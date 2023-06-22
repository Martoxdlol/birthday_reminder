import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/layouts/birthday_view.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({
    super.key,
    required this.birthday,
  });

  final Birthday birthday;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);

    final nextBirthday = birthday.nextBirthday();

    final now = DateTime.now();

    String formatter = "EEEE dd, MMMM";

    if (nextBirthday.year != now.year) {
      formatter += " y";
    }

    final isToday = nextBirthday.day == now.day && nextBirthday.month == now.month && nextBirthday.year == now.year;

    final screenWidth = MediaQuery.of(context).size.width;

    final difference = birthday.durationToNextBirthday();

    final inDays = (difference.inMilliseconds / 1000 / 60 / 60 / 24).ceil();

    String label = "${strings.in_word} $inDays ${strings.days}";

    if (inDays == 1) {
      label = strings.tomorrow;
    }

    final Locale locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    return Card(
      child: InkWell(
        onTap: () {
          showBirthdayView(context, birthday: birthday);
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth - 201),
                child: Text(
                  birthday.personName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (birthday.nextAge() != null) ...[
                const SizedBox(
                  width: 8,
                ),
                const Icon(
                  Icons.cake,
                  color: Colors.black12,
                  size: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    birthday.nextAge().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black38),
                  ),
                ),
              ],
              const Expanded(child: SizedBox.shrink()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: isToday
                    ? [
                        Text(
                          strings.today,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ]
                    : [
                        Text(label),
                        Text(
                          DateFormat(formatter, languageCode).format(nextBirthday),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
