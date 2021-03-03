import 'package:expiration_notifier/providers/expiryItems.dart';
import 'package:expiration_notifier/screens/expiryItemForm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/ExpiryListItem.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ExpiryItems>(context, listen: false).loadItems(),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: FittedBox(
                        child: Text(
                      'Expiry List',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          letterSpacing: 2.0),
                    )),
                    centerTitle: true,
                    actions: [
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () => Navigator.of(context).pushNamed(
                              ExpiryItemForm.ROUTE_NAME,
                              arguments: {'edit': false, 'name': "null"}))
                    ],
                  ),
                  body: SafeArea(
                    child: Container(
                      child: Consumer<ExpiryItems>(
                        child: Center(
                          child: const Text(
                            "Press [+] to add an item",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        builder: (context, items, child) => items.size() < 1
                            ? child
                            : ListView.builder(
                                itemCount: items.size(),
                                itemBuilder: (context, index) =>
                                    ChangeNotifierProvider.value(
                                  value: items.items[index],
                                  child: ExpiryListItem(),
                                ),
                              ),
                      ),
                    ),
                  )),
    );
  }
}
