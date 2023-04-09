import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/new_transaction.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction_> transactions;
  final Function deleteTx;

  TransactionList(this.transactions, this.deleteTx);

  static final CollectionReference transactionCollectionRef =
      FirebaseFirestore.instance.collection('transactions');
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  void _startUpdateNewTransaction(BuildContext ctx, NewTransaction newTx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: newTx,
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Future<void> _updateNewTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
    String txCategory,
    String txDateIdAsString,
    bool usedDefaultDate,
    DateTime txDate,
  ) async {
    final String transactionIdAsCurrentDateTime = DateTime.now().toString();
    final newTx = Transaction_(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: transactionIdAsCurrentDateTime,
      category: txCategory,
      uid: uid,
    );
    print("update id $txDateIdAsString");
    // Write the transaction to Firebase
    final uptodatedDoc = await transactionCollectionRef
        .where(
          'uid',
          isEqualTo: uid,
        )
        .where(
          'id',
          isEqualTo: txDateIdAsString,
        )
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) => snapshot.docs[0].reference);
    uptodatedDoc.update({
      'uid': uid,
      'id': txDateIdAsString,
      'title': newTx.title,
      'amount': newTx.amount,
      'date': usedDefaultDate
          ? Timestamp.fromDate(txDate)
          : Timestamp.fromDate(newTx.date),
      'category': newTx.category,
    });
    // add({
    //   'uid': uid,
    //   'id': transactionIdAsCurrentDateTime,
    //   'title': newTx.title,
    //   'amount': newTx.amount,
    //   'date': Timestamp.fromDate(newTx.date),
    //   'category': newTx.category,
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: transactions.isEmpty
          ? Column(
              children: <Widget>[
                Text(
                  'No transactions added yet!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    height: 200,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    )),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: Key(transactions[index].id),
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    print("Dismissed id: ${transactions[index].id}");
                    print("Dismissed uid: ${transactions[index].uid}");
                    deleteTx(
                      transactions,
                      transactions[index].id,
                      transactions[index].uid,
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Handle edit transaction here
                        print('Edit transaction ${transactions[index].id}');
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: FittedBox(
                              child: Text('\$${transactions[index].amount}'),
                            ),
                          ),
                        ),
                        title: Text(
                          transactions[index].title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(transactions[index].date),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.blueAccent,
                          onPressed: () {
                            // Handle edit transaction here
                            print('Edit transaction ${transactions[index].id}');
                            _startUpdateNewTransaction(
                              ctx,
                              NewTransaction(
                                  _updateNewTransaction,
                                  transactions[index].amount.toString(),
                                  transactions[index].title,
                                  transactions[index].id,
                                  transactions[index].date),
                            );
                            //return NewTransaction(addTx, initialAmountText, initialTitleText)
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: transactions.length,
            ),
    );
  }
}
