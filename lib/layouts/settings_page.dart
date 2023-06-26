import 'dart:async';

import 'package:birthday_reminder/helpers/notifications_registration.dart';
import 'package:birthday_reminder/layouts/notifications_settings.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? notificationsEnabled;
  bool? canSendNotifications;
  Timer? timer;
  Timer? timer2;

  @override
  void initState() {
    updateNotificationsEnabled();
    timer = Timer(const Duration(seconds: 1), updateNotificationsEnabled);
    timer2 = Timer(const Duration(seconds: 5), updateNotificationsEnabled);

    NotificationsRegistration.instance.canSendNotifications().then((value) {
      setState(() {
        canSendNotifications = value;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  void updateNotificationsEnabled() {
    NotificationsRegistration.instance.notificationsEnabled().then((value) {
      setState(() {
        notificationsEnabled = value;
      });
    });
  }

  Future<bool> toggle(bool value) async {
    bool result = false;

    timer?.cancel();
    timer2?.cancel();

    if (value) {
      result = await NotificationsRegistration.instance.enableNotifications();
    } else {
      result = await NotificationsRegistration.instance.disableNotifications();
    }

    if (result) {
      setState(() {
        notificationsEnabled = value;
      });
    }

    return result;
  }

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
        SettingsSection(title: Text(strings.account), tiles: <SettingsTile>[
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
          SettingsTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: Text(strings.delete_all_my_data),
            onPressed: (context) {
              launchUrl(Uri.parse(
                  '${strings.request_delete_data_url}${user!.email ?? '<please put here your email>'}.\n\n${user.uid.substring(user.uid.length - 6)}.\n'));
            },
          ),
        ]),
        SettingsSection(title: Text(strings.notifications), tiles: [
          SettingsTile.switchTile(
            leading: Icon(
              notificationsEnabled == true
                  ? Icons.notifications_active_rounded
                  : (notificationsEnabled == null ? Icons.notifications_rounded : Icons.notifications_off_rounded),
            ),
            initialValue: canSendNotifications == true && notificationsEnabled == null || notificationsEnabled == true,
            onToggle: (canSendNotifications != null && notificationsEnabled != null) ? toggle : null,
            title: Text(strings.notifications),
          ),
          SettingsTile.navigation(
            leading: Icon(Icons.access_time),
            enabled: notificationsEnabled == true,
            title: Text(strings.configure_notifications),
            description: Text(strings.configure_notifications_description),
            onPressed: notificationsEnabled == true
                ? (context) {
                    Navigator.of(context).push(
                      CupertinoDialogRoute(builder: (context) => const NotificationsSettingsPage(), context: context),
                    );
                  }
                : null,
          ),
        ]),
        SettingsSection(
          title: const Text("App"),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.share_rounded),
              title: Text(strings.share),
              onPressed: (context) {
                Share.share('https://birthday-remainder-app.web.app/');
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.privacy_tip_rounded),
              title: Text(strings.privacy_policy),
              onPressed: (context) {
                launchUrl(Uri.parse('https://birthday-remainder-app.web.app/privacy-policy'), mode: LaunchMode.externalApplication);
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.policy_rounded),
              title: Text(strings.privacy_policy),
              onPressed: (context) {
                launchUrl(Uri.parse('https://birthday-remainder-app.web.app/terms-of-use'), mode: LaunchMode.externalApplication);
              },
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.help),
              title: Text(strings.help_and_contact),
              onPressed: (context) {
                launchUrl(Uri.parse(strings.help_email_link), mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ],
    );
  }
}
