import 'package:birthday_reminder/helpers/birthday.dart';
import 'package:birthday_reminder/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef FirestoreCollectionSnapshotStream = Stream<QuerySnapshot<Map<String, dynamic>>>;

FirestoreCollectionSnapshotStream getBirthdaysFirestoreSnapshotStream() {
  return FirebaseFirestore.instance.collection('birthdays').where('owner', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots();
}

Stream<List<Birthday>> getBirthdaysStream() {
  final originalStream = getBirthdaysFirestoreSnapshotStream();
  final birthdaysStraem = streamMapper(originalStream);
  final stream = streamSort(birthdaysStraem);

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

Iterable<Birthday> filterBirthdays(Iterable<Birthday> birthdays, String filter) {
  final filterLower = removeDiacritics(filter.toLowerCase()).trim();

  return birthdays.where((birthday) {
    return removeDiacritics(birthday.personName).toLowerCase().contains(filterLower);
  });
}

Stream<List<Birthday>> streamSort(Stream<Iterable<Birthday>> stream) {
  return stream.map((birthdays) {
    final list = birthdays.toList();
    list.sort((a, b) => a.durationToNextBirthday().compareTo(b.durationToNextBirthday()));
    return list;
  });
}
