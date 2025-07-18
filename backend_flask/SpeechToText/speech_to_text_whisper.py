import whisper
import os
import torch
import tempfile
from werkzeug.datastructures import FileStorage

# For converting words to numbers
from spacy import load
import numerizer
nlp = load('en_core_web_sm')

class SpeechToTextWhisper():
    def __init__(self, settings_manager):
        self.__settingsManager = settings_manager
        self.__model_type = self.__settingsManager.get('stt', 'whisper_model')

        self.language = ''
        self.converted_text = ''

        self.__device = 'cpu'
        if torch.cuda.is_available() and self.__model_type in ['tiny', 'base', 'small']:
            self.__device = 'cuda'
            
        # TODO: Exception Handling
        self.__model = whisper.load_model(self.__model_type, device=self.__device)

    
    def __text_to_number(self, text: str) -> str:
        doc = nlp(text)
        numerized = doc._.numerize()
        result = list(numerized.values())[0]
        return result.replace(",", "")
        

    def convert(self, audio_input, is_numeric = False) -> str:
        """
        Transcribes audio from a file path or a Flask FileStorage object.

        :param audio_input: Path to audio file (str) or FileStorage object
        :return: Transcribed text
        """
        file_path = None
        temp_file = None

        if isinstance(audio_input, FileStorage):
            temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
            audio_input.save(temp_file.name)
            file_path = temp_file.name

        elif isinstance(audio_input, str):
            if not os.path.exists(audio_input):
                return 'Path does not exist'
            file_path = audio_input

        else:
            raise ValueError("Unsupported input type. Must be path or FileStorage.")

        try:
            output = self.__model.transcribe(file_path)
            self.converted_text = output['text']
            if (is_numeric):
                self.converted_text = self.__text_to_number(self.converted_text)

            self.language = output['language']

            print(self.converted_text)

            return self.converted_text
        finally:
            if temp_file:
                temp_file.close()