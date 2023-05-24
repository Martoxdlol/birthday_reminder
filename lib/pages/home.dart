import 'package:birthday_reminder/layouts/add_new.dart';
import 'package:birthday_reminder/layouts/birthdays_list.dart';
import 'package:birthday_reminder/layouts/settings_page.dart';
import 'package:birthday_reminder/strings.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<int> indexes = [0];

  CarouselController controller = CarouselController();
  ScrollController listScrollController = ScrollController();
  double appBarElevation = 0;

  void updateScrollPosition() {
    final scrollPosition = listScrollController.position.pixels;
    double nextAppBarElevation = 0;
    if ((scrollPosition / 3) <= 4) {
      nextAppBarElevation = scrollPosition / 10;
    }
    if ((scrollPosition / 3) > 4) {
      nextAppBarElevation = 4;
    }

    if (nextAppBarElevation == appBarElevation) return;

    setState(() {
      appBarElevation = nextAppBarElevation;
    });
  }

  @override
  void initState() {
    listScrollController.addListener(updateScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    listScrollController.removeListener(updateScrollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final currentIndex = indexes.last;

    return WillPopScope(
      onWillPop: () async {
        if (indexes.length > 1) {
          final destinationIndex = indexes[indexes.length - 2];
          setState(() {
            indexes.removeLast();
          });
          controller.animateToPage(destinationIndex);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.mainPageTitle),
          shadowColor: Colors.black26,
          elevation: appBarElevation,
          actions: [
            IconButton(icon: Icon(Icons.cake), onPressed: () {}),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (int destinationIndex) {
            if (currentIndex == destinationIndex) return;
            controller.animateToPage(destinationIndex);
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
        body: CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            enableInfiniteScroll: true,
            animateToClosest: true,
            disableCenter: false,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            viewportFraction: 1,
            height: double.infinity,
            onPageChanged: (index, reason) {
              setState(() {
                if (currentIndex == index) return;
                indexes.add(index);
              });
            },
          ),
          items: [
            BirthdaysList(
              scrollController: listScrollController,
            ),
            NewBirthday(),
            SettingsPage(),
          ],
        ),
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
