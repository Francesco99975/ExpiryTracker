import 'package:expiration_notifier/providers/expiryItem.dart';
import 'package:expiration_notifier/providers/expiryItems.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpiryListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ExpiryItem>(context);
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you want to delete this item ?"),
            actions: <Widget>[
              FlatButton(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: const Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          Provider.of<ExpiryItems>(context, listen: false).deleteItem(item.id);
        }
      },
      child: Card(
        elevation: 5,
        child: ListTile(
            title: Text(item.name),
            subtitle: Text(item.expiryDate.toString()),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
            )),
      ),
    );
  }
}
