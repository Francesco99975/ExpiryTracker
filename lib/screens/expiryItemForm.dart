import 'package:expiration_notifier/providers/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expiryItems.dart';
import '../providers/expiryItem.dart';

class ExpiryItemForm extends StatefulWidget {
  static const ROUTE_NAME = "add-item";
  @override
  _ExpiryItemFormState createState() => _ExpiryItemFormState();
}

class _ExpiryItemFormState extends State<ExpiryItemForm> {
  // UI state variables
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  bool _isInit = true;

  // Form variables
  String _name;
  DateTime _expiryDate;
  Map<String, dynamic> args;
  Size deviceSize;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      args = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      deviceSize = MediaQuery.of(context).size;

      _expiryDate = args['edit']
          ? DateTime.parse(args['date'])
          : DateTime.now().add(const Duration(days: 2));

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _presentDatePicker(BuildContext ctx, args) async {
    final pickedDate = await showDatePicker(
        context: ctx,
        initialDate: args['edit']
            ? DateTime.parse(args['date'])
            : DateTime.now().add(const Duration(days: 2)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2150));

    if (pickedDate == null) return;

    setState(() {
      _expiryDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          _expiryDate.hour, _expiryDate.minute, 0);
      print(_expiryDate);
    });
  }

  Future<TimeOfDay> selectTime(BuildContext context, sh, sm) async {
    return await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: sh, minute: sm));
  }

  void _save() async {
    _isLoading = true;
    if (_formKey.currentState.validate() &&
        _expiryDate.isAfter(DateTime.now().add(const Duration(days: 2)))) {
      _formKey.currentState.save();
      if (!args['edit']) {
        final newItem = ExpiryItem(name: _name, expiryDate: _expiryDate);
        final int id = await Provider.of<ExpiryItems>(context, listen: false)
            .addItem(newItem);
        if (_expiryDate.isAfter(DateTime.now())) {
          await Provider.of<Notifications>(context, listen: false)
              .scheduleNotification(id, newItem.name, newItem.expiryDate);
        }
      } else {
        final updatedItem =
            ExpiryItem(id: args['id'], name: _name, expiryDate: _expiryDate);
        await Provider.of<ExpiryItems>(context, listen: false)
            .updateItem(updatedItem);
        if (_expiryDate.isAfter(DateTime.now())) {
          await Provider.of<Notifications>(context, listen: false)
              .cancelNotification(updatedItem.id);
          await Provider.of<Notifications>(context, listen: false)
              .scheduleNotification(
                  updatedItem.id, updatedItem.name, updatedItem.expiryDate);
        }
      }
      Navigator.pop(context);
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Invalid Data"),
          content: const Text(
              "Please enter valid data for the item name, and make sure that the date is set at least 2 days from now"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Dismiss"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: args['edit']
            ? Text(
                "Update Item",
                style: TextStyle(
                    color: Theme.of(context).accentColor, letterSpacing: 2.0),
              )
            : Text(
                "Add Item",
                style: TextStyle(
                    color: Theme.of(context).accentColor, letterSpacing: 2.0),
              ),
        centerTitle: true,
      ),
      body: Container(
        height: deviceSize.height,
        width: deviceSize.width,
        margin: EdgeInsets.all(18.0),
        padding: EdgeInsets.all(5.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    autocorrect: false,
                    initialValue: args['edit'] ? args['name'] : null,
                    decoration: InputDecoration(labelText: "Item name"),
                    validator: (value) => value.trim().isEmpty
                        ? "Enter a item name please"
                        : null,
                    onSaved: (newValue) => _name = newValue,
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: InkWell(
                      child: FittedBox(
                          child: Text(
                        DateFormat.yMMMMEEEEd().format(_expiryDate),
                        style: TextStyle(
                            color: Theme.of(context).accentColor, fontSize: 22),
                      )),
                      onTap: () => _presentDatePicker(context, args),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: InkWell(
                      child: FittedBox(
                          child: Text(
                        DateFormat.Hm().format(_expiryDate),
                        style: TextStyle(
                            color: Theme.of(context).accentColor, fontSize: 22),
                      )),
                      onTap: () async {
                        TimeOfDay choice = await selectTime(
                            context, _expiryDate.hour, _expiryDate.minute);
                        if (choice != null) {
                          setState(() {
                            _expiryDate = DateTime(
                                _expiryDate.year,
                                _expiryDate.month,
                                _expiryDate.day,
                                choice.hour,
                                choice.minute,
                                0);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                onPressed: _isLoading ? () {} : _save,
                child: Text(
                  args['edit'] ? "UPDATE ITEM" : "SET ITEM",
                  style: TextStyle(fontSize: 22, letterSpacing: 3.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
