import 'package:birthday_reminder/layouts/add_new.dart';
import 'package:birthday_reminder/layouts/birthdays_list.dart';
import 'package:birthday_reminder/layouts/settings_page.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:birthday_reminder/widgets/confirm_dialog.dart';
import 'package:birthday_reminder/widgets/search_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<int> indexes = [0];
  String filter = '';

  var addBirthdayData = NewBirthdayData(
    name: '',
    day: DateTime.now().day,
    month: DateTime.now().month,
    year: DateTime.now().year,
    notes: '',
  );

  Future<void> saveBirthday() async {
    final date = DateTime(
      addBirthdayData.year,
      addBirthdayData.month,
      addBirthdayData.day,
    );

    if (date.month != addBirthdayData.month) {
      return;
    }

    if (addBirthdayData.name.trim() == '') return;

    setState(() {
      indexes.removeLast();
      if (indexes.last != 0) indexes.add(0);
    });

    try {
      await FirebaseFirestore.instance.collection('birthdays').add({
        "birth": date,
        "noYear": addBirthdayData.year == 0,
        "notes": addBirthdayData.notes,
        "owner": FirebaseAuth.instance.currentUser!.uid,
        "personName": addBirthdayData.name,
        "app_version": "2.0.0",
        "created_at": DateTime.now(),
        "updated_at": DateTime.now(),
      });

      setState(() {
        addBirthdayData = NewBirthdayData(
          name: '',
          day: DateTime.now().day,
          month: DateTime.now().month,
          year: DateTime.now().year,
          notes: '',
        );
      });
    } catch (e) {
      confirm(
        context,
        onInput: (result) {
          Navigator.of(context).pop();
          setState(() {
            if (indexes.last == 1) return;
            indexes.add(1);
          });
        },
        title: Text("Ocurrió un error"),
        content: Text("No se pudo guardar el cumpleaños. Por favor, intenta de nuevo."),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final currentIndex = indexes.last;

    Widget body = BirthdaysList(
      filter: filter,
    );

    if (currentIndex == 1) {
      body = NewBirthday(
        data: addBirthdayData,
        onDataChange: (data) {
          setState(() {
            addBirthdayData = data;
          });
        },
      );
    } else if (currentIndex == 2) {
      body = SettingsPage();
    }

    return WillPopScope(
      onWillPop: () async {
        if (indexes.length > 1) {
          setState(() {
            indexes.removeLast();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: SearchAppBar(
          elevation: currentIndex == 2 ? 3.0 : null,
          searchEnabled: currentIndex == 0,
          onCancel: () {
            setState(() {
              filter = '';
            });
          },
          onSearch: (query) {
            setState(() {
              filter = query;
            });
          },
        ),
        // appBar: AppBar(
        //   title: Text(strings.mainPageTitle),
        //   shadowColor: Colors.black26,
        //   elevation: currentIndex == 2 ? 3.0 : null,
        //   actions: [
        //     IconButton(icon: Icon(Icons.search), onPressed: () {}),
        //   ],
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: currentIndex == 1
            ? FloatingActionButton.extended(
                onPressed: saveBirthday,
                icon: Icon(Icons.save_rounded),
                label: Text("Guardar"),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          elevation: 3.0,
          onDestinationSelected: (int destinationIndex) {
            if (currentIndex == destinationIndex) return;

            setState(() {
              indexes.add(destinationIndex);
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.list),
              label: strings.birthdays,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add),
              label: strings.add,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: strings.settings,
            ),
          ],
        ),
        body: body,
      ),
    );
  }
}



// ends StatelessWidget {
//   const Home({super.key});

//   @override
//   Widget build(Object context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('birthdays')
//             .where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           final birthdays = snapshot.data?.docs.map((e) => e.data()).toList();

//           if (snapshot.hasError) {
//             return Text("ERROR");
//           }

//           if (birthdays == null) {
//             return Text("LOADING");
//           }

//           return ListView.builder(
//             itemCount: birthdays.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: EdgeInsets.all(10),
//                 child: Card(
//                     child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Text(birthdays[index]['personName']),
//                 )),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
