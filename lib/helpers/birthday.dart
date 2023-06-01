import 'package:cloud_firestore/cloud_firestore.dart';

class Birthday {
  final String id;
  final String personName;
  final DateTime birth;
  final String notes;
  final bool noYear;

  Birthday({
    required this.id,
    required this.personName,
    required this.birth,
    required this.notes,
    required this.noYear,
  });

  @override
  String toString() {
    return "Bithday(personName: $personName, birth: $birth, notes: $notes, noYear: $noYear)";
  }

  Birthday copyWith({
    String? id,
    String? personName,
    DateTime? birth,
    String? notes,
    bool? noYear,
  }) {
    return Birthday(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      birth: birth ?? this.birth,
      notes: notes ?? this.notes,
      noYear: noYear ?? this.noYear,
    );
  }

  factory Birthday.fromMap(Map<String, dynamic> map, {String? id}) {
    final useId = map['id'] as String? ?? id;

    if (useId == null) {
      throw ArgumentError('id not found, provide id as argument or in map');
    }

    final rawBirth = map['birth'];

    DateTime birth;

    if (rawBirth is DateTime) {
      birth = rawBirth;
    } else if (rawBirth is Timestamp) {
      birth = rawBirth.toDate();
    } else if (rawBirth is num) {
      birth = DateTime.fromMillisecondsSinceEpoch(rawBirth.toInt());
    } else {
      birth = DateTime.parse(map['birth'].toString());
    }

    return Birthday(
      id: useId,
      personName: map['personName'] as String,
      birth: birth,
      notes: map['notes'] as String,
      noYear: map['noYear'] as bool? ?? false,
    );
  }

  DateTime nextBirthday({DateTime? from}) {
    final now = from ?? DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

    final thisYear = now.year;

    final nextBirthday = DateTime(
      thisYear,
      birth.month,
      birth.day,
    );

    if (nextBirthday.isBefore(now)) {
      return DateTime(
        thisYear + 1,
        birth.month,
        birth.day,
      );
    }

    return nextBirthday;
  }

  int daysToNextBirthday({DateTime? from}) {
    final now = from ?? DateTime.now();

    final difference = nextBirthday(from: from).difference(now);

    return difference.inDays;
  }

  int? nextAge({DateTime? from}) {
    if (noYear) return null;

    final bornYear = birth.year;
    final nextYear = nextBirthday(from: from).year;

    return nextYear - bornYear;
  }

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'birth': birth,
      'notes': notes,
      'noYear': noYear,
    };
  }
}
