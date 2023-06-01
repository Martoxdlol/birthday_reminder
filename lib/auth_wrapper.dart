import 'package:birthday_reminder/pages/home.dart';
import 'package:birthday_reminder/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuthWrapper extends StatelessWidget {
  const AppAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
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
