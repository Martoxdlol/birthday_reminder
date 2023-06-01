import 'package:birthday_reminder/util.dart';
import 'package:birthday_reminder/widgets/birthday_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BirthdaysList extends StatelessWidget {
  const BirthdaysList({
    super.key,
    required this.filter,
  });
  final String filter;

  @override
  Widget build(BuildContext context) {
    final stream =
        FirebaseFirestore.instance.collection('birthdays').where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final birthdays = snapshot.data?.docs
            .map((e) => {
                  ...e.data(),
                  "id": e.id,
                })
            .toList()
            .where((element) {
          if (filter == '') return true;

          final name = removeDiacritics(element['personName'] as String).toLowerCase();
          final filterLower = removeDiacritics(filter.toLowerCase()).trim();

          if (name.contains(filterLower)) {
            return true;
          }

          return false;
        }).toList();
        birthdays?.sort((a, b) {
          final now = DateTime.now();
          final currentYear = now.year;

          if (a['birth'] == null || b['birth'] == null) {
            return 0;
          }

          if (a['birth'] is! Timestamp || b['birth'] is! Timestamp) {
            return 0;
          }

          final aBirth = (a['birth'] as Timestamp).toDate();
          final bBirth = (b['birth'] as Timestamp).toDate();

          final aMonth = aBirth.month;
          final bMonth = bBirth.month;

          final aDay = aBirth.day;
          final bDay = bBirth.day;

          final aCurrent = DateTime(currentYear, aMonth, aDay);
          final bCurrent = DateTime(currentYear, bMonth, bDay);

          if (now.day == aDay && now.month == aMonth && now.day == bDay && now.month == bMonth) {
            return 0;
          }

          if (now.day == aDay && now.month == aMonth) {
            return -1;
          }

          if (now.day == bDay && now.month == bMonth) {
            return 1;
          }

          if (now.isBefore(aCurrent) && now.isAfter(bCurrent)) {
            return -1;
          }

          if (now.isBefore(bCurrent) && now.isAfter(aCurrent)) {
            return 1;
          }

          return aCurrent.compareTo(bCurrent);
        });

        if (snapshot.hasError) {
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
            final personName = birthdays[index]['personName'];

            if (birthdays[index]['birth'] is! Timestamp) {
              return const SizedBox.shrink();
            }

            Timestamp birthTimestamp = birthdays[index]['birth'];
            final birth = birthTimestamp.toDate();

            bool noYear = false;

            if (birthdays[index]['noYear'] is bool) {
              noYear = birthdays[index]['noYear'] as bool;
            }

            final id = birthdays[index]['id'] as String;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: BirthdayCard(
                personName: personName,
                date: birth,
                noYear: noYear,
                notes: birthdays[index]['notes'] as String,
                id: id,
              ),
            );
          },
        );
      },
    );
  }
}
