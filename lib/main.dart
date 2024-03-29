import 'package:birthday_reminder/auth_wrapper.dart';
import 'package:birthday_reminder/firebase_options.dart';
import 'package:birthday_reminder/js_bindings/js_ignore_bindings.dart'
    if (dart.library.html) 'package:birthday_reminder/js_bindings/js_bindings.dart';
import 'package:birthday_reminder/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:app_links/app_links.dart';

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
  late AppLinks _appLinks;

  @override
  void initState() {
    if (!kIsWeb) {
      initDeepLinks();
    }
    if (kIsWeb) {
      appFinishedLoading();
    }
    super.initState();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      navigateToUri(appLink);
    }

    _appLinks.uriLinkStream.listen(navigateToUri);
  }

  void navigateToUri(Uri uri) {
    final params = uri.queryParameters;
    final segments = uri.pathSegments;
    // TODO: Implement shared link handling
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
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => const AppAuthWrapper(),
      ),
    );
  }
}
