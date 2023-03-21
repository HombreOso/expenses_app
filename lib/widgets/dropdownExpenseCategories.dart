import 'package:flutter/material.dart';

class DropdownButtonExample extends StatefulWidget {
  final Function(String) onChangedDDL;
  final BuildContext ctx;

  DropdownButtonExample({
    super.key,
    required this.onChangedDDL,
    required this.ctx,
  });

  @override
  State<DropdownButtonExample> createState() =>
      _DropdownButtonExampleState(onChangedDDL: onChangedDDL);
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> listExpenseCategories = const <String>[
    "Food",
    "Amazon",
    "Education",
    "Gadgets",
    "Others",
  ];
  // ignore: todo
  // TODO screen where this categories can be specified by user
  Function(String) onChangedDDL;
  String dropdownValue =
      "Food"; // dropdownValue is initialized to a value contained in the listExpenseCategories
  // ToDo: make the category "Food" be set by default, so that user only has to type the cost and hit "Add" button
  // Current behaviour: if the category is not set, the entry has only cost value and empty string instead of "Food"

  _DropdownButtonExampleState({
    required this.onChangedDDL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(widget.ctx).primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(
          Icons.arrow_downward,
          color: Colors.amber,
        ),
        elevation: 16,
        style: TextStyle(
          color: Theme.of(widget.ctx).secondaryHeaderColor,
          fontWeight: FontWeight.bold,
        ),
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
      ),
    );
  }
}
