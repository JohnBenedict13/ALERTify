import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await _localNotif.initialize(settings);

    await FirebaseMessaging.instance.requestPermission();
  }

  // 🔔 PUBLIC METHOD (THIS WAS MISSING / WRONG)
  static void showLocalAlert(String status) {
    String message;

    switch (status) {
      case "EVACUATION":
        message = "Evacuate immediately! Flood level critical.";
        break;
      case "HIGH_RISK":
        message = "High flood risk. Prepare to evacuate.";
        break;
      case "WARNING":
        message = "Flood warning. Stay alert.";
        break;
      default:
        return;
    }

    _showNotification("ALERTify Flood Alert", message);
  }

  // 🔒 INTERNAL METHOD
  static Future<void> _showNotification(
      String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alert_channel',
      'Flood Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);

    await _localNotif.show(
      0,
      title,
      body,
      notifDetails,
    );
  }
}
