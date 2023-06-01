import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/util.dart';
import 'package:birthday_reminder/widgets/birthday_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BirthdaysListView extends StatefulWidget {
  const BirthdaysListView({
    super.key,
    required this.filter,
  });
  final String filter;

  @override
  State<BirthdaysListView> createState() => _BirthdaysListViewState();
}

class _BirthdaysListViewState extends State<BirthdaysListView> {
  Stream<Iterable<Birthday>> streamMapper(Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
    return stream.map(
      (event) => event.docs.map((doc) {
        return Birthday.fromMap(
          doc.data(),
          id: doc.id,
        );
      }),
    );
  }

  Stream<Iterable<Birthday>> streamFilter(Stream<Iterable<Birthday>> stream) {
    final filterLower = removeDiacritics(widget.filter.toLowerCase()).trim();

    return stream.map(
      (birthdays) => birthdays.where((birthday) {
        return removeDiacritics(birthday.personName).toLowerCase().contains(filterLower);
      }),
    );
  }

  Stream<List<Birthday>> streamSort(Stream<Iterable<Birthday>> stream) {
    return stream.map((birthdays) {
      final list = birthdays.toList();
      list.sort((a, b) => a.daysToNextBirthday().compareTo(b.daysToNextBirthday()));
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final originalStream =
        FirebaseFirestore.instance.collection('birthdays').where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();

    final birthdaysStraem = streamMapper(originalStream);
    final unfilteredStream = streamFilter(birthdaysStraem);
    final stream = streamSort(unfilteredStream);

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final birthdays = snapshot.data;

        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          );
        }

        if (birthdays == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: birthdays.length,
          itemBuilder: (context, index) {
            final birthday = birthdays[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: BirthdayCard(
                birthday: birthday,
              ),
            );
          },
        );
      },
    );
  }
}
