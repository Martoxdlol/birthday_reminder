import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:birthday_reminder/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:intl/intl.dart';

class NotificationsRegistration {
  Future<bool> canSendNotifications() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getFcmToken() async {
    if (!await canSendNotifications()) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) print("Cannot get FCM token. $e");
    }
    return null;
  }

  Future<bool> requestNotificationsPermission() async {
    if (await canSendNotifications()) return true;

    final result = await FirebaseMessaging.instance.requestPermission();

    if (result.authorizationStatus == AuthorizationStatus.authorized || result.authorizationStatus == AuthorizationStatus.provisional) {
      return true;
    }

    if (kIsWeb) {
      return false;
    }

    final task = Completer<bool>();
    bool isCompleted = false;

    final timer = Timer(const Duration(seconds: 12), () {
      isCompleted = true;
      task.complete(false);
    });

    AppSettings.openNotificationSettings(callback: () async {
      if (isCompleted) return;
      timer.cancel();
      task.complete(await canSendNotifications());
    });

    return await task.future;
  }

  CollectionReference<Map<String, dynamic>> get tokensCollection => FirebaseFirestore.instance.collection('fcm_tokens');

  Future<bool> enableNotifications() async {
    if (!await requestNotificationsPermission()) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final fcmToken = await getFcmToken();
    if (fcmToken == null) {
      return false;
    }

    try {
      await _upsertFirebaseDoc(fcmToken, notificationsEnabled: true);
    } catch (e) {
      if (kDebugMode) print(e);
      return false;
    }

    return true;
  }

  Future<bool> disableNotifications() async {
    final fcmToken = await getFcmToken();
    if (fcmToken == null) return false;

    try {
      await _upsertFirebaseDoc(fcmToken, notificationsEnabled: false);
    } catch (e) {
      if (kDebugMode) print(e);
      return false;
    }

    return true;
  }

  Future<void> updateUserInformation() async {
    final fcmToken = await getFcmToken();
    if (fcmToken == null) return;

    await _upsertFirebaseDoc(fcmToken);
  }

  Future<void> _upsertFirebaseDoc(
    String token, {
    bool? notificationsEnabled,
    DailyUpdateTimeOption? dailyUpdateTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final locale = obtainLocale();

    final tokenDocRef = tokensCollection.doc(token);

    final body = {
      'user_id': user.uid,
      'updated_at': DateTime.now(),
      'lang': locale.languageCode,
      'country': locale.countryCode,
      'timezone': DateTime.now().timeZoneOffset.inHours,
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
    };

    if (notificationsEnabled != null) {
      body['enable_notifications'] = notificationsEnabled;
    }

    if (dailyUpdateTime != null) {
      body['daily_update_time'] = dailyUpdateTime.label;
    }

    try {
      await tokenDocRef.set(body, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<Map<String, dynamic>?> getFirebaseDocData(String token) async {
    final tokenDocRef = tokensCollection.doc(token);

    final doc = await tokenDocRef.get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<bool> notificationsEnabled() async {
    if (!await canSendNotifications()) return false;

    final fcmToken = await getFcmToken();
    if (fcmToken == null) return false;

    final data = await getFirebaseDocData(fcmToken);

    if (data == null) return false;

    if (data['enable_notifications'] == null) return false;

    return data['enable_notifications'] as bool;
  }

  Future<List<DailyUpdateTimeOption>> getDailyUpdateTimeOptions() async {
    if (FirebaseRemoteConfig.instance.lastFetchStatus != RemoteConfigFetchStatus.success) {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    }

    final rawTimeOptions = jsonDecode(FirebaseRemoteConfig.instance.getString('daily_update_time')) as List<dynamic>? ?? [];

    final asListString = rawTimeOptions.map((e) => e.toString()).toList();

    return asListString.map(DailyUpdateTimeOption.fromTimeString).toList();
  }

  Future<DailyUpdateTimeOption> getDefaultDailyUpdateTime() async {
    if (FirebaseRemoteConfig.instance.lastFetchStatus != RemoteConfigFetchStatus.success) {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
    }

    final rawTime = FirebaseRemoteConfig.instance.getString('default_daily_update_time');

    return DailyUpdateTimeOption.fromTimeString(rawTime);
  }

  Future<DailyUpdateTimeOption> getDailyUpdateTime() async {
    final fcmToken = await getFcmToken();
    if (fcmToken == null) return getDefaultDailyUpdateTime();

    final data = await getFirebaseDocData(fcmToken);

    if (data == null) return await getDefaultDailyUpdateTime();

    if (data['daily_update_time'] == null) return await getDefaultDailyUpdateTime();

    return DailyUpdateTimeOption.fromTimeString(data['daily_update_time'] as String);
  }

  Future<void> setDailyUpdateTime(DailyUpdateTimeOption time) async {
    final fcmToken = await getFcmToken();
    if (fcmToken == null) return;

    await _upsertFirebaseDoc(fcmToken, dailyUpdateTime: time);
  }

  static final instance = NotificationsRegistration();
}

class DailyUpdateTimeOption {
  final int hours;
  final int minutes;
  final int seconds;

  const DailyUpdateTimeOption(this.hours, this.minutes, this.seconds);

  factory DailyUpdateTimeOption.fromTimeString(String timeString) {
    final splitted = timeString.split(':');

    final hours = int.parse(splitted[0]);
    final minutes = int.parse(splitted[1]);
    final seconds = splitted.length == 3 ? int.parse(splitted[2]) : 0;

    return DailyUpdateTimeOption(hours, minutes, seconds);
  }

  String get label {
    DateTime time = DateTime.now().copyWith(hour: hours, minute: minutes, second: seconds);

    if (seconds == 0) {
      return DateFormat('HH:mm').format(time);
    }
    return DateFormat('HH:mm:ss').format(time);
  }

  // set equal operator and hash
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyUpdateTimeOption && (other.minutes == minutes && other.seconds == seconds && other.hours == hours);
  }

  @override
  int get hashCode => label.hashCode;
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