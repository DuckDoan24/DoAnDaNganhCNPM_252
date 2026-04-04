from flask import Blueprint, request, jsonify
from mqtt import client

control_bp = Blueprint('control', __name__)

# Vi du API bat/tat den
@control_bp.route('/led', methods=['POST'])
def submit_led():
    """
    Control LED state
    ---
    tags:
      - Control
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            state:
              type: string
              description: "on/off"
          required:
            - state
    responses:
      200:
        description: LED state set
        schema:
          type: object
          properties:
            status:
              type: string
    """
    print('register')
    req = request.json
    data = req["state"]  
    client.publish("led", data)
    return {"status": "ok"}

# API dieu khien toc do quat
@control_bp.route('/fan', methods=['POST'])
def submit_fan():
    """
    Control fan speed
    ---
    tags:
      - Control
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            speed:
              type: string
              description: "speed value (0-100)"
          required:
            - speed
    responses:
      200:
        description: Fan speed set
        schema:
          type: object
          properties:
            status:
              type: string
    """
    req = request.json
    data = req.get("speed", "0")
    client.publish("fan-speed", data)
    return {"status": "ok"}

# API dieu khien mau den
@control_bp.route('/color', methods=['POST'])
def submit_color():
    """
    Control LED color
    ---
    tags:
      - Control
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            color:
              type: string
              description: "hex color code, e.g. #FF0000"
          required:
            - color
    responses:
      200:
        description: LED color set
        schema:
          type: object
          properties:
            status:
              type: string
    """
    req = request.json
    data = req.get("color", "1")
    client.publish("led", data)
    return {"status": "ok"}
