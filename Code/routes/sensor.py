from flask import Blueprint, request, jsonify
from mqtt import client, _parse_number, _append_temperature_history, _read_temperature_history

sensor_bp = Blueprint('sensor', __name__)

@sensor_bp.route('/temperature', methods=['GET'])
def get_temperature():
    """
    Get current temperature
    ---
    tags:
      - Sensor
    responses:
      200:
        description: Latest temperature feed
        schema:
          type: object
          properties:
            feed:
              type: string
            value:
              type: number
            created_at:
              type: string
    """
    data = client.receive('temperature')
    value = _parse_number(getattr(data, "value", None))
    created_at = getattr(data, "created_at", None)
    _append_temperature_history(value, created_at)

    return {
        "feed": "temperature",
        "value": value,
        "created_at": created_at,
    }

@sensor_bp.route('/temperature/history', methods=['GET'])
def get_temperature_history():
    """
    Get temperature history
    ---
    tags:
      - Sensor
    parameters:
      - in: query
        name: limit
        type: integer
        required: false
        description: Maximum number of history entries (default 20, max 100)
    responses:
      200:
        description: Temperature history list
        schema:
          type: object
          properties:
            feed:
              type: string
            count:
              type: integer
            history:
              type: array
              items:
                type: object
    """
    limit = request.args.get("limit", default=20, type=int)
    if limit is None or limit <= 0:
        limit = 20
    if limit > 100:
        limit = 100

    history = _read_temperature_history(limit)

    return {
        "feed": "temperature",
        "count": len(history),
        "history": history,
    }

@sensor_bp.route('/humidity', methods=['GET'])
def get_humidity():
    """
    Get current humidity
    ---
    tags:
      - Sensor
    responses:
      200:
        description: Latest humidity feed
        schema:
          type: object
          properties:
            feed:
              type: string
            value:
              type: number
            created_at:
              type: string
    """
    data = client.receive("humidity")
    return {
        "feed": "humidity",
        "value": _parse_number(getattr(data, "value", None)),
        "created_at": getattr(data, "created_at", None),
    }

@sensor_bp.route('/brightness', methods=['GET'])
def get_brightness():
    """
    Get current brightness
    ---
    tags:
      - Sensor
    responses:
      200:
        description: Latest brightness feed
        schema:
          type: object
          properties:
            feed:
              type: string
            value:
              type: number
            created_at:
              type: string
    """
    data = client.receive("brightness")
    return {
        "feed": "brightness",
        "value": _parse_number(getattr(data, "value", None)),
        "created_at": getattr(data, "created_at", None),
    }