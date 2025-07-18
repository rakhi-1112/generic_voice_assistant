from gtts import gTTS
from pydub import AudioSegment
import os
import uuid
import tempfile
import textwrap

ACCENT_MAP = {
    "us": "com",
    "uk": "co.uk",
    "australia": "com.au",
    "canada": "ca",
    "india": "co.in",
    "ireland": "ie",
    "south_africa": "co.za",
}

class TextToSpeechGTTS:
    def __init__(self, settings_manager, lang="en"):
        self.__lang = lang

        self.__settingsManager = settings_manager
        self.__max_chars = int(self.__settingsManager.get('tts', 'gtts_char_limit'))

        self.__accent_code = 'com'
        accent_country = self.__settingsManager.get('tts', 'gtts_accent_region').lower()
        if accent_country in ACCENT_MAP:
            self.__accent_code = ACCENT_MAP[accent_country] 

    def __split_text(self, text):
        return textwrap.wrap(text, self.__max_chars, break_long_words=False, replace_whitespace=False)

    def convert(self, text, output_file="OutputPath\\output.mp3"):
        chunks = self.__split_text(text)
        print(f"Text split into {len(chunks)} chunks")

        temp_files = []
        try:
            for i, chunk in enumerate(chunks):
                tts = gTTS(text = chunk, lang = self.__lang, tld = self.__accent_code)
                temp_path = os.path.join(tempfile.gettempdir(), f"tts_chunk_{uuid.uuid4()}.mp3")
                tts.save(temp_path)
                temp_files.append(temp_path)

            combined = AudioSegment.empty()
            for file in temp_files:
                combined += AudioSegment.from_file(file)

            combined.export(output_file, format="mp3")
            print(f"Saved combined TTS output to {output_file}")

        finally:
            for file in temp_files:
                if os.path.exists(file):
                    os.remove(file)

            return output_file
