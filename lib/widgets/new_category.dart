import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import './dropdownExpenseCategories.dart';

class NewCategory extends StatefulWidget {
  final Function addCt;
  final String nameCt;
  final String amountCt;
  final String nameCurrentCt;

  NewCategory(this.addCt, this.nameCt, this.amountCt, this.nameCurrentCt);

  @override
  _NewCategoryState createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  var _amountController;
  var _titleController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.nameCt);
    _amountController = TextEditingController(text: widget.amountCt);
  }

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  Future<List<String>> get namesOfCategories async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories = snapshot.docs
        .map((doc) => Category.fromMap(doc.data()))
        .toList()
        .where((cat) => cat.uid == uid)
        .toList();
    return await loadedCategories.map((e) => e.name as String).toList();
  }

  String _selectedCategory = "Food";
  DateTime _selectedDate = DateTime.now();
  bool _usedDefaultDate = true;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    widget.addCt(enteredTitle, enteredAmount, "");

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _usedDefaultDate ? null : _submitData(),
              // onChanged: (val) => amountInput = val,
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: Text(
                'Add Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).secondaryHeaderColor),
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  textStyle: MaterialStateProperty.all(Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.white)),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  alignment: Alignment.center),
              onPressed: () async => (await namesOfCategories)
                      .contains(_selectedCategory)
                  ? {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Category already exists'),
                          content: const Text('Category name already exists'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      )
                    }
                  : _submitData,
            ),
          ],
        ),
      ),
    );
  }
}
