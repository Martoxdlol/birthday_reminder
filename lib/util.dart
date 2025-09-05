import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:universal_html/html.dart" as html;

String removeDiacritics(String str) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

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
    html.window.document
        .querySelector('html')
        ?.setAttribute('lang', locale.languageCode);
  } catch (e) {
    if (kDebugMode) print(e);
  }
}

String extractInitials(String fullName) {
  if (fullName.isEmpty) {
    return '';
  }

  final List<String> nameParts = fullName.trim().split(' ');
  while (nameParts.length > 2) {
    nameParts.removeLast();
  }
  final StringBuffer initialsBuffer = StringBuffer();

  for (final String namePart in nameParts) {
    if (namePart.isNotEmpty) {
      final char = namePart.characters.first;
      //match if is special symbol
      if (RegExp('[!@#\$%^&*(),.?":{}|<>]').hasMatch(char)) {
        continue;
      }
      initialsBuffer.write(char.toUpperCase());
      if (!RegExp('[a-zA-Z]').hasMatch(char)) {
        break;
      }
    }
  }

  return initialsBuffer.toString();
}

class ColorPair {
  final Color background;
  final Color foreground;

  ColorPair(this.background, this.foreground);
}

ColorPair generateRandomColor(String fullName) {
  int seed = 0;
  for (int i = 0; i < fullName.length; i++) {
    seed += fullName.codeUnitAt(i);
  }

  final Random random = Random(seed);

  // Generate random HSL values
  final double hue = random.nextDouble() * 360.0;
  final double saturation = 0.5 + random.nextDouble() * 0.5;
  final double lightness = 0.4 + random.nextDouble() * 0.2;

  final Color background = HSLColor.fromAHSL(1.0, hue, saturation, lightness)
      .toColor()
      .withOpacity(0.7);

  // Calculate contrast color for foreground text
  const double contrastThreshold = 128;
  final double luminance = background.computeLuminance();
  final Color foreground =
      luminance > contrastThreshold ? Colors.black : Colors.white;

  return ColorPair(background, foreground);
}
