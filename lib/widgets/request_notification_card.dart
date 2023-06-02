import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestNotificationCard extends StatefulWidget {
  const RequestNotificationCard({super.key});

  @override
  State<RequestNotificationCard> createState() => _RequestNotificationCardState();
}

class _RequestNotificationCardState extends State<RequestNotificationCard> {
  bool show = false;

  @override
  void initState() {
    FirebaseMessaging.instance.getNotificationSettings().then((value) {
      if (value.authorizationStatus == AuthorizationStatus.authorized) {
        setState(() {
          show = false;
        });
      } else {
        SharedPreferences.getInstance().then((prefs) {
          if (prefs.getBool('prefer_no_notifications') ?? false) return;
          setState(() {
            show = true;
          });
        });
      }
    });

    super.initState();
  }

  Future<void> cancel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('prefer_no_notifications', true);

    setState(() {
      show = false;
    });
  }

  void accept() {
    setState(() {
      show = false;
    });
    FirebaseMessaging.instance.requestPermission().then((value) {
      if (value.authorizationStatus != AuthorizationStatus.authorized) {
        AppSettings.openNotificationSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textTheme = theme.textTheme.apply(bodyColor: Colors.white);

    final appliedTheme = theme.copyWith(
      textTheme: textTheme,
    );

    if (!show) return const SizedBox.shrink();

    return Theme(
      data: appliedTheme,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          color: Colors.teal,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Activar notificaciones",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ]),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Te avisaremos de los cumpleaños del día y de la semana",
                    style: textTheme.bodyLarge,
                  ),
                ),
                TextButtonTheme(
                  data: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: cancel, child: Text("No, gracias")),
                      TextButton(onPressed: accept, child: Text("Activar")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
