# Birthday Reminder | Recordador de Cumpleaños

This is a Flutter app that it is used as a calendar for people birthdays.
It sends you periodic notifications with future and current birthdays so you don't miss
saying "Happy Birthday" to your firends/family/whatever.

[**View on Play Store**](https://play.google.com/store/apps/details?id=net.tomascichero.birthdayremainder)

## Setup dev environment

Requirements:

- [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) installed
- [Firebase cli](https://firebase.google.com/docs/cli) installed
- [FlutterFire cli](https://firebase.google.com/docs/flutter/setup?platform=android) installed
- Create or have a created firebase project.

Steps

- Clone repository
- Open a terminal inside the project
- Run `dart pub get`
- Run `firebase use --add` and choose your project and use `default` as alias name
- Set configure SHA hash on your firebase project (see below)
- **Optional** Change package name. You can use [change_app_package_name](https://pub.dev/packages/change_app_package_name) package. ([More info here](https://stackoverflow.com/questions/51534616/how-to-change-package-name-in-flutter)).
- Change `web/.well-known/assetlinks.json` to your SHA hash (see below) and your package name 
- run `flutterfire configure` and confirm for all platforms

Now you can run the app with flutter support using `flutter run`

## Get signing SHA hash

**On Windows**:

- In command prompt: `keytool -list -v -keystore %USERPROFILE%/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
- In Powershell: `.\keytool -list -v -keystore $env:USERPROFILE/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

**On mac/linux**:

- In the terminal: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

**possible keytool paths in windows**:

- C:\Program Files\Android\Android Studio\jbr\bin
- C:\Program Files\Android\Android Studio\jre\bin
- C:\Program Files\Java\jdk-19\bin
- C:\Program Files\Java\jdk-VERSION\bin

### Set SHA into your Firebase project

Go to Firebase: project settings > your apps > choose android app and add signature SHA

## Setup Cloud Functions (for scheduling notifications)

You need to enable billing on your Google Cloud project to use Cloud Functions.

You don't need to setup credentials, firebase emulators does it for you.

**Just in case** [Service Accounts pane](https://console.cloud.google.com/iam-admin/serviceaccounts)

To start local emulator run `cd functions/ && npm run serve`

To run the function that sends notifications to all users locally start the local emulator and open on your browser `http://127.0.0.1:5001/birthday-remainder-app/us-central1/manually`. Note: the port may differ (may be different than 5001). This will send notification. Be careful, it will use the production database.

## Internationalization (multiple languages)

The app is using [flutter internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

To generate dart lib use `flutter gen-l10n`

To generate icons use `flutter pub run flutter_launcher_icons`

## Build app

### Android

Run `flutter build apk` or `flutter build appbundle`

### Web

You must have **node js** and **npm** installed

Run `npm run build` (see package.json)

Run `firebase deploy --only hosting` to deploy to firebase hosting (only web app, not functions or database rules)

Make sure to change the `web/.well-known/assetlinks.json` file to your SHA hash and your package name and other links in the web page relating to your app hosting url.

## Deploy app to firebase

Just run in a CMD or terminal `npm run deploy` or do it manually by running `firebase deploy`

Note: if you are using powershell and it doesn't work, try with CMD (`cmd.exe` inside the powershell terminal).
