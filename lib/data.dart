import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef FirestoreCollectionSnapshotStream = Stream<QuerySnapshot<Map<String, dynamic>>>;

FirestoreCollectionSnapshotStream getBirthdaysStream() {
  return FirebaseFirestore.instance.collection('birthdays').where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();
}

Stream<List<Birthday>> getBirdthaysSortedAndFilteredStream(String filter) {
  final originalStream = getBirthdaysStream();

  final birthdaysStraem = streamMapper(originalStream);
  final unfilteredStream = streamFilter(birthdaysStraem, filter);
  final stream = streamSort(unfilteredStream);

  return stream;
}

Stream<Iterable<Birthday>> streamMapper(Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
  return stream.map(
    (event) => event.docs.map((doc) {
      return Birthday.fromMap(
        doc.data(),
        id: doc.id,
      );
    }),
  );
}

Stream<Iterable<Birthday>> streamFilter(Stream<Iterable<Birthday>> stream, String filter) {
  final filterLower = removeDiacritics(filter.toLowerCase()).trim();

  return stream.map(
    (birthdays) => birthdays.where((birthday) {
      return removeDiacritics(birthday.personName).toLowerCase().contains(filterLower);
    }),
  );
}

Stream<List<Birthday>> streamSort(Stream<Iterable<Birthday>> stream) {
  return stream.map((birthdays) {
    final list = birthdays.toList();
    list.sort((a, b) => a.daysToNextBirthday().compareTo(b.daysToNextBirthday()));
    return list;
  });
}
