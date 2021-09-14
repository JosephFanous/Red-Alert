import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Database/tutorial_database.dart';

class TutorialSettings extends StatefulWidget {
  final TutorialModel tutorialModel = TutorialModel();

  @override
  _TutorialSettingsState createState() => _TutorialSettingsState();
}

class _TutorialSettingsState extends State<TutorialSettings> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _tutorialSettings(snapshot.data);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  // ----------------------------------------------------------------------------------
  // -- Tutorial Settings --
  //options: enable or disable tutorials
  Widget _tutorialSettings(SharedPreferences prefs) => Container(
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
        FlutterI18n.translate(context, "settings.tutorial.title"), //header
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      _tutorialToggle(prefs),
    ])
  );

  // -- Tutorials On/Off --
  Widget _tutorialToggle(SharedPreferences prefs) => SwitchListTile(
    activeColor: Colors.white,
    contentPadding: const EdgeInsets.all(0),
    value: prefs.getBool('tutorial_on') ?? false,
    onChanged: (bool value) {
      setState(() {
        if (value) {
          widget.tutorialModel.turnOnAllTutorials();
          prefs.setBool('tutorial_on', true);
        } else {
          widget.tutorialModel.turnOffAllTutorials();
          prefs.setBool('tutorial_on', false);
        }
      });
    },
    title: Text(FlutterI18n.translate(context, "settings.tutorial.text"),
        textScaleFactor: 1.1, style: TextStyle(color: Colors.white)),
  );
}
