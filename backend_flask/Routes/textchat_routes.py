from flask import Blueprint, request, jsonify, current_app, send_file
import os
from flasgger import swag_from

from SpeechToText.speech_to_text_whisper import SpeechToTextWhisper
from TextToSpeech.text_to_speech_gtts import TextToSpeechGTTS

textchat_blueprint = Blueprint("textchat", __name__)

@textchat_blueprint.route("/generate_response", methods=["POST"])
@swag_from("FlasggerDocstrings/textchat_routes/generate_response.yml")
def generate_response():
    prompt = request.get_json().get("prompt")

    model = current_app.language_model
    response = model.generate_chat_response(prompt)

    print(response)

    return jsonify({
        "response": response
    })
