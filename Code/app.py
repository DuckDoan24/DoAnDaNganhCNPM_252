import sys
import os
import random
import time
from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for
from Adafruit_IO import MQTTClient

load_dotenv()
##########################################
##### Khoi tao lien ket den Adafruit #####
##########################################
AIO_USERNAME = os.getenv("ADA_USERNAME")
AIO_KEY = os.getenv("ADA_KEY")

def connected (client) :
    print ("Ket noi thanh cong ...")
    client.subscribe("led")

def subscribe (client, userdata, mid, granted_qos) :
    print ("Subcribe thanh cong ...")

def disconnected (client) :
    print ("Ngat ket noi ...")
    sys.exit (1)

def message (client, feed_id, payload):
    print ("Nhan du lieu :" + payload)

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

@app.route('/', methods=['GET'])
def index():
    return render_template('test.html')

# Vi du API bat tat den
@app.route('/led', methods=['POST'])
def submit_led():
    req = request.json
    data = req["state"]  
    client.publish("led", data)
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(debug=True)