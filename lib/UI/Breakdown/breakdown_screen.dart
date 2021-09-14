import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../Settings/settings_btn.dart';
import '../drawer.dart';
import '../are_you_sure_you_want_to_exit.dart';
import '../Tutorials/tutorial.dart';

import '../../Database/missing_person_database.dart';
import '../../Database/tutorial_database.dart';

import 'Chart/chart_selector.dart';

import 'Data Table/data_table.dart';
import 'breakdown_func.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

class Breakdown extends StatelessWidget {
  final MissingPeopleModel missingPerson = MissingPeopleModel();
  final TutorialModel tutorialModel = TutorialModel();
  final BreakdownFunc _breakdownFunc = BreakdownFunc();
  final int _numOfTabs = 2;

  void _tutorial(BuildContext context) async {
    bool showTutorial =
        await tutorialModel.getTutorialSettingFor("breakdownPage");
    if (showTutorial) {
      await showDialog(
        context: context,
        child: TutorialDialog("breakdownPage"),
      );
    }
  }

  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _tutorial(context);
    return _tabs(context);
  }

  // ------------------------------------------------------------------

  Widget _tabs(BuildContext context) => DefaultTabController(
    length: _numOfTabs,
    child: Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "drawer.breakdown")),
        actions: [SettingsBtn()],
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.table_chart)),
            Tab(icon: Icon(Icons.stacked_line_chart)),
          ],
        ),
      ),
      drawer: DrawerMenu(),
      body: _areYourSureYouWantToExitWarpper(),
  ));

  Widget _areYourSureYouWantToExitWarpper() => Builder(
    builder: (context) => WillPopScope(
      child: _futureTable(),
      onWillPop: () async {
        bool value = await showDialog<bool>(
            context: context, builder: (context) => ExitDialog());
        return value;
      }
    )
  );

  // ---------------------------------------------------------

  Widget _futureTable() => FutureBuilder(
    future: missingPerson.getAllPeople(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data.length > 0) {
          _breakdownFunc.people = snapshot.data;

          return _mainTabBarView();
        } else {
          return _waitingForMainViewTabBarView('Empty');
        }
      } else {
        return _waitingForMainViewTabBarView('Loading');
      }
    },
  );

  Widget _mainTabBarView() => TabBarView(
    dragStartBehavior: DragStartBehavior.down,
    children: [
      BreakdownTable(_breakdownFunc),
      ChartSelector(_breakdownFunc),
    ],
  );

  Widget _waitingForMainViewTabBarView(String type) => TabBarView(
    children: _loadingText(type),
  );

  List<Widget> _loadingText(String type) {
    List<Widget> text = [];
    for (int i = 0; i < _numOfTabs; i++) {
      text.add(Text(type));
    }
    return text;
  }
}
