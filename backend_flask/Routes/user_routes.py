import uuid
from flask import Blueprint, request, jsonify, current_app
from firebase_admin import firestore
from datetime import datetime
from flasgger import swag_from

from DataValidation.user_validation import UserValidation
from DataHelper.user_data_helper import UserDataHelper

user_blueprint = Blueprint("user", __name__)

@user_blueprint.route('/create_user', methods=['POST'])
@swag_from('FlasggerDocstrings/user_routes/create_user.yml')
def create_user():
    try:
        data = request.get_json()
        db = current_app.firebase_db
        user_data_helper = UserDataHelper(db)

        is_valid, message = UserValidation.validate(data, user_data_helper)
        if not is_valid:
            return jsonify({"error": message}), 400

        user_id = str(uuid.uuid4())
        timestamp = firestore.SERVER_TIMESTAMP

        user_data = {
            "user_id": user_id,
            "username": data['username'],
            "password_hash": data['password_hash'],
            "email": data['email'],
            "created_at": timestamp,
            "updated_at": timestamp
        }

        db.collection("users").document(user_id).set(user_data)

        return jsonify({
            "message": "User created successfully",
            "user_name": user_id
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500