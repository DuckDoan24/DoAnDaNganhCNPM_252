from flask import Blueprint, request, jsonify
import mqtt 
sensor_bp = Blueprint('sensor', __name__)

@sensor_bp.route('/sensor/temperature', methods=['GET'])
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
    return {
        "feed": "temperature",
        "value": mqtt.latest_temp,
        "created_at": mqtt.temp_time,
    }

@sensor_bp.route('/sensor/temperature/history', methods=['GET'])
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

    history = mqtt._read_temperature_history(limit)

    return {
        "feed": "temperature",
        "count": len(history),
        "history": history,
    }

@sensor_bp.route('/sensor/humidity', methods=['GET'])
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
    return {
        "feed": "humidity",
        "value": mqtt.latest_humid,
        "created_at": mqtt.humid_time,
    }

@sensor_bp.route('/sensor/brightness', methods=['GET'])
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
    return {
        "feed": "brightness",
        "value": mqtt.latest_bright,
        "created_at": mqtt.bright_time,
    }