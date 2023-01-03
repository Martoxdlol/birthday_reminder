import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('birthdays')
            .where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get()
            .asStream(),
        builder: (context, snapshot) {
          final birthdays = snapshot.data?.docs.map((e) => e.data()).toList();

          if (snapshot.hasError) {
            return Text("ERROR");
          }

          if (birthdays == null) {
            return Text("LOADING");
          }

          return ListView.builder(
            itemCount: birthdays.length,
            itemBuilder: (context, index) {
              return Text(birthdays[index]['personName']);
            },
          );
        },
      ),
    );
  }
}
