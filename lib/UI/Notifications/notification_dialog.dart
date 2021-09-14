import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../Database/missing_person_database.dart';

class NotificationDialog extends StatelessWidget {
  final MissingPeopleModel missingPeople = MissingPeopleModel();
  final String payload;

  NotificationDialog(this.payload);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.brown,
      title: Text(
        "Feature Person",
        style: TextStyle(color: Colors.white),),
      content: _missingPersonOfTheyDay(),
      actions: [
        Builder(
        builder: (context) => TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "OK",
            style: TextStyle(color: Colors.blue[300]),
          ),
        ),
      )],
    );
  }

  // ---------------------------------------------------------
  // Widgets in dialog for notification

  Widget _missingPersonOfTheyDay() => FutureBuilder(
    future: missingPeople.getPeopleFromId(payload),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data.length > 0) {
          return _missingPersonOfTheDayContent(snapshot.data[0]);
        } else {
          return Text("No Data");
        }
      } else {
        return Text("Fetching Data");
      }
    });

  Widget _missingPersonOfTheDayContent(Map person) => FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Date Formatter for formatting the date to a more readable format
          DateFormat formatter = DateFormat(
            'MMMM dd, yyyy',
            snapshot.data.getString('language') ?? "en",
          );

          // The person details
          String url = person['image'];
          String name = person['firstName'] + " " + person['lastName'];
          String missingSince =
              formatter.format(DateTime.parse(person['missingSince']));
          String lastKnownLoc = person['city'] + ", " + person['province'];

          // the content
          return Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogImg(url),
            SizedBox(height: 10),
            _dialogName(name),
            SizedBox(height: 10),
            _dialogDate(missingSince, snapshot.data),
            _dialogLoc(lastKnownLoc, snapshot.data),
          ]);
        } else {
          return Text("Loading");
        }
      });

  Widget _dialogImg(String url) => Image.network(
        url,
        errorBuilder: (context, exception, stacktrace) => Icon(Icons.error),
      );

  Widget _dialogName(String name) => Text(
        name,
        style: TextStyle(color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
      );

  Widget _dialogDate(String missingSince, SharedPreferences prefs) => Builder(
      builder: (context) => Text(
            FlutterI18n.translate(context, "person_dialog.missing_since") +
                missingSince,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ));

  Widget _dialogLoc(String lastKnownLoc, SharedPreferences prefs) => Builder(
      builder: (context) => Text(
            FlutterI18n.translate(context, "person_dialog.last_location") +
                lastKnownLoc,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ));
}
