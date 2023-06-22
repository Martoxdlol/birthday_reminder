import 'package:birthday_reminder/auth_wrapper.dart';
import 'package:birthday_reminder/firebase_options.dart';
import 'package:birthday_reminder/js_bindings.dart';
import 'package:birthday_reminder/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    if (kIsWeb) {
      appFinishedLoading();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = obtainLocale();

    final strings = lookupAppLocalizations(locale);

    if (kIsWeb) {
      setWebLocale(locale);
    }

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
