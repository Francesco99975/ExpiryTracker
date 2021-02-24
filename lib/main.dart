import 'package:expiration_notifier/providers/expiryItems.dart';
import 'package:expiration_notifier/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ExpirationNotifierApp());
}

class ExpirationNotifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpiryItems(),
      builder: (_, __) => MaterialApp(
          title: 'Expiration Notifier',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Home()),
    );
  }
}
