import os
from flask import Flask


def create_app():
    app = Flask(__name__)

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    @app.route("/")
    def hello():
        return "Hello, World"


    @app.route("/__mon/health")
    def health():
        return "{\"health\": \"ok\"}"

    return app
