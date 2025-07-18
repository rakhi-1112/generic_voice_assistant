from flask import Blueprint, request, jsonify, current_app
from SpeechToText.speech_to_text_whisper import SpeechToTextWhisper
from flasgger import swag_from

stt_blueprint = Blueprint("stt", __name__)

@stt_blueprint.route("/transcribe", methods=["POST"])
@swag_from("FlasggerDocstrings/stt_routes/transcribe.yml")
def transcribe():
    audio = request.files.get("audio")
    if not audio:
        return jsonify({"error": "No audio file uploaded"}), 400
    
    is_numeric = request.form.get("is_numeric") or request.args.get("is_numeric") or "false"
    is_numeric = is_numeric.lower() in ["true", "1", "yes"]

    settings_manager = current_app.settings
    converter = SpeechToTextWhisper(settings_manager)

    transcript = converter.convert(audio, is_numeric)
    return jsonify({"transcript": transcript})