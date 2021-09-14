import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Database/missing_person_database.dart';
import '../../Database/tutorial_database.dart';

import '../drawer.dart';
import '../are_you_sure_you_want_to_exit.dart';
import '../Tutorials/tutorial.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

class SyncScreen extends StatelessWidget {
  final TutorialModel tutorialModel = TutorialModel();

  SyncScreen();

  void _tutorial(BuildContext context) async {
    bool showTutorial = await tutorialModel.getTutorialSettingFor("syncPage");
    if (showTutorial) {
      await showDialog(
        context: context,
        child: TutorialDialog("syncPage"),
      );
    }
  }

  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    MissingPeopleModel missingPeopleModel = context.watch<MissingPeopleModel>();

    return _scaffold(missingPeopleModel, context);
  }

  Widget _scaffold(
          MissingPeopleModel missingPeopleModel, BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "drawer.sync")),
      ),
      drawer: DrawerMenu(),
      backgroundColor: Colors.brown[900],
      body: _areYourSureYouWantToExitWrapper(missingPeopleModel),
    );

  // ------------------------------------------------------------------

  Widget _areYourSureYouWantToExitWrapper(
          MissingPeopleModel missingPeopleModel) =>
    Builder(
      builder: (context) => WillPopScope(
        child: _body(missingPeopleModel),
        onWillPop: () async {
          bool value = await showDialog<bool>(
              context: context, builder: (context) => ExitDialog());
          return value;
        }
      )
    );

  Widget _body(MissingPeopleModel missingPeopleModel) {
    return Builder(
      builder: (context) {
        _tutorial(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _localDbStatusText(missingPeopleModel),
            _btns(missingPeopleModel),
            _backToMainPageBtn(),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------

  Widget _localDbStatusText(MissingPeopleModel missingPeopleModel) =>
    FutureBuilder(
      future: missingPeopleModel.isDbEmpty(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data) {
            return Text(
              "Local DB is Empty",
              style: TextStyle(color: Colors.white),
              textScaleFactor: 2,
            );
          } else {
            return Text(
              "Local DB is Sync",
              style: TextStyle(color: Colors.white),
              textScaleFactor: 2,
            );
          }
        } else {
          return Text(
            "Loading Status....",
            style: TextStyle(color: Colors.white),
            textScaleFactor: 2,
          );
        }
      },
    );

  // ----------------------------------------------------

  Widget _btns(MissingPeopleModel missingPeopleModel) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        _refreshBtn(missingPeopleModel),
        SizedBox(height: 10),
        _downloadBtn(missingPeopleModel),
        SizedBox(height: 10),
        _deleteBtn(missingPeopleModel),
        SizedBox(height: 10),
      ],
    ),
  );

  Widget _refreshBtn(MissingPeopleModel missingPeopleModel) =>
    FloatingActionButton(
      child: Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      onPressed: () => missingPeopleModel.refreshLocalDb(),
      heroTag: "btn1",
    );

  Widget _downloadBtn(MissingPeopleModel missingPeopleModel) =>
    FloatingActionButton(
      child: Icon(
        Icons.cloud_download,
        color: Colors.white,
      ),
      onPressed: () => missingPeopleModel.downloadAllPeopleToDb(),
      heroTag: "btn2",
    );

  Widget _deleteBtn(MissingPeopleModel missingPeopleModel) =>
    FloatingActionButton(
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () => missingPeopleModel.deleteAllPeople(),
      heroTag: "btn3",
    );

  // ----------------------------------------------------

  Widget _backToMainPageBtn() => Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/missing'),
      child: Text("To Main Page"),
    ),
  );
}
