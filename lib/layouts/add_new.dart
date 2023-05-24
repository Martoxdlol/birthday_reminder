import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewBirthday extends StatefulWidget {
  const NewBirthday({super.key});

  @override
  State<NewBirthday> createState() => _NewBirthdayState();
}

class _NewBirthdayState extends State<NewBirthday> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Text("New birthday");
  }
}
