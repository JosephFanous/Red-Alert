import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notifications/notification.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //initialize notifications and tutorial screens
            Notifications notification = new Notifications();
            notification.init();

            return _notificationSettings(notification, snapshot.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  // ------------------------------------------------------------------

  // -- Notification Settings --
  //options: scheduled notifications and featured persons notifications
  Widget _notificationSettings(
          Notifications notification, SharedPreferences prefs) =>
    Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.brown[300], spreadRadius: 3),
        ],
      ),
      margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Column(children: <Widget>[
        Text(
          FlutterI18n.translate(
              context, "settings.notifications.title"), //header
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        _scheduledNotification(prefs),
        _featurePerson(prefs),
      ]
    )
  );

  // -- Scheduled Notifications --
  Widget _scheduledNotification(SharedPreferences prefs) => SwitchListTile(
    activeColor: Colors.white,
    contentPadding: const EdgeInsets.all(0),
    value: prefs.getBool('notifications_scheduled') ?? true,
    onChanged: (bool value) {
      prefs.setBool("notifications_scheduled", value);
      setState(() {});
    },
    title: Text(
        FlutterI18n.translate(context, "settings.notifications.scheduled"),
        textScaleFactor: 1.1,
        style: TextStyle(color: Colors.white)),
  );

  // -- Featured Persons Notifications --
  Widget _featurePerson(SharedPreferences prefs) => SwitchListTile(
    activeColor: Colors.white,
    contentPadding: const EdgeInsets.all(0),
    value: prefs.getBool('notifications_featured') ?? true,
    onChanged: (bool value) {
      prefs.setBool("notifications_featured", value);
      setState(() {});
    },
    title: Text(
      FlutterI18n.translate(context, "settings.notifications.featured"),
      textScaleFactor: 1.1,
      style: TextStyle(color: Colors.white),
    ),
  );
}
