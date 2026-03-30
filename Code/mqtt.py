import os
import threading
import json
import sys
from Adafruit_IO import MQTTClient
from datetime import datetime, timezone

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
    client.subscribe("fan-speed")
    client.subscribe("led-color")
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