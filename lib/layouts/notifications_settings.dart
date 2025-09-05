import 'package:birthday_reminder/helpers/notifications_registration.dart';
import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  DailyUpdateTimeOption? notificationTime;
  List<DailyUpdateTimeOption>? options;

  void updateData() {
    NotificationsRegistration.instance.getDailyUpdateTime().then((value) {
      if (!mounted) return;
      setState(() {
        notificationTime = value;
      });
    });

    NotificationsRegistration.instance
        .getDailyUpdateTimeOptions()
        .then((value) {
      if (!mounted) return;
      setState(() {
        options = value;
      });
    });
  }

  @override
  void initState() {
    updateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Horario notificaciones"),
      ),
      body: ListView.builder(
        itemCount: options?.length ?? 0,
        itemBuilder: (context, index) => RadioListTile(
          title: Text(options![index].label),
          value: options![index],
          groupValue: notificationTime,
          onChanged: (value) {
            if (value == null) return;
            NotificationsRegistration.instance
                .setDailyUpdateTime(value)
                .then((value) => updateData());
          },
        ),
      ),
    );
  }
}
