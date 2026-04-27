import os
import threading
import json
import sys
from Adafruit_IO import MQTTClient
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
from db import conn

##########################################
##### Khoi tao lien ket den Adafruit #####
##########################################
AIO_USERNAME = os.getenv("ADA_USERNAME")
AIO_KEY = os.getenv("ADA_KEY")

latest_temp = 0
temp_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()
latest_humid = 0
humid_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()
latest_bright = 0
bright_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()

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
    global latest_humid, humid_time, latest_bright, bright_time, latest_temp, temp_time
    if feed_id == "temperature":
        latest_temp = _parse_number(payload)
        temp_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()
        _append_temperature_history(latest_temp, temp_time)
    elif feed_id == "humidity":
        latest_humid = _parse_number(payload)
        humid_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()
    elif feed_id == "brightness":
        latest_bright = _parse_number(payload)
        bright_time = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()

def _parse_number(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return value


def _append_temperature_history(value, created_at=None):
    temp = _parse_number(value)
    timestamp_str = created_at or datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).replace(microsecond=0).isoformat()
    cur = conn.cursor()
    cur.execute("INSERT INTO temperature (temperature, timestamp) VALUES (%s, %s)", (temp, timestamp_str))
    conn.commit()
    cur.close()


def _read_temperature_history(limit):
    cur = conn.cursor()
    cur.execute("SELECT temperature, timestamp FROM temperature ORDER BY id DESC LIMIT %s", (limit,))
    rows = cur.fetchall()
    cur.close()
    history = []
    for row in reversed(rows):
        history.append({
            "value": row[0],
            "created_at": row[1].isoformat() if row[1] else None
        })
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