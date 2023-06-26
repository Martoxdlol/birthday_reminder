import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ShareModal extends StatelessWidget {
  const ShareModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
    );
  }
}

void showShareModal(BuildContext context, Birthday birthday) {
  final string = appStrings(context);
  if (string.localeName.startsWith('es')) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(birthday.birth);
    Share.share('El día $formattedDate es el cumpleaños de ${birthday.personName}');
  } else {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(birthday.birth);
    Share.share('The day $formattedDate is ${birthday.personName}\'s birthday');
  }

  return;

  // TODO: Actually implement this function
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ShareModal();
    },
  );
}
