import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/new_category.dart';
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

  static Future<List<Category>> _fetchDataFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final List<Category> loadedCategories =
        snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
    return loadedCategories;
  }

  Future<void> _addNewCategory(
    String ctName,
    double ctAmount,
  ) async {
    final String categoryIdAsCurrentDateTime = DateTime.now().toString();
    final newCt = Category(
      name: ctName,
      amount: ctAmount,
      uid: uid,
    );
    setState(() {
      categories.add(newCt);
    });
    // Write the transaction to Firebase
    await categoriesCollectionRef.add({
      'uid': uid,
      'id': categoryIdAsCurrentDateTime,
      'name': newCt.name,
      'amount': newCt.amount,
    });
  }

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
      print('Failed to delete category: $e');
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
                // TextButton(
                //   onPressed: () {
                //     // Add the new category and close the dialog
                //     categories.length != 0
                //         ? Navigator.of(context).pushNamed('/expenses')
                //         : null;
                //   },
                //   child: Text('Done'),
                // ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewCategory(context),
      ),
    );
  }

  void _startAddNewCategory(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewCategory(_addNewCategory),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }
}
