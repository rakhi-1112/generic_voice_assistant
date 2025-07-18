from gpt4all import GPT4All
import torch

class LanguageModel:
    def __init__(self, settings_manager, model_path):
        self.__settingsManager = settings_manager

        gguf_name = self.__settingsManager.get('language_model', 'model_gguf_file_name')
        self.__max_context_window = int(self.__settingsManager.get('language_model', 'max_context_window'))
        self.__system_prompt = ""

        self.__device = 'cpu'
        if torch.cuda.is_available():
            self.__device = 'cuda'
        self.__model = GPT4All(model_name = gguf_name, 
                               model_path = model_path, 
                               device = self.__device, 
                               n_ctx = self.__max_context_window)
        
        # Creating a persistent sesssion
        self.__session = self.__model.chat_session()


    def generate_response(self, prompt: str) -> str:
        """
        Generate a standalone response without a chat session
        """
        return self.__model.generate(prompt)
    

    def set_system_prompt(self, prompt: str):
        """
        Updates system prompt and resets session.
        """
        self.__system_prompt = prompt
        self.__reset_session()


    def __reset_session(self):
        """
        Clears chat session and re-applies system prompt.
        """
        self.__session = self.__model.chat_session(self.__system_prompt)


    def generate_chat_response(self, prompt: str) -> str:
        """
        Send user input to the model and get assistant response within chat session.
        """
        self.__reset_session()
        response = ""
        with self.__session:
            response = self.__model.generate(prompt,
                                         max_tokens = 1024)
            
        return response