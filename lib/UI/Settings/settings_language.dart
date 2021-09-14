import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettings extends StatelessWidget {
  final Function reloadParent;

  LanguageSettings(this.reloadParent);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _languageSettings(snapshot.data);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  // ------------------------------------------------------------------

  // -- Language Settings --
  //options: english and french
  Widget _languageSettings(SharedPreferences prefs) => Builder(
    builder: (context) => Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.brown[300], spreadRadius: 3),
        ],
      ),
      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
      child: Column(children: <Widget>[
        Text(
          FlutterI18n.translate(
              context, "settings.language"), //section header
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Column(children: <Widget>[
          _english(prefs),
          _french(prefs),
        ]),
      ])
    )
  );

  // -- English --
  Widget _english(SharedPreferences prefs) => Builder(
    builder: (context) => SizedBox(
      width: double.infinity,
      child: OutlineButton(
        color: Colors.brown[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'English',
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.white),
            ),
            //display checkbox if language is selected
            (prefs.getString('language') == "en")
                ? Icon(Icons.check, color: Colors.white)
                : Text(""),
            ]),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          onPressed: () async {
            //set the stored language and current locale to english
            print('Language Select: English');
            prefs.setString("language", "en"); //set stored language
            Locale newLocale = Locale('en'); //set current locale
            await FlutterI18n.refresh(context, newLocale);
            reloadParent();
          }
        )
      )
    );

  // -- French --
  Widget _french(SharedPreferences prefs) => Builder(
    builder: (context) => SizedBox(
      width: double.infinity,
      child: OutlineButton(
        color: Colors.brown[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Français',
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.white),
            ),
            //display checkbox if language is selected
            (prefs.getString('language') == "fr")
                ? Icon(Icons.check, color: Colors.white)
                : Text(""),
          ]),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        onPressed: () async {
          //set the stored language and current locale to french
          print('Language Select: French');
          prefs.setString("language", "fr"); //set stored language
          Locale newLocale = Locale('fr'); //set current locale
          await FlutterI18n.refresh(context, newLocale);
          reloadParent();
        }
      )
    )
  );
}
