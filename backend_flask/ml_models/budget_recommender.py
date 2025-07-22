import json
import pandas as pd
import numpy as np
from prophet import Prophet
from sklearn.linear_model import LinearRegression
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


# Budget Suggestion using Rule-Based AI Logic
def recommend_budget(data):
    income = data.get("income", 0)
    expenses = dict(data.get("expense", {}))
    total_expense = sum(expenses.values())

    temp_expenses = dict()
    for key in expenses.keys():
        temp_expenses[key.lower()] = expenses[key]
    expenses = temp_expenses
    print(expenses)

    suggestions = []
    if total_expense > income:
        suggestions.append("⚠️ You are spending more than your income.")

    if expenses.get("marketing", 0) > 0.3 * income:
        suggestions.append("📉 Reduce marketing expenses to around 20% of income.")

    if expenses.get("misc", 0) > 0.1 * income:
        suggestions.append("🔍 Review miscellaneous expenses.")

    return {"status": "ok", "suggestions": suggestions or ["✅ Budget looks healthy."]}


#ML-based Funding Scheme Matching using Fuzzy Rules
# def match_funding(data):
#     region = data.get("region", "").lower()
#     industry = data.get("industry", "").lower()
#     stage = data.get("business_stage", "").lower()

#     with open("data/funding_schemes.json", "r") as f:
#         schemes = json.load(f)

#     matched = []
#     for scheme in schemes:
#         if region in scheme["region"].lower() or industry in scheme["industry"].lower():
#             if stage in scheme["eligibility"].lower():
#                 matched.append(scheme)

#     return {"matches": matched or [], "count": len(matched)}

def match_funding(business_sector: str, funding_amount: int):
    df = pd.read_csv("ml_models/data/funding_schemes.csv")

    # Filter by funding amount range
    df_filtered = df[
        (df["funding_min"] <= funding_amount) &
        (df["funding_max"] >= funding_amount)
    ]

    # Optional: further filter by business sector (case-insensitive)
    df_filtered = df_filtered[
        df_filtered["industry"].str.lower().str.contains(business_sector.lower())
    ]

    if df_filtered.empty:
        return {"matches": [], "message": "No matching funding schemes found."}

    # Create NLP corpus from combined fields
    df_filtered["combined"] = (
        df_filtered["name"].fillna("") + " " +
        df_filtered["description"].fillna("") + " " +
        df_filtered["region"].fillna("") + " " +
        df_filtered["industry"].fillna("") + " " +
        df_filtered["eligibility"].fillna("")
    )

    # User intent sentence
    user_desc = f"{business_sector} sector startup seeking {funding_amount} INR funding"
    corpus = df_filtered["combined"].tolist() + [user_desc]

    # TF-IDF similarity
    tfidf = TfidfVectorizer()
    tfidf_matrix = tfidf.fit_transform(corpus)
    user_vector = tfidf_matrix[-1]
    similarity_scores = cosine_similarity(user_vector, tfidf_matrix[:-1]).flatten()

    # Get top 3 matches
    top_indices = similarity_scores.argsort()[-3:][::-1]
    matches = df_filtered.iloc[top_indices][[
        "name", "description", "region", "industry", "eligibility", "funding_min", "funding_max"
    ]].to_dict(orient="records")
    return {"matches": matches}


# Prophet Forecasting: Future Revenue/Expense Prediction
def forecast_cashflow(data):
    df = pd.DataFrame(data["history"])  # expects [{"ds": "2024-06-01", "y": 10000}, ...]

    if len(df) < 6:
        return {"error": "Need at least 6 months of historical data for forecasting."}

    model = Prophet()
    model.fit(df)

    future = model.make_future_dataframe(periods=3, freq="M")
    forecast = model.predict(future)

    return {
        "forecast": forecast[["ds", "yhat"]].tail(3).to_dict(orient="records")
    }



def simple_linear_forecast(history):
    df = pd.DataFrame(history)
    df["t"] = np.arange(len(df)).reshape(-1, 1)
    model = LinearRegression()
    model.fit(df["t"].values.reshape(-1, 1), df["y"].values)

    future = np.arange(len(df), len(df) + 3).reshape(-1, 1)
    preds = model.predict(future)
    dates = pd.date_range(start=df["ds"].iloc[-1], periods=4, freq="M")[1:]
    return [{"ds": str(d), "yhat": float(y)} for d, y in zip(dates, preds)]
