from flask import Blueprint, request, jsonify, current_app
from ml_models.budget_recommender import recommend_budget,match_funding,forecast_cashflow
ai_ml_blueprint = Blueprint('ai_ml', __name__)

@ai_ml_blueprint.route("/predict_budget", methods=["POST"])
def budget():
    data = request.json
    return jsonify(recommend_budget(data))


# @ai_ml_blueprint.route("/match_funding", methods=["POST"])
# def funding():
#     data = request.json
#     return jsonify(match_funding(data))


@ai_ml_blueprint.route("/match_funding", methods=["POST"])
def funding():
    data = request.get_json()
    sector = data.get("sector")
    required_amount = data.get("amount_needed")

    if not sector:
        sector = "Other"
    if not required_amount:
        return jsonify({"error": "Missing Required Amount"})

    matched = match_funding(sector, required_amount)
    response = jsonify(matched)
    return response


@ai_ml_blueprint.route("/forecast_growth", methods=["POST"])
def forecast():
    data = request.get_json()
    print(data)
    return jsonify(forecast_cashflow(data))