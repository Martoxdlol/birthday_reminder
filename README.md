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

## Util notes

The app is using [flutter internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

To generate dart lib use `flutter gen-l10n`

To generate icons use `flutter pub run flutter_launcher_icons`