import 'package:expiration_notifier/providers/expiryItem.dart';
import 'package:expiration_notifier/providers/expiryItems.dart';
import 'package:expiration_notifier/providers/notifications.dart';
import 'package:expiration_notifier/screens/expiryItemForm.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpiryListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final item = Provider.of<ExpiryItem>(context);
    final now = DateTime.now();

    Color stateClr;
    String expStr = now.isBefore(item.expiryDate) ? "Expires" : "Expired";
    if (now.isBefore(item.expiryDate.subtract(const Duration(days: 10)))) {
      stateClr = Colors.green[700];
    } else if (now
            .isAfter(item.expiryDate.subtract(const Duration(days: 10))) &&
        now.isBefore(item.expiryDate)) {
      stateClr = Colors.yellow[700];
    } else {
      stateClr = Colors.red[700];
    }

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
          await Provider.of<Notifications>(context, listen: false)
              .cancelNotification(item.id);
          await Provider.of<ExpiryItems>(context, listen: false)
              .deleteItem(item.id);
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10)),
            side: BorderSide(width: 5, color: stateClr)),
        child: ListTile(
            title: Text(
              item.name,
              style:
                  TextStyle(fontSize: 22, color: Theme.of(context).accentColor),
            ),
            subtitle: Text(
              "$expStr on: ${DateFormat.yMMMMEEEEd().format(item.expiryDate)}",
              style: TextStyle(fontSize: 16, color: stateClr),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () => Navigator.of(context)
                  .pushNamed(ExpiryItemForm.ROUTE_NAME, arguments: {
                'edit': true,
                'name': item.name,
                'date': item.expiryDate.toString()
              }),
            )),
      ),
    );
  }
}
