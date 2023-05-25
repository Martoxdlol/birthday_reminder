import 'package:birthday_reminder/layouts/birthday_view.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:flutter/material.dart';

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({
    super.key,
    required this.personName,
    required this.date,
    required this.noYear,
    required this.notes,
    required this.id,
  });

  final String personName;
  final DateTime date;
  final bool noYear;
  final String notes;
  final String id;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final strings = appStrings(context);

    final thisYear = now.year;

    final nextBirthday = DateTime(
      thisYear,
      date.month,
      date.day,
    );

    final difference = nextBirthday.difference(now);

    var diff = difference.inDays;

    if (diff < 0) {
      diff = 365 + diff;
    }

    return Card(
      child: InkWell(
        onTap: () {
          showBirthdayView(context, date: nextBirthday, notes: notes, name: personName, noYear: noYear, id: id);
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(personName),
              Expanded(child: SizedBox.shrink()),
              Text("${strings.in_word} $diff ${strings.days}"),
            ],
          ),
        ),
      ),
    );
  }
}
