import 'package:flutter/material.dart';

import '../Settings/settings_btn.dart';
import '../Search Bar/search_bar.dart';
import '../drawer.dart';
import '../are_you_sure_you_want_to_exit.dart';

import 'saved_person_list.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

// Save Person Screen Main Page
class SavedPersonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _scaffold(context);
  }

  Widget _scaffold(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(FlutterI18n.translate(context, "drawer.saved")),
      actions: [SettingsBtn()],
    ),
    drawer: DrawerMenu(),
    backgroundColor: Colors.brown[900],
    body: _areYourSureYouWantToExitWarpper(),
  );

  Widget _areYourSureYouWantToExitWarpper() => Builder(
    builder: (context) => WillPopScope(
      child: Column(
        children: [
          Row(
            children: [
              SearchBar(),
            ],
          ),
          SavedPersonList(),
        ]
      ),
      onWillPop: () async {
        bool value = await showDialog<bool>(
            context: context, builder: (context) => ExitDialog());
        return value;
      }
    )
  );
}
