import 'package:birthday_reminder/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final strings = appStrings(context);

    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.android,
      lightTheme: const SettingsThemeData(settingsListBackground: Colors.transparent),
      darkTheme: const SettingsThemeData(settingsListBackground: Colors.transparent),
      sections: [
        SettingsSection(
          title: Text(strings.account),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.account_circle_rounded),
              onPressed: (context) {},
              title: Text(user?.displayName ?? user?.email ?? 'Anonymous'),
              value: Text(user?.email ?? ''),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.exit_to_app_rounded),
              title: Text(strings.sign_out),
              onPressed: (context) {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ],
    );
  }
}
