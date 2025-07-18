from flask import Blueprint, request, jsonify, current_app, send_file
import os
from flasgger import swag_from

from TextToSpeech.text_to_speech_gtts import TextToSpeechGTTS

tts_blueprint = Blueprint("tts", __name__)

@tts_blueprint.route("/speak", methods=["POST"])
@swag_from("FlasggerDocstrings/tts_routes/speak.yml")
def speak():
    data = request.get_json()
    text = data.get("text")
    language = data.get("language", "en")

    if not text:
        return jsonify({"error": "Text is required"}), 400

    settings_manager = current_app.settings
    converter = TextToSpeechGTTS(settings_manager, language)
    output_path = os.path.abspath(converter.convert(text))

    return send_file(
        output_path,
        mimetype="audio/mpeg",
        as_attachment=True  # True = download, False = stream
    )
