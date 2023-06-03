import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:universal_html/html.dart" as html;

String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

const defaultLocale = Locale('en');

Locale obtainLocale() {
  if (kIsWeb) {
    return obtainWebLocale() ?? defaultLocale;
  }

  final platformLocale = Platform.localeName.split('.')[0];
  final splitted = platformLocale.split('_');

  return Locale(splitted[0], splitted.length == 2 ? splitted[1] : null);
}

Locale? obtainWebLocale() {
  if (!kIsWeb) return null;
  try {
    final fullLang = html.window.navigator.language;

    // ignore: unnecessary_null_comparison
    if (fullLang == null) {
      return null;
    }

    final splitted = fullLang.split('-');
    final lang = splitted[0];
    final country = splitted.length == 2 ? splitted[1] : null;

    return Locale(lang, country);
  } catch (e) {
    return null;
  }
}

void setWebLocale(Locale locale) {
  try {
    html.window.document.querySelector('html')?.setAttribute('lang', locale.languageCode);
  } catch (e) {
    if (kDebugMode) print(e);
  }
}

Future<bool> getCanSendNotifications() async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  return settings.authorizationStatus == AuthorizationStatus.authorized;
}
