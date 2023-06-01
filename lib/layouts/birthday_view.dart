import 'package:birthday_reminder/layouts/add_new.dart';
import 'package:birthday_reminder/layouts/bottom_popup.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:birthday_reminder/widgets/confirm_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BirthdayView extends StatefulWidget {
  const BirthdayView({
    super.key,
    required this.name,
    required this.date,
    required this.notes,
    required this.noYear,
    required this.id,
  });

  final String name;
  final DateTime date;
  final String notes;
  final bool noYear;
  final String id;

  @override
  _BirthdayViewState createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> {
  NewBirthdayData? data;

  void setInitialData() {
    print(widget.noYear);
    data = NewBirthdayData(
        name: widget.name, day: widget.date.day, month: widget.date.month, year: widget.noYear ? 0 : widget.date.year, notes: widget.notes);
  }

  @override
  void initState() {
    setInitialData();
    super.initState();
  }

  void resetData() {
    setState(() {
      setInitialData();
    });
  }

  bool get somethingChanged {
    final year = widget.noYear ? 0 : widget.date.year;
    if (widget.name != data?.name) return true;
    if (widget.date.day != data?.day) return true;
    if (widget.date.month != data?.month) return true;
    if (year != data?.year) return true;
    if (widget.notes != data?.notes) return true;
    return false;
  }

  Future<void> save() async {
    final data = this.data;
    if (data == null) return;

    await FirebaseFirestore.instance.collection('birthdays').doc(widget.id).update({
      "birth": DateTime(data.year, data.month, data.day),
      "noYear": data.year == 0,
      "notes": data.notes,
      "owner": FirebaseAuth.instance.currentUser!.uid,
      "personName": data.name,
      "app_version": "2.0.0",
      "updated_at": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return WillPopScope(
      onWillPop: () async {
        if (somethingChanged) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(somethingChanged ? strings.editing : (data?.name ?? widget.name)),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await confirm(
                  context,
                  onInput: (result) {},
                  title: Text(strings.are_you_sure),
                  content: Text("Se eliminará el cumpleaños de ${data?.name ?? widget.name}."),
                );

                if (result) {
                  FirebaseFirestore.instance.collection('birthdays').doc(widget.id).delete();
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ],
          leading: somethingChanged ? const Icon(Icons.edit) : null,
        ),
        primary: true,
        body: data != null
            ? NewBirthday(
                data: data!,
                onDataChange: (data) {
                  setState(() {
                    this.data = data;
                  });
                },
              )
            : null,
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (i) {
            if (somethingChanged) {
              if (i == 0) {
                resetData();
              } else if (i == 1) {
                Navigator.of(context).pop();
                save().then((value) {}).catchError((error) {
                  confirm(context,
                      title: Text(strings.error_ocurred),
                      onInput: (result) {},
                      content: const Text("No se pudo guardar el cumpleaños. Intentelo mas tarde,"));
                });
              }
            } else {
              if (i == 0) {
                // Share
              } else if (i == 1) {
                Navigator.of(context).pop();
              }
            }
          },
          selectedIndex: somethingChanged ? 1 : 0,
          destinations: [
            NavigationDestination(
              icon: Icon(somethingChanged ? Icons.cancel : Icons.share),
              label: somethingChanged ? strings.cancel : strings.share,
            ),
            NavigationDestination(
              icon: Icon(somethingChanged ? Icons.save : Icons.close),
              label: somethingChanged ? strings.save : strings.close,
            ),
          ],
        ),
      ),
    );
  }
}

void showBirthdayView(
  BuildContext context, {
  required DateTime date,
  required String notes,
  required String name,
  required bool noYear,
  required String id,
}) {
  Navigator.of(context).push(
    BottomPopupRoute(
      height: 470,
      builder: (context) => BirthdayView(
        name: name,
        date: date,
        notes: notes,
        noYear: noYear,
        id: id,
      ),
    ),
  );
}
