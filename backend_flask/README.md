## Settings Management
- Use `SettingsManager` class to interact with `config.json`. 
- `config.json` acts as a backend wide place to store all your app settings.
- Add settings to `config.json` and then access it with `SettingsManager.get()`
- To change the value of an existing setting, use `SettingsManager.set()`

## Speech to Text
- NOTE: The `small` variant of Whisper is pretty fast. It is also very accurate for english audios, however, the accuracy for Hindi is lower.
    - The `medium` variant of can be used. It requires 5.3 GB of VRAM with CUDA, so will need a pretty powerful laptop to get this running. So use CPU if you want to use the `medium` variant. Make sure your PC has enough storage. This takes about 1.5 mins for a 30 second audio. Performance on Hindi audio is significantly better, although not perfect.

# Steps to Run Everything

## Setting up Firebase
1. Go to Firebase console: `console.firebase.google.com`
2. Create a new Firebase project, if you haven't already
3. Enter project name
4. Keep unchecking the options and pressing Continue on the next two screens.
5. Once you're at the project Dashboard, find the Tile which says `Cloud Firestore`, and click it.
6. Click the button that says `Create Database`
7. Here set the server location to somewhere that's near to you, maybe Mumbai.
8. In the next screen, choose `Start in Production Mode`
9. Now in the root directory of the project, create a new folder called `secrets` (case-sensitive)
10. In Firebase Console, on the top left, beside the `Project Overview` button, there's a Settings button. Click it.
11. Click Project Settings
12. Go to Service Accounts
13. Click on `Generate New Private Key`. This will download a json file named `firebase-adminsdk-xxxx.json` or smth similar.
14. Move this private key file to the `secrets` folder that was created in Step 9.
15. Navigate to `backend_flask\config.json`, and find the setting `firebase_sdk_path`. Write the path of the private key file, relative to the project root. It should look something like: `"secrets/generic-voice-assistant-firebase-adminsdk-xxxx.json"`

## Running Backend
1. On a terminal anywhere, run the command `winget install ffmpeg`.
2. On a terminal anyweher, run the command `python -m spacy download en_core_web_sm`
3. Now open a terminal inside `backend_flask`, and run `pip install -r requirements.txt`
4. Create the `OutputPath` and `ModelPath` folders inside the `backend_flask` folder if they aren't already there.
5. **IMPORTANT**: If your laptop has an NVIDIA GPU, with >=4GB of VRAM, you can use CUDA while running the LLM. 
    5.1. If you can use CUDA, run the commands `pip uninstall torch`, and then `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`. Then follow the next steps.
    5.2. If you can't use CUDA, go to `LanguageModel.language_model.py`. In the constructor, comment out the two lines:
    ```
    if torch.cuda.is_available():
        self.__device = 'cuda'
    ```
5. Now start the server with `Python server.py`
6. Make a note of the non-localhost ip of the server, something like: `http://192.168.x.x:5050`.

7. To view all the api endpoints on the server, go to a browser and use `http://192.168.x.x:5050/apidocs`

## Running Frontend
**Prerequisites**:
- If you're trying to run the app on a physical phone (not an emulator), 
    1. Make sure both your phone and PC are connected to the same network.
    2. Make sure that `Developer Options` and `USB Debugging` are turned on your phone.
- Make sure that Flutter is set up on your PC:
    1. Download flutter sdk: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.6-stable.zip
    2. Extract this, it should create a folder named exactly `flutter`
    3. Go to C:\Users\<your-username> and create a folder called dev
    4. Paste the previously extracted `flutter` folder inside `dev`.
    5. Go inside `dev\flutter\bin`, there should be some files: flutter.bat, flutter, dart.bat, etc
    6. Copy the path of this folder, it should be `C:\Users\<your-usernmae>\dev\flutter\bin`
    7. On Start Menu, search environment variables -> `Edit Environment Variables`.
        7.1. Here at the bottom of the popup, there will be a button `Environment Variables`. Click it.
        7.2. Here, in the top section, select the `Path` row
        7.3. After selecting `Paath` row, click `Edit`
        7.4. On the new screen select `New`
        7.5. Paste the previously copied path in the textbox that appears
        7.6. Hit ok ok ok
    8. Open cmd and type `flutter`. If it doesn't show an error then you're done.

**Steps**:
1. Open a terminal inside `fronted_flutter`
2. Type `flutter run`. If you have an emulator running, or your phone connected to the PC with USB, then the app should launch in a short time on your phone.
3. Once the app is running, navigate to `Settings` from the left sidebar.
4. Set the server ip here: example: `http://192.168.x.x:5050`
5. Now everything is set

**Note**: Currently there is no frontend option to add users. However there is a backend endpoint for it.
1. Go to the swagger page at `http://192.168.x.x:5050/apidocs`.
2. Use the endpoint `/api/user/create_user` to create a user.
3. Write the username for this user in the `Settings` page.
4. Now you can use all the functionality iin the app without issues.