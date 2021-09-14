import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Popup Map/popup_map.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

// Pop up dialog for main page
class PeopleDialog extends StatelessWidget {
  final Map person;

  PeopleDialog(this.person);

  Future _showMapDialog(BuildContext scaffoldContext) async => await showDialog(
    context: scaffoldContext,
    builder: (_) {
      return PopUpMap(
        person['city'],
        person['province'],
        person['image'],
      );
    }
  );

  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: SimpleDialog(
        backgroundColor: Colors.brown[400],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: _dialogHeader(),
        children: [
          _dialogImage(),
          _dialogBody(context),
        ],
      ),
    );
  }

  // ----------------------------------------------------------

  Widget _dialogHeader() => Text(
        person['firstName'] + " " + person['lastName'],
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      );

  Widget _dialogImage() => Image.network(
        person['image'],
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.error),
      );

  // ----------------------------------------------------------

  Widget _dialogBody(BuildContext context) => Container(
        child: SimpleDialogOption(
          child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              _dialogBodyDate(context),
              SizedBox(height: 15),
              _dialogBodyLoc(),
              SizedBox(height: 15),
            ],
          ),
        ),
      );

  Widget _dialogBodyDate(BuildContext context) => FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DateFormat formatter = DateFormat(
              'MMMM dd, yyyy', snapshot.data.getString('language') ?? "en");
          String missingSince =
              formatter.format(DateTime.parse(person['missingSince']));

          return Row(
            children: [
              Expanded(
                  child: Text(
                FlutterI18n.translate(context, "person_dialog.missing_since") +
                    missingSince,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ))
            ],
          );
        } else {
          return Text("Loading");
        }
      });

  Widget _dialogBodyLoc() => Builder(
    builder: (context) => Row(children: [
      Expanded(
        child: ElevatedButton(
          child: Text(
            FlutterI18n.translate(
                    context, "person_dialog.last_location") +
                person['city'] +
                ", " +
                person['province'],
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          onPressed: () => _showMapDialog(context),
        ),
      ),
    ])
  );
}
