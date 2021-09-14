import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../Notifications/notification.dart';

class NotifyButton extends StatelessWidget {
  final Notifications _notifications;
  final Map person;

  NotifyButton(this._notifications, this.person);

  void _notifyBtnHandler(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateFormat formatter =
        DateFormat('MMMM dd, yyyy', prefs.getString('language') ?? "en");

    if (prefs.getBool('notifications_scheduled') ?? false) {
      var when = await _selectDate(context); //function which opens a DatePicker

      if (when != null) {
        await _notifications.sendNotificationNow(
            "Reminder Set For " + formatter.format(when),
            person['firstName'] + " " + person['lastName']);
        await _notifications.sendNotificationLater(
          person['id'],
          "Did you find me?",
          person['firstName'] + " " + person['lastName'],
          when,
        );

        _confirmationFialog(when, context);
      }
    } else {
      _notEnabledDialog(context);
    }
  }

  //dialog to alert user that the notification was scheduled
  Future _confirmationFialog(when, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateFormat formatter =
        DateFormat('MMMM dd, yyyy', prefs.getString('language') ?? "en");

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text(
              "Reminder for ${person['firstName']} ${person['lastName']} set for ${formatter.format(when)}."),
          backgroundColor: Colors.brown[100],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Future _notEnabledDialog(BuildContext context) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: new Text(FlutterI18n.translate(
            context, "person_list.notification_dialog")),
        backgroundColor: Colors.brown[100],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  );

  @override
  Widget build(BuildContext context) {
    //notifyButton: a button which processes a future notification for the accociated person.

    return IconButton(
      icon: Icon(
        Icons.add_alert,
        color: Colors.white,
      ),
      onPressed: () => _notifyBtnHandler(context),
    );
  }

  // ---------------------------------------------------------------------
  //_selectDate: opens a DatePicker to choose the date of the notification to set.
  Future<tz.TZDateTime> _selectDate(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: Locale(prefs.getString('language') ?? "en"));

    if (selectedDate == null) {
      return null;
    } else {
      return tz.TZDateTime.from(selectedDate, tz.local);
    }
  }
}
