import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../drawer.dart';
import '../are_you_sure_you_want_to_exit.dart';

import 'settings_language.dart';
import 'settings_notification.dart';
import 'settings_tutorial.dart';

class Settings extends StatefulWidget {
  @override
  SettingsPage createState() => SettingsPage();
}

class SettingsPage extends State<Settings> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(FlutterI18n.translate(context, "settings.title"))),
      drawer: DrawerMenu(),
      backgroundColor: Colors.brown[900],
      body: _areYourSureYouWantToExitWarpper(),
    );
  }

  Widget _areYourSureYouWantToExitWarpper() => Builder(
    builder: (context) => WillPopScope(
      child: _body(),
      onWillPop: () async {
        bool value = await showDialog<bool>(
            context: context, builder: (context) => ExitDialog());
        return value;
      }
    )
  );

  Widget _body() => SingleChildScrollView(
    child: Container(
        margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LanguageSettings(refresh), //widget for language settings
            NotificationSettings(), //widget for notification settings
            TutorialSettings(), //widget for tutorial settings
          ],
        )
      )
    );
}
