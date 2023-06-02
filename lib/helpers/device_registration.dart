import 'package:birthday_reminder/helpers/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceRegistrationManager {
  Future<void> registerDevice() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final usersPreferencesCollection = FirebaseFirestore.instance.collection('users_preferences');
    final userPreferencesDocRef = usersPreferencesCollection.doc(user.uid);

    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      throw Exception('FCM token is null');
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userPreferencesFromFirebase = await transaction.get(userPreferencesDocRef);
      final data = userPreferencesFromFirebase.exists ? userPreferencesFromFirebase.data() : null;

      final preferences = data != null
          ? UserPreferences(
              fcmTokens: (data['fcm_tokens'] as List<dynamic>).map((e) => e.toString()).toList(), userId: userPreferencesFromFirebase.id)
          : UserPreferences(userId: user.uid, fcmTokens: [fcmToken]);

      final newData = {
        'fcm_tokens': preferences.fcmTokens,
        'updated_at': DateTime.now(),
        'created_at': data?['created_at'] ?? DateTime.now(),
      };

      if (data != null) {
        transaction.update(userPreferencesDocRef, newData);
      } else {
        transaction.set(userPreferencesDocRef, newData);
      }
    });
  }

  Future<void> unregisterDevice() async {}

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