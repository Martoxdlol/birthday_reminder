import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

AppLocalizations appStrings(BuildContext context) {
  return AppLocalizations.of(context) ?? AppLocalizationsEn();
}
