NOTE: 
1. Make sure that the `OutputPath` and `ModelPath` folders are present with `backend_flask` folder
2. pip install requirements.txt
3. Python tests.py


## Settings Management
- Use `SettingsManager` class to interact with `config.json`. 
- `config.json` acts as a backend wide place to store all your app settings.
- Add settings to `config.json` and then access it with `SettingsManager.get()`
- To change the value of an existing setting, use `SettingsManager.set()`

## Speech to Text

### Prerequisites
- To use `Whisper`, `FFMPEG` needs to be installed. Use `winget install ffmpeg` on the command prompt.
- To use `spacy`, to extract numbers out of text, use `python -m spacy download en_core_web_sm`
- To use `PyTorch` with CUDA (if you have an NVidia GPU), use `torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`
- NOTE: The `small` variant of Whisper is pretty fast. It is also very accurate for english audios, however, the accuracy for Hindi is lower.
    - The `medium` variant of can be used. It requires 5.3 GB of VRAM with CUDA, so will need a pretty powerful laptop to get this running. So use CPU if you want to use the `medium` variant. Make sure your PC has enough storage. This takes about 1.5 mins for a 30 second audio. Performance on Hindi audio is significantly better, although not perfect.


## Text to Speech

### gTTS

