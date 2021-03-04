import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications with ChangeNotifier {
  // Notification setup
  FlutterLocalNotificationsPlugin _localNotification;

  Future<void> loadNotificationsPlugin() async {
    tz.initializeTimeZones();
    var androidInitialize = AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = IOSInitializationSettings();
    var initializeSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    _localNotification = FlutterLocalNotificationsPlugin();
    _localNotification.initialize(initializeSettings);
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));
  }

  Future<void> scheduleNotification(
      int notifId, String title, DateTime expiryDate) async {
    await _localNotification.zonedSchedule(
        notifId,
        title,
        "$title is going to expire soon",
        tz.TZDateTime.from(
            expiryDate.subtract(const Duration(days: 2)), tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails("expiry-channel-1",
                "expiry-channel", "channel for expiry items notifications"),
            iOS: IOSNotificationDetails()),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelNotification(int notifId) async {
    await _localNotification.cancel(notifId);
  }
}
