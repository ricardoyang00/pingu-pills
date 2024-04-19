import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/medicaments.dart';
import 'package:app/preferences.dart';
import 'package:app/screens/stock_screen.dart';
import 'dart:async';

void verifyStockRunningLow(Medicament medicament) async {
  int lowQuantity = await Preferences().getLowQuantity();

  if (medicament.quantity <= lowQuantity) {
    String title = 'Stock is Running Low!';
    String body;
    if (medicament.quantity == 1) {
      body = '${medicament.name} only has 1 piece remaining';
    } else if (medicament.quantity == 0) {
      body = '${medicament.name} is out of stock';
    } else {
      body = '${medicament.name} only has ${medicament.quantity} pieces remaining';
    }
    quantityLowNotificationHandler(title, body);
  }
}

void quantityLowNotificationHandler(String title, String body) async {
  await showNotification(title, body);
}

Future<void> requestNotificationPermission(BuildContext context, String notification_title, String notification_text) async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please grant permission to receive notifications'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Request notification permission
                var status = await Permission.notification.request();
                Navigator.of(context).pop(status.isGranted);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await showNotification(notification_title,notification_text);
    }
  } else {
    await showNotification(notification_title,notification_text);
  }
}

Future<void> showNotification(String notification_title, String notification_text) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/ic_launcher',
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await FlutterLocalNotificationsPlugin().show(
    0,
    notification_title,
    notification_text,
    platformChannelSpecifics,
    payload: 'item x',
  );
}