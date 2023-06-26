import 'package:birthday_reminder/data.dart';
import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/widgets/birthday_card.dart';
import 'package:flutter/material.dart';

class BirthdaysListView extends StatefulWidget {
  const BirthdaysListView({
    super.key,
    required this.stream,
    required this.insertChildren,
    this.filter,
  });
  final Stream<List<Birthday>> stream;

  final String? filter;

  final List<Widget> insertChildren;

  @override
  State<BirthdaysListView> createState() => _BirthdaysListViewState();
}

class _BirthdaysListViewState extends State<BirthdaysListView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, snapshot) {
        final birthdays = snapshot.data;

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

        final filteredBirthdays = widget.filter == null ? birthdays : filterBirthdays(birthdays, widget.filter!).toList();

        return ListView.builder(
          itemCount: filteredBirthdays.length + widget.insertChildren.length,
          itemBuilder: (context, index) {
            final birthdayIndex = index - widget.insertChildren.length;

            if (index < widget.insertChildren.length) {
              return widget.insertChildren[index];
            }

            final birthday = filteredBirthdays[birthdayIndex];

            return BirthdayCard(birthday: birthday);
          },
        );
      },
    );
  }
}
