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
            args['edit'] ? DateTime.parse(args['date']) : DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2090));

    if (pickedDate == null) return;

    _expiryDate = pickedDate;
  }

  Future<void> initTimezone() async {
    return Future(() async {
      tz.setLocalLocation(
          tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
    });
  }

  void _save() async {
    _isLoading = true;
    final newItem =
        ExpiryItem(id: uuid.v4(), name: _name, expiryDate: _expiryDate);
    await Provider.of<ExpiryItems>(context, listen: false).addItem(newItem);
    await localNotification.zonedSchedule(
        Provider.of<ExpiryItems>(context, listen: false).size(),
        newItem.name,
        "$newItem is going to expire soon",
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title:
            args['edit'] ? const Text("Update Item") : const Text("Add Item"),
        centerTitle: true,
      ),
      body: Container(
        height: deviceSize.height,
        width: deviceSize.width,
        margin: EdgeInsets.all(18.0),
        padding: EdgeInsets.all(5.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  autocorrect: false,
                  initialValue: args['edit'] ? args['name'] : null,
                  decoration: InputDecoration(labelText: "Item name"),
                  validator: (value) =>
                      value.trim().isEmpty ? "Enter a item name please" : null,
                  onSaved: (newValue) => _name = newValue,
                ),
                Center(
                  child: InkWell(
                    child: FittedBox(
                        child:
                            Text(DateFormat.yMMMMEEEEd().format(_expiryDate))),
                    onTap: () => _presentDatePicker(context, args),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  onPressed: _isLoading ? () {} : _save,
                  child: Text("Set Item"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
