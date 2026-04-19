import os
from dotenv import load_dotenv
from flask import Flask, render_template
from flask_cors import CORS
from flasgger import Swagger

load_dotenv()

from routes.user import bcrypt, jwt, user_bp
from routes.control import control_bp
from routes.sensor import sensor_bp

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
swagger = Swagger(app)
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY")
jwt.init_app(app)
bcrypt.init_app(app)

@app.route('/', methods=['GET'])
def index():
    return render_template('test.html')

app.register_blueprint(user_bp)
app.register_blueprint(control_bp)
app.register_blueprint(sensor_bp)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')