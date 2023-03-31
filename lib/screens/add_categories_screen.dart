import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/new_transaction.dart';
import '../widgets/transaction_list.dart';
import '../widgets/chart.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/categories_list.dart';
import '../firebase_options.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];
  static final CollectionReference categoriesCollectionRef =
      FirebaseFirestore.instance.collection('categories');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  void _deleteCategory(String name, String uid) async {
    // Remove the transaction from the local list
    setState(() {
      categories.removeWhere((tx) => tx.name == name);
    });
    // Get a reference to the Firestore document using the local transaction ID
    final categoryDoc = await categoriesCollectionRef
        .where('uid', isEqualTo: uid)
        .where('name', isEqualTo: name)
        .get()
        .then((value) => value.docs.first.reference);

    // Delete the document from Firestore
    try {
      await categoryDoc.delete();
    } catch (e) {
      // Handle errors
      print('Failed to delete transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('amount', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Category> loadedCategories = [];
          final List<DocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data!.docs
                  .cast<DocumentSnapshot<Map<String, dynamic>>>();
          documents.forEach((doc) {
            final category = Category.fromSnapshot(doc);
            loadedCategories.add(category);
          });
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CategoriesList(loadedCategories, _deleteCategory),
                TextButton(
                  onPressed: () {
                    // Add the new category and close the dialog
                    categories.length != 0
                        ? Navigator.of(context).pushNamed('/expenses')
                        : null;
                  },
                  child: Text('Done'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() async {
    Category newCategory = Category(
      name: "",
      amount: 0,
      uid: uid,
    );
    newCategory = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                ),
                onChanged: (value) {
                  // Update the name of the new category as the user types
                  newCategory.name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Update the amount of the new category as the user types
                  newCategory.amount = double.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog without adding the new category
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the new category and close the dialog
                Navigator.of(context).pop(newCategory);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    // If the user added a new category, add it to the list
    setState(() {
      categories.add(newCategory);
    });
  }
}
