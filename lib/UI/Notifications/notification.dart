import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

import 'notification_dialog.dart';

// Based on Randy's Lecture Code
class Notifications {
  final channelId = 'testNotification';
  final channelName = 'Test Notification';
  final channelDescription = 'Test Notification Channel';

  BuildContext context;
  bool sent = false;

  var _flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

  NotificationDetails _platformChannelInfo;
  var _notificationId = 100;

  void init({BuildContext scaffoldContext}) {
    context = scaffoldContext;

    var initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initSettings = InitializationSettings(android: initSettingsAndroid);

    _flutterNotificationPlugin.initialize(
      initSettings,
      onSelectNotification: onSelectNotification,
    );

    var androidChannelInfo = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
    );

    _platformChannelInfo = NotificationDetails(
      android: androidChannelInfo,
    );
  }

  // ---------------------------------------------------------
  // On selecting the notification
  // Open a dialog

  Future onSelectNotification(String payload) async {
    if (payload.isNotEmpty && sent) {
      await showDialog(
        context: context,
        builder: (_) => NotificationDialog(payload),
      );
    }
  }

  // ---------------------------------------------------------
  // either notify the user now or another set moment of time

  sendNotificationNow(String title, String body, {String payload}) {
    sent = true;
    _flutterNotificationPlugin.show(
      _notificationId++,
      title,
      body,
      _platformChannelInfo,
      payload: payload,
    );
  }

  sendNotificationLater(int id, String title, String body, tz.TZDateTime when,
      {String payload}) {
    sent = true;
    _flutterNotificationPlugin.zonedSchedule(
      //_notificationId++,
      id,
      title,
      body,
      when,
      _platformChannelInfo,
      payload: payload,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
    );
  }
}
