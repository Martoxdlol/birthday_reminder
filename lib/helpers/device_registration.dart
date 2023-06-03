import 'package:birthday_reminder/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class DeviceRegistrationManager {
  Future<void> registerDevice() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final tokensCollection = FirebaseFirestore.instance.collection('fcm_tokens');

    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      throw Exception('FCM token is null');
    }

    final tokenDocRef = tokensCollection.doc(fcmToken);

    final locale = obtainLocale();

    if (kDebugMode) {
      print("FCM token: $fcmToken");
    }

    await tokenDocRef.set({
      'user_id': user.uid,
      'updated_at': DateTime.now(),
      'lang': locale.languageCode,
      'country': locale.countryCode,
      'enable_notifications': true,
    });
  }

  Future<void> unregisterDevice() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final tokensCollection = FirebaseFirestore.instance.collection('fcm_tokens');

    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      throw Exception('FCM token is null');
    }

    final tokenDocRef = tokensCollection.doc(fcmToken);

    await tokenDocRef.delete();
  }

  static final instance = DeviceRegistrationManager();
}

// POST TO: https://fcm.googleapis.com/fcm/send

// HEADERS:
// Bearer ..server_token...

// {
//   "to":"...fcm_token...",
//   "notification":{
//     "title":"New birthday!",
//     "body":"28 years old today!"
//   },
//   "data" : {
//     "birthday_id" : "...",
//   }
// }