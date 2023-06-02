import 'package:birthday_reminder/auth_wrapper.dart';
import 'package:birthday_reminder/firebase_options.dart';
import 'package:birthday_reminder/helpers/device_registration.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:universal_html/html.dart" as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorLang = kIsWeb ? (html.window?.navigator.language?.split('-') ?? ['en']) : [];
    Locale? locale = navigatorLang.length == 2 ? Locale(navigatorLang[0], navigatorLang[1]) : null;

    if (navigatorLang.length == 1) {
      locale = Locale(navigatorLang[0]);
    }

    if (locale != null) {
      html.window.document.querySelector('html')?.setAttribute('lang', locale.languageCode);
    }

    final strings = locale != null ? lookupAppLocalizations(locale) : appStrings(context);
    return MaterialApp(
      title: strings.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: const VisualDensity(horizontal: 2, vertical: 1),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Builder(
        builder: (context) => const AppAuthWrapper(),
      ),
    );
  }
}
