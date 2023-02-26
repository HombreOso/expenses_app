import 'package:flutter/material.dart';

class DropdownButtonExample extends StatefulWidget {

  final Function(String) onChangedDDL;

  DropdownButtonExample({
    super.key,
    required this.onChangedDDL,
  });

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState(onChangedDDL: onChangedDDL);
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> listExpenseCategories = const <String>["Food", "Amazon", "Education", "Gadgets", "Others"];
  Function(String) onChangedDDL;
  String dropdownValue = "Food"; // dropdownValue is initialized to a value contained in the listExpenseCategories
  // ToDo: make the category "Food" be set by default, so that user only has to type the cost and hit "Add" button
  // Current behaviour: if the category is not set, the entry has only cost value and empty string instead of "Food"

  _DropdownButtonExampleState(
    {
        required this.onChangedDDL,
    }
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Color.fromARGB(255, 12, 113, 195)),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;

        });
        onChangedDDL(dropdownValue);
      },
      items: listExpenseCategories.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}