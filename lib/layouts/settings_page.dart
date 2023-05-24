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

    return SettingsList(
      sections: [
        SettingsSection(
          title: Text('Account'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.account_circle_rounded),
              onPressed: (context) {},
              title: Text(user?.displayName ?? user?.email ?? 'Anonymous'),
              value: Text(user?.email ?? ''),
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.exit_to_app_rounded),
              title: Text('Sign out'),
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
