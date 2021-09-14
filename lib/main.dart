import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'UI/Missing Person/missing_person_screen.dart';
import 'UI/Map/map_screen.dart';
import 'UI/Saved/saved_person_screen.dart';
import 'UI/Breakdown/breakdown_screen.dart';
import 'UI/Sync/sync_screen.dart';

import 'UI/Settings/settings.dart';

import 'Database/saved_people_database.dart';
import 'Database/filter_by_date_model.dart';
import 'Database/selected_item_model.dart';
import 'Database/missing_person_database.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- USER SETTINGS INITIALIZATION ---

  //get language stored on disk
  final prefs = await SharedPreferences.getInstance();
  String language = prefs.getString('language') ?? "none";

  //if language does not exist on disk, the app is being run for the first time
  //perform some basic setup
  if (language == "none") {
    // -- Language Settings --
    print(
        "No language selected, using default: ${Platform.localeName.substring(0, 2)}.");
    language =
        Platform.localeName.substring(0, 2); //get language code from device
    if (language == "en" || language == "fr")
      prefs.setString("language",
          language); //if device default is en/fr, set language to device default
    else
      prefs.setString("language",
          "en"); //if device default is anything else, set language to en

    // -- Notification Settings --
    //enable all notifications by default
    prefs.setBool("notifications_scheduled", true);
    prefs.setBool("notifications_featured", true);

    // -- Tutorial Settings --
    //enable tutorials by default
    prefs.setBool("tutorial_on", true);
  } else {
    print(
        "Selected language is: $language"); //print selected language to console
  }

  //load internationalization files
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      forcedLocale: Locale(
          language), //force the language to be the stored language chosen in settings
      decodeStrategies: [JsonDecodeStrategy()],
      basePath: 'assets/flutter_i18n',
    ),
  );
  await flutterI18nDelegate.load(Locale(language));

  //run app with providers
  runApp(MultiProvider(
    providers: [
      // Listener for when the Local DB is synced
      ChangeNotifierProvider(create: (_) => MissingPeopleModel()),
      // Listener for when someone is saved
      ChangeNotifierProvider(create: (_) => SavedPeopleModel()),
      // Listener for when a date to filter by is picked
      ChangeNotifierProvider(create: (_) => DateModel()),
      // Listener for when people are save and to deselect them
      ChangeNotifierProvider(create: (_) => SelectedPeopleModel()),
    ],
    child: MyApp(flutterI18nDelegate),
  ));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();

    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "Error initializing database",
            textDirection: TextDirection.ltr,
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Main
          return _checkIfDbIsEmpty();
        } else {
          // Before Start up loading Screen
          return _loadingIcon();
        }
      }
    );
  }

  Widget _checkIfDbIsEmpty() {
    MissingPeopleModel missingPeopleModel = MissingPeopleModel();

    return FutureBuilder(
      future: missingPeopleModel.isDbEmpty(),
      builder: (_, dbSnapshot) {
        if (dbSnapshot.hasData) {
          if (dbSnapshot.data) {
            return _startingPageIs("sync");
          } else {
            return _startingPageIs("missing");
          }
        } else {
          // Waiting for if local DB is empty
          return _loadingIcon();
        }
      }
    );
  }

  Widget _loadingIcon() => Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: Colors.white,
          ),
          Text("Loading"),
        ],
      )
    )
  );

  Widget _startingPageIs(String main) => MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.brown,
    ),
    initialRoute: '/' + main,
    routes: {
      '/sync': (context) => SyncScreen(),
      '/missing': (context) => MissingPerson(),
      '/map': (context) => MapScreen(),
      '/saved': (context) => SavedPersonScreen(),
      '/charts': (context) => Breakdown(),
      '/settings': (context) => Settings(),
    },
    localizationsDelegates: [
      flutterI18nDelegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en'),
      const Locale('fr'),
    ],
  );
}
