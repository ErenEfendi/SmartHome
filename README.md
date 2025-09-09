# Capstone Project about SmartHome Mobile App


## Firebase Setup

This project uses Firebase. The files `firebase_options.dart`, `GoogleService-Info.plist`, and `google-services.json` are not shared for security reasons.

You need to create an Android application in the Firebase Console and download the corresponding file yourself.

You also need to register an iOS application in the Firebase Console and download your own `.plist` file.


To integrate Firebase into your project:

1. [Install the FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).
2. Run the following command:
   ```bash
   flutterfire configure


## Firebase Structure

### Realtime Database

Below is an example of the Firebase Realtime Database structure used in this project:

![image](https://github.com/user-attachments/assets/a8d77085-b416-4a9a-bd7b-60a0cf268aa7)
![image](https://github.com/user-attachments/assets/146544fd-c868-4b31-b2e6-c4bff44bc201)


### Firebase Messaging
Firebase Cloud Messaging (FCM) is used in this project.

![image](https://github.com/user-attachments/assets/55d66f54-c9c5-4234-9254-014dc7ef612a)


for the web service for gasLevel alert I used render with a self-ping script. You can find the script in the webservice file.

<img width="2482" height="992" alt="image" src="https://github.com/user-attachments/assets/3cc5c0d3-24cf-4e10-84ca-f8454dfd96bf" />
