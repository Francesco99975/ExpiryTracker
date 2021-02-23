import 'package:flutter/material.dart';

void main() {
  runApp(ExpirationNotifierApp());
}

class ExpirationNotifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Expiration Notifier',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold());
  }
}
