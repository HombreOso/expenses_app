import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/new_transaction.dart';
import '../widgets/transaction_list.dart';
import '../widgets/chart.dart';
import '../models/transaction.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static Future<List<Transaction_>> _fetchDataFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('transactions').get();
    final List<Transaction_> loadedTransactions =
        snapshot.docs.map((doc) => Transaction_.fromMap(doc.data())).toList();
    return loadedTransactions;
  }

  List<Transaction_> _userTransactions = [];

  static final CollectionReference transactionCollectionRef =
      FirebaseFirestore.instance.collection('transactions');

  Stream<QuerySnapshot> getTransactions() {
    return transactionCollectionRef.snapshots();
  }

  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  List<Transaction_> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 31), //  transactions in the last 31 days
        ),
      );
    }).toList();
  }

  Future<void> _addNewTransaction(String txTitle, double txAmount,
      DateTime chosenDate, String txCategory) async {
    final String transactionIdAsCurrentDateTime = DateTime.now().toString();
    final newTx = Transaction_(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: transactionIdAsCurrentDateTime,
      category: txCategory,
      uid: uid,
    );
    setState(() {
      _userTransactions.add(newTx);
    });
    // Write the transaction to Firebase
    await transactionCollectionRef.add({
      'uid': uid,
      'id': transactionIdAsCurrentDateTime,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': Timestamp.fromDate(newTx.date),
      'category': newTx.category,
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id, String uid) async {
    // Remove the transaction from the local list
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
    print("Id: $id");
    print("Uid: $uid");
    // Get a reference to the Firestore document using the local transaction ID
    final transactionDoc = await transactionCollectionRef
        .where('uid', isEqualTo: uid)
        .where('id', isEqualTo: id)
        .get()
        .then((value) => value.docs.first.reference);

    // Delete the document from Firestore
    try {
      await transactionDoc.delete();
    } catch (e) {
      // Handle errors
      print('Failed to delete transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Expenses',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Chart(_recentTransactions),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final List<Transaction_> loadedTransactions = [];
                final List<DocumentSnapshot<Map<String, dynamic>>> documents =
                    snapshot.data!.docs
                        .cast<DocumentSnapshot<Map<String, dynamic>>>();
                documents.forEach((doc) {
                  final transaction = Transaction_.fromSnapshot(doc);
                  loadedTransactions.add(transaction);
                });
                return TransactionList(loadedTransactions, _deleteTransaction);
              },
            ),
            //TransactionList(_userTransactions, _deleteTransaction),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
