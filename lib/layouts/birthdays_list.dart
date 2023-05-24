import 'package:birthday_reminder/widgets/birthday_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BirthdaysList extends StatelessWidget {
  const BirthdaysList({
    super.key,
    this.scrollController,
  });
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('birthdays').where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        final birthdays = snapshot.data?.docs.map((e) => e.data()).toList();

        if (snapshot.hasError) {
          return Text("ERROR");
        }

        if (birthdays == null) {
          return Text("LOADING");
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: birthdays.length,
          itemBuilder: (context, index) {
            final personName = birthdays[index]['personName'];
            Timestamp birthTimestamp = birthdays[index]['birth'];
            final birth = birthTimestamp.toDate();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: BirthdayCard(
                personName: personName,
                date: birth,
              ),
            );
          },
        );
      },
    );
  }
}
