import sys
import os
import random
import time
import json
import threading
import psycopg2
from flask_jwt_extended import create_access_token, jwt_required, JWTManager, unset_jwt_cookies
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for, jsonify, make_response
from Adafruit_IO import MQTTClient
from flask_bcrypt import Bcrypt

load_dotenv()

##########################################
##### Khoi tao lien ket den Adafruit #####
##########################################
AIO_USERNAME = os.getenv("ADA_USERNAME")
AIO_KEY = os.getenv("ADA_KEY")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_DATA_DIR = os.path.join(BASE_DIR, "data")
TEMPERATURE_HISTORY_FILE = os.path.join(LOCAL_DATA_DIR, "temperature_history.jsonl")
TEMP_HISTORY_MAX_ITEMS = 1000
_temp_history_lock = threading.Lock()

def connected (client) :
    print ("Ket noi thanh cong ...")
    client.subscribe("led")
    client.subscribe("temperature")
    client.subscribe("humidity")
    client.subscribe("brightness")

def subscribe (client, userdata, mid, granted_qos) :
    print ("Subcribe thanh cong ...")

def disconnected (client) :
    print ("Ngat ket noi ...")
    sys.exit (1)

def message (client, feed_id, payload):
    print ("Nhan du lieu :" + payload)

def _parse_number(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return value

def _ensure_local_data_dir():
    os.makedirs(LOCAL_DATA_DIR, exist_ok=True)


def _append_temperature_history(value, created_at=None):
    _ensure_local_data_dir()
    entry = {
        "value": _parse_number(value),
        "created_at": created_at or datetime.now(timezone.utc).isoformat(),
    }

    with _temp_history_lock:
        with open(TEMPERATURE_HISTORY_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")

        with open(TEMPERATURE_HISTORY_FILE, "r", encoding="utf-8") as f:
            lines = f.readlines()

        if len(lines) > TEMP_HISTORY_MAX_ITEMS:
            lines = lines[-TEMP_HISTORY_MAX_ITEMS:]
            with open(TEMPERATURE_HISTORY_FILE, "w", encoding="utf-8") as f:
                f.writelines(lines)


def _read_temperature_history(limit):
    with _temp_history_lock:
        if not os.path.exists(TEMPERATURE_HISTORY_FILE):
            return []

        with open(TEMPERATURE_HISTORY_FILE, "r", encoding="utf-8") as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]

    lines = lines[-limit:]
    history = []
    for line in lines:
        try:
            record = json.loads(line)
            history.append(
                {
                    "value": _parse_number(record.get("value")),
                    "created_at": record.get("created_at"),
                }
            )
        except json.JSONDecodeError:
            continue

    return history

client = MQTTClient(AIO_USERNAME, AIO_KEY)
client.on_connect = connected
client.on_disconnect = disconnected
client.on_message = message
client.on_subscribe = subscribe
client.connect()
client.loop_background()
##########################################
##### Khoi tao lien ket den Adafruit #####
##########################################

app = Flask(__name__)
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")
jwt = JWTManager(app)
conn = psycopg2.connect(database=os.getenv("DB_NAME"), user=os.getenv("DB_USER"),
                        password=os.getenv("DB_PASSWORD"), host="localhost", port="5432")
bcrypt = Bcrypt(app)

@app.route('/', methods=['GET'])
def index():
    return render_template('test.html')

# Vi du API bat tat den
@app.route('/led', methods=['POST'])
def submit_led():
    print('register')
    req = request.json
    data = req["state"]  
    client.publish("led", data)
    return {"status": "ok"}

@app.route('/temperature', methods=['GET'])
def get_temperature():
    data = client.receive('temperature')
    value = _parse_number(getattr(data, "value", None))
    created_at = getattr(data, "created_at", None)
    _append_temperature_history(value, created_at)

    return {
        "feed": "temperature",
        "value": value,
        "created_at": created_at,
    }

@app.route('/temperature/history', methods=['GET'])
def get_temperature_history():
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

@app.route('/humidity', methods=['GET'])
def get_humidity():
    data = client.receive("humidity")
    return {
        "feed": "humidity",
        "value": _parse_number(getattr(data, "value", None)),
        "created_at": getattr(data, "created_at", None),
    }

@app.route('/brightness', methods=['GET'])
def get_brightness():
    data = client.receive("brightness")
    return {
        "feed": "brightness",
        "value": _parse_number(getattr(data, "value", None)),
        "created_at": getattr(data, "created_at", None),
    }
@app.route('/user/register', methods=['POST'])
def user_register():
    data = request.get_json()

    if not data:
        return jsonify({"error": "Invalid JSON"}), 400

    email = data.get('email')
    fullname = data.get('fullname')
    dob = data.get('dob')
    phonenum = data.get('phonenum')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

        cur = conn.cursor()
        cur.execute("""
            INSERT INTO users (email, fullname, dob, phonenum, password_hash)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id;
        """, (email, fullname, dob, phonenum, hashed_password))

        user_id = cur.fetchone()[0]
        conn.commit()

        return jsonify({
            "message": "User created",
            "id": user_id
        }), 201

    except Exception as e:
        print("error:", e)
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()

@app.route('/user/login', methods=['POST'])
def user_login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    cur = conn.cursor()
    cur.execute("""
    SELECT id, password_hash FROM users WHERE email=%s
    """, (email,))
    user = cur.fetchone()
    cur.close()
    
    if not user: return jsonify({"error": "Wrong email or password"}), 404

    user_id, user_pass = user
    if bcrypt.check_password_hash(user_pass, password):
        token = create_access_token(
            identity = user_id,
            expires_delta = datetime.timedelta(hours=1)
        )
        return jsonify({'access-token': token})
    else: 
        return jsonify({"error": "Wrong email or password"})

@app.route('/user/logout', methods=['POST'])
def user_logout():
    response = jsonify({"msg": "Logout successfully"})
    unset_jwt_cookies(response)
    return response

@app.route('/user/<int:id>', methods=['GET'])
def user_getinfo(id):
    cur = conn.cursor()
    cur.execute("""
    SELECT email, fullname, dob, phonenum FROM users WHERE id=%s
    """, (id,))
    user = cur.fetchone()
    cur.close()
    email, fullname, dob, phonenum = user
    response = jsonify({'email':email, 'fullname':  fullname, 'dob': dob, 'phonenum': phonenum})
    return response

@app.route('/user/delete/<int:id>', methods=['POST'])
def user_delete(id):
    try:
        cur = conn.cursor()
        cur.execute("""
        DELETE FROM users WHERE id=%s
        """, (id,))
        conn.commit()

        return jsonify({
            "message": "User deleted",
        }), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()

@app.route('/user/update/<int:id>', methods=['POST'])
def user_update(id):
    data = request.json
    fullname = data.get('fullname')
    dob = data.get('dob')
    phonenum = data.get('phonenum')
    try:
        cur = conn.cursor()
        cur.execute("""
        UPDATE users
        SET fullname=%s, dob=%s, phonenum=%s
        WHERE id=%s
        """, (fullname, dob, phonenum, id))
        conn.commit()

        return jsonify({
            "message": "User updated",
        }), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400

    finally:
        cur.close()

if __name__ == "__main__":
    app.run(debug=True)