import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/layouts/birthday_view.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:birthday_reminder/util.dart';
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

    final isToday = nextBirthday.day == now.day &&
        nextBirthday.month == now.month &&
        nextBirthday.year == now.year;

    // final screenWidth = MediaQuery.of(context).size.width;

    final difference = birthday.durationToNextBirthday();

    final inDays = (difference.inMilliseconds / 1000 / 60 / 60 / 24).ceil();

    String label = "${strings.in_word} $inDays ${strings.days}";

    if (inDays == 1) {
      label = strings.tomorrow;
    }

    final Locale locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    final nextAge = birthday.nextAge();

    String? nextAgeLabel;

    if (nextAge != null) {
      nextAgeLabel = "${nextAge.toString()} ${strings.years}";
    }

    final remainingTimeWidget = isToday
        ? Text(
            strings.today,
            style: Theme.of(context).textTheme.labelLarge,
          )
        : Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          );

    final colors = generateRandomColor(birthday.personName);

    final nextBirthdayLabelTextStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(overflow: TextOverflow.ellipsis);
    final nextBirthdayLabel = Row(
      children: [
        Text(
          DateFormat(formatter, languageCode).format(nextBirthday),
          style: nextBirthdayLabelTextStyle,
        ),
        if (nextAgeLabel != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.arrow_forward,
              size: 8,
              color: nextBirthdayLabelTextStyle?.color,
            ),
          ),
          Text(
            nextAgeLabel,
            style: nextBirthdayLabelTextStyle,
          )
        ]
      ],
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        child: Text(extractInitials(birthday.personName)),
      ),
      title: Text(
        birthday.personName,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: remainingTimeWidget,
      subtitle: nextBirthdayLabel,
      onTap: () {
        showBirthdayView(context, birthday: birthday);
      },
    );
  }
}
