from flask import Blueprint, request, jsonify, current_app
from firebase_admin import firestore
from flasgger import swag_from

from DataValidation.investment_adv_validation import InvestmentAdvisoryValidation
from DataHelper.user_data_helper import UserDataHelper

investment_adv_blueprint = Blueprint('investment', __name__)

@investment_adv_blueprint.route('/submit_investment', methods=['POST'])
@swag_from('FlasggerDocstrings/investment_adv_routes/submit_investment.yml')
def submit_investment():
    try:
        data = request.get_json()
        data['inv_frequency'] = data['inv_frequency'].lower()
        db = current_app.firebase_db
        user_helper = UserDataHelper(db)

        is_valid, message = InvestmentAdvisoryValidation.validate(data)
        if not is_valid:
            return jsonify({"error": message}), 400

        username = data.get('username')
        user_id = user_helper.get_user_id(username)

        if not user_id:
            return jsonify({"error": "Username not found"}), 404

        inv_ref = db.collection('users').document(user_id).collection('investments')
        inv_ref.add({
            "age_group": data['age_group'],
            "inv_frequency": data['inv_frequency'],
            "inv_goal": data['inv_goal'],
            "inv_risk": data['inv_risk'],
            "inv_amount": data['inv_amount']
        })

        return jsonify({"message": "Investment data saved successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
