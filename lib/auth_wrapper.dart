import 'dart:async';

import 'package:birthday_reminder/helpers/notifications_registration.dart';
import 'package:birthday_reminder/pages/home.dart';
import 'package:birthday_reminder/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuthWrapper extends StatefulWidget {
  const AppAuthWrapper({super.key});

  @override
  State<AppAuthWrapper> createState() => _AppAuthWrapperState();
}

class _AppAuthWrapperState extends State<AppAuthWrapper> {
  late Stream<User?> stream;

  void listener(User? user) async {
    await NotificationsRegistration.instance.updateUserInformation();
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
