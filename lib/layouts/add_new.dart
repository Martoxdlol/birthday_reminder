import 'package:birthday_reminder/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewBirthdayData {
  final String name;
  final int day;
  final int month;
  final int year;
  final String notes;

  NewBirthdayData({
    required this.name,
    required this.day,
    required this.month,
    required this.year,
    required this.notes,
  });

  @override
  String toString() {
    return "NewBirthdayData(name: $name, day: $day, month: $month, year: $year)";
  }

  NewBirthdayData copyWith({
    String? name,
    int? day,
    int? month,
    int? year,
    String? notes,
  }) {
    return NewBirthdayData(
      name: name ?? this.name,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      notes: notes ?? this.notes,
    );
  }
}

class NewBirthday extends StatelessWidget {
  const NewBirthday({
    super.key,
    required this.data,
    required this.onDataChange,
  });

  final NewBirthdayData data;
  final void Function(NewBirthdayData data) onDataChange;

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    final strings = appStrings(context);

    final days = <int>[];
    for (int i = 1; i <= 31; i++) {
      days.add(i);
    }

    final months = <String>[];
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(2000, i, 15);
      final format = DateFormat('MMMM', strings.localeName);

      months.add(format.format(date));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                filled: true,
                labelText: "Nombre de la persona",
              ),
              initialValue: data.name,
              onChanged: (value) {
                onDataChange(data.copyWith(name: value));
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ExpandedDropDownPicker(
                  onChanged: (value) {
                    onDataChange(data.copyWith(month: value));
                  },
                  value: data.month,
                  label: 'Mes',
                  items: months,
                ),
                const SizedBox(width: 10),
                ExpandedDropDownPicker(
                  onChanged: (value) {
                    onDataChange(data.copyWith(day: value));
                  },
                  value: data.day,
                  label: 'Día',
                  items: days.map((e) => e.toString()).toList(),
                )
              ],
            ),
            const SizedBox(height: 10),
            BirthYearPicker(
              value: data.year,
              onChanged: (value) {
                onDataChange(data.copyWith(year: value));
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                filled: true,
                labelText: "Notas",
              ),
              onChanged: (value) {
                onDataChange(data.copyWith(name: value));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ExpandedDropDownPicker extends StatelessWidget {
  const ExpandedDropDownPicker({super.key, required this.label, required this.items, required this.onChanged, required this.value});

  final String label;
  final List<String> items;
  final int value;
  final Function(int?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final menuItems = <DropdownMenuItem<int>>[];

    for (var i = 0; i < items.length; i++) {
      menuItems.add(
        DropdownMenuItem(
          value: i,
          child: Text(items[i]),
        ),
      );
    }

    return Expanded(
      child: DropdownButtonFormField(
        onChanged: (value) {
          onChanged?.call(value != null ? value + 1 : null);
        },
        decoration: InputDecoration(
          filled: true,
          labelText: label,
        ),
        value: value - 1,
        items: menuItems,
      ),
    );
  }
}

class BirthYearPicker extends StatefulWidget {
  const BirthYearPicker({super.key, required this.onChanged, required this.value});

  final Function(int?)? onChanged;
  final int value;

  @override
  State<BirthYearPicker> createState() => _BirthYearPickerState();
}

class _BirthYearPickerState extends State<BirthYearPicker> {
  var menuItems = <DropdownMenuItem<int>>[];

  @override
  void initState() {
    setState(() {
      menuItems.add(const DropdownMenuItem(
        value: 0,
        child: Text("Sin especificar"),
      ));

      for (int i = -1; i < 130; i++) {
        final currentYear = DateTime.now().year;
        final year = currentYear - i;
        final turns = currentYear - year;

        if (turns == -1) {
          // next year
          menuItems.add(DropdownMenuItem(
            value: year,
            child: Row(children: [
              Text((DateTime.now().year - i).toString()),
              const SizedBox(width: 7),
              const Text("nace el año próximo", style: TextStyle(color: Colors.grey)),
            ]),
          ));
        } else if (turns == 0) {
          // this year
          menuItems.add(DropdownMenuItem(
            value: year,
            child: Row(children: [
              Text((DateTime.now().year - i).toString()),
              const SizedBox(width: 7),
              const Text("nace este año", style: TextStyle(color: Colors.grey)),
            ]),
          ));
        } else {
          // past years
          menuItems.add(DropdownMenuItem(
            value: year,
            child: Row(children: [
              Text((DateTime.now().year - i).toString()),
              const SizedBox(width: 7),
              Text("cumple $turns años", style: const TextStyle(color: Colors.grey)),
            ]),
          ));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      onChanged: (value) {},
      decoration: const InputDecoration(
        filled: true,
        labelText: "Año de nacimiento",
      ),
      value: 0,
      items: menuItems,
    );
  }
}
