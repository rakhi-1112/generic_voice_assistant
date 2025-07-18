from flask import Blueprint, request, jsonify, current_app, send_file
import os
from flasgger import swag_from

from SpeechToText.speech_to_text_whisper import SpeechToTextWhisper
from TextToSpeech.text_to_speech_gtts import TextToSpeechGTTS

voicechat_blueprint = Blueprint("voicechat", __name__)

@voicechat_blueprint.route("/add_system_prompt", methods=["POST"])
@swag_from("FlasggerDocstrings/voicechat_routes/add_system_prompt.yml")
def add_system_prompt():
    data = request.get_json()
    prompt = data.get("prompt")

    if not prompt:
        return jsonify({"error": "Prompt is required"}), 400

    model = current_app.language_model
    model.set_system_prompt(prompt)

    return jsonify({"message": "System prompt updated successfully."}), 200


@voicechat_blueprint.route("/generate_response", methods=["POST"])
@swag_from("FlasggerDocstrings/voicechat_routes/generate_response.yml")
def generate_response():
    # STT Layer
    audio = request.files.get("audio")
    if not audio:
        return jsonify({"error": "No audio file uploaded"}), 400

    settings_manager = current_app.settings
    converter = SpeechToTextWhisper(settings_manager)

    converter.convert(audio)
    transcript = converter.converted_text
    language = converter.language

    print(transcript)
    print(language)

    # LLM Layer
    model = current_app.language_model
    response = model.generate_chat_response(transcript)

    print(response)

    # TTS Layer
    if not response:
        return jsonify({"error": "Model Failed to Generate Response"}), 400
    
    converter = TextToSpeechGTTS(settings_manager, language)
    output_path = os.path.abspath(converter.convert(response))

    return send_file(
        output_path,
        mimetype="audio/mpeg",
        as_attachment=True  # True = download, False = stream
    )
