import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  final uuid = Uuid();

  // Notification setup
  FlutterLocalNotificationsPlugin localNotification;

  // Form variables
  String _name;
  DateTime _expiryDate;

  @override
  void initState() {
    _expiryDate = DateTime.now();
    tz.initializeTimeZones();
    var androidInitialize = AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = IOSInitializationSettings();
    var initializeSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    localNotification = FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializeSettings);
    initTimezone();
    super.initState();
  }

  void _presentDatePicker(BuildContext ctx, args) async {
    final pickedDate = await showDatePicker(
        context: ctx,
        initialDate:
            args['edit'] ? DateTime.parse(args['date']) : DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2090));

    if (pickedDate == null) return;

    setState(() {
      _expiryDate = pickedDate;
    });
  }

  Future<void> initTimezone() async {
    return Future(() async {
      tz.setLocalLocation(
          tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
    });
  }

  void _save() async {
    _isLoading = true;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final newItem =
          ExpiryItem(id: uuid.v4(), name: _name, expiryDate: _expiryDate);
      await Provider.of<ExpiryItems>(context, listen: false).addItem(newItem);
      await localNotification.zonedSchedule(
          Provider.of<ExpiryItems>(context, listen: false).size() - 1,
          newItem.name,
          "${newItem.name} is going to expire soon",
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
          const NotificationDetails(
              android: AndroidNotificationDetails("expiry-channel-1",
                  "expiry-channel", "channel for expiry items notifications"),
              iOS: IOSNotificationDetails()),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

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
                ],
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                onPressed: _isLoading ? () {} : _save,
                child: Text(
                  "SET ITEM",
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
