import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/widgets/birthday_card.dart';
import 'package:flutter/material.dart';

class BirthdaysListView extends StatefulWidget {
  const BirthdaysListView({
    super.key,
    required this.stream,
    required this.insertChildren,
  });
  final Stream<List<Birthday>> stream;

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

        return ListView.builder(
          itemCount: birthdays.length + widget.insertChildren.length,
          itemBuilder: (context, index) {
            final birthdayIndex = index - widget.insertChildren.length;

            if (index < widget.insertChildren.length) {
              return widget.insertChildren[index];
            }

            final birthday = birthdays[birthdayIndex];

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
