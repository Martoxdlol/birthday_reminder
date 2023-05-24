import 'package:flutter/material.dart';

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({
    super.key,
    required this.personName,
    required this.date,
  });

  final String personName;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final thisYear = now.year;

    final nextBirthday = DateTime(
      thisYear,
      date.month,
      date.day,
    );

    final difference = nextBirthday.difference(now);

    return Card(
      child: InkWell(
        onTap: () {},
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(personName),
              Expanded(child: SizedBox.shrink()),
              Text("En ${difference.inDays} días"),
            ],
          ),
        ),
      ),
    );
  }
}
