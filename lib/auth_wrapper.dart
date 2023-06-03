import 'dart:async';

import 'package:birthday_reminder/helpers/device_registration.dart';
import 'package:birthday_reminder/pages/home.dart';
import 'package:birthday_reminder/pages/login.dart';
import 'package:birthday_reminder/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppAuthWrapper extends StatefulWidget {
  const AppAuthWrapper({super.key});

  @override
  State<AppAuthWrapper> createState() => _AppAuthWrapperState();
}

class _AppAuthWrapperState extends State<AppAuthWrapper> {
  late Stream<User?> stream;

  User? lastUser;

  void listener(User? user) async {
    final preventAskingPermissionOnWeb = kIsWeb && !(await getCanSendNotifications());
    if (preventAskingPermissionOnWeb) return;

    if (user == null) {
      await DeviceRegistrationManager().unregisterDevice();
    } else if (lastUser == null) {
      await DeviceRegistrationManager().registerDevice();
    } else if (lastUser != null && lastUser!.uid != user.uid) {
      await DeviceRegistrationManager().unregisterDevice();
      await DeviceRegistrationManager().registerDevice();
    }
    lastUser = user;
  }

  StreamSubscription<User?>? subscription;

  @override
  void initState() {
    stream = FirebaseAuth.instance.authStateChanges();
    subscription = stream.listen(listener);
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: stream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          // User is signed in.
          return const Home();
        } else {
          // User is not signed in.
          return const LoginPage();
        }
      },
    );
  }
}
