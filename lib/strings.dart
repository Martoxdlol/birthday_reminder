import 'l10n/app_localizations_en.dart';
import 'package:flutter/cupertino.dart';
import 'l10n/app_localizations.dart';

AppLocalizations appStrings(BuildContext context) {
  return AppLocalizations.of(context) ?? AppLocalizationsEn();
}
