from SpeechToText.speech_to_text_whisper import SpeechToTextWhisper
from SettingsManager.settings_manager import SettingsManager
from TextToSpeech.text_to_speech_gtts import TextToSpeechGTTS
from LanguageModel.language_model import LanguageModel

from word2num import word2num
from spacy import load
import numerizer
nlp = load('en_core_web_sm')

def test_stt(settings_manager, input_path):
    converter = SpeechToTextWhisper(settings_manager)
    converter.convert(input_path)
    return converter.converted_text, converter.language


def test_tts(settings_manager, output_path, text, language = "en"):
    converter = TextToSpeechGTTS(settings_manager, language)
    converter.convert(text, output_path)


def test_language_model(settings_manager, prompt):
    model = LanguageModel(settings_manager, 'ModelPath')
    return model.generate_response(prompt)


def test_language_model_chat(settings_manager):
    model = LanguageModel(settings_manager, 'ModelPath')
    model.set_system_prompt(
        '''
        You are a Senior Python developer in my company. 
        I am a junior developer who has just graduated college and started working in the same company as you.
        I am reaching out to you for help. 
        The company project is a medical project that looks at x-rays and identifies tumors.
        ''')

    while(True):
        prompt = input("Question: ")
        response = model.generate_chat_response(prompt)
        print("Response", response)


def main():
    settings_manager = SettingsManager()

    doc = nlp("forty five thousand umm")
    numerized = doc._.numerize()
    print(list(numerized.values())[0])

    # input_path = 'SampleAudioFiles\\Prompt1.m4a'
    # output_path = 'OutputPath\\output1.mp3'

    # test_language_model_chat(settings_manager)
    
    # # STT: Converts audio from input_path to text
    # text, language = test_stt(settings_manager, input_path)

    # # LLM: Feeds the text from the STT to LLM
    # response = test_language_model(settings_manager, text)

    # # TTS: Converts response from LLM to audio and stores in output_path
    # test_tts(settings_manager, output_path, response, language)


if __name__ == '__main__':
    main()