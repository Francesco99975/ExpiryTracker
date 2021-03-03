import 'package:expiration_notifier/providers/expiryItems.dart';
import 'package:expiration_notifier/screens/expiryItemForm.dart';
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
            brightness: Brightness.dark,
            primarySwatch: Colors.amber,
            accentColor: Colors.blue[600],
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: {ExpiryItemForm.ROUTE_NAME: (_) => ExpiryItemForm()},
          home: Home()),
    );
  }
}
