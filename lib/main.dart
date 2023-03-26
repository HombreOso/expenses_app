import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';

import '../screens/expenses_screen.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FutureBuilder(
      // Initialize FlutterFire:
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text(
            "Something went wrong",
            textDirection: TextDirection.ltr,
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show a loading indicator
        return Text(
          "Loading",
          textDirection: TextDirection.ltr,
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        secondaryHeaderColor: Colors.amber,

        // errorColor: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              labelLarge: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          titleTextStyle: ThemeData.light().textTheme.titleLarge!.copyWith(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        iconTheme: IconThemeData(
          color: Colors.amber,
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            }
            if (userSnapshot.hasData) {
              return MyHomePage();
            }
            return AuthScreen();
          }),
    );
  }
}
