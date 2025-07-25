# System Imports
from flask import Flask
from flasgger import Swagger
import firebase_admin
from firebase_admin import credentials, firestore

# Custom Imports
from Routes import register_blueprints
from SettingsManager.settings_manager import SettingsManager
from LanguageModel.language_model import LanguageModel

def create_app():
    app = Flask(__name__)

    settings_manager = SettingsManager()
    model = LanguageModel(settings_manager, 'ModelPath')
    app.settings = settings_manager
    app.language_model = model

    swagger = Swagger(app)

    certificate_path = settings_manager.get("firebase", "firebase_sdk_path")
    certificate_path = "../" + certificate_path     # Assuming the project is ran from server.py, then go one step back

    cred = credentials.Certificate(certificate_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    app.firebase_db = db

    register_blueprints(app)
    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True, host="0.0.0.0", port=5050)