import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text('Expiry List')),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView.builder(itemBuilder: null),
    );
  }
}
