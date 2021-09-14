import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong/latlong.dart';

import '../../Database/missing_person_database.dart';
import '../../Database/tutorial_database.dart';

import '../Settings/settings_btn.dart';
import '../drawer.dart';
import '../are_you_sure_you_want_to_exit.dart';
import '../Tutorials/tutorial.dart';

import 'map_box.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

class MapScreen extends StatefulWidget {
  final MissingPeopleModel missingPeopleModel = MissingPeopleModel();
  final TutorialModel tutorialModel = TutorialModel();
  final MapController mapController = MapController();

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String city = '';
  String province = '';

  void _tutorial(BuildContext context) async {
    bool showTutorial =
        await widget.tutorialModel.getTutorialSettingFor("mapPage");
    if (showTutorial) {
      await showDialog(
        context: context,
        child: TutorialDialog("mapPage"),
      );
    }
  }

  void _moveMapCenter(Position position) {
    var currentZoom = widget.mapController.zoom;
    widget.mapController.move(
      LatLng(position.latitude, position.longitude),
      currentZoom,
    );
  }

  void _reDrawWhenALocationIsSet(String _city, String _province) {
    if (_city.isNotEmpty) {
      setState(() {
        city = _city;
        province = _province;
      });
    }
  }

  String _getProvinceShortCode(String province) {
    if (province == "Ontario")
      return "ON";
    else if (province == "British Columbia")
      return "BC";
    else if (province == "Québec")
      return "QC";
    else if (province == "Manitoba")
      return "MB";
    else if (province == "Saskatchewan")
      return "SK";
    else if (province == "Alberta")
      return "AB";
    else if (province == "Yukon")
      return "YK";
    else if (province == "Northwest Territories")
      return "NT";
    else if (province == "Nunavut")
      return "NU";
    else if (province == "Newfoundland &amp; Labrador")
      return "NL";
    else if (province == "Nova Scotia")
      return "NS";
    else if (province == "New Brunswick")
      return "NB";
    else if (province == "Prince Edward Island")
      return "PE";
    else
      return "";
  }

  Future<Map> _getCurrentlocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> address =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    return {
      'pos': position,
      'city': address[0].locality,
      'province': _getProvinceShortCode(address[0].administrativeArea)
    };
  }

  void _setCurrentLocation() async {
    String _city = "";
    String _province = "";
    try {
      Map locs = await _getCurrentlocation();
      _moveMapCenter(locs['pos']);
      _city = locs['city'];
      _province = locs['province'];
    } catch (e) {
      print("ERROR");
    }

    _reDrawWhenALocationIsSet(_city, _province);
  }

  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _tutorial(context);
    return _scaffold();
  }

  Widget _scaffold() => Scaffold(
    appBar: AppBar(
      title: Text(FlutterI18n.translate(context, "drawer.map")),
      actions: [SettingsBtn()],
    ),
    drawer: DrawerMenu(),
    body: _areYourSureYouWantToExitWrapper(),
    floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add), onPressed: () => _setCurrentLocation()),
  );

  Widget _areYourSureYouWantToExitWrapper() => Builder(
    builder: (context) => WillPopScope(
      child: _futureMap(),
      onWillPop: () async {
        bool value = await showDialog<bool>(
            context: context, builder: (context) => ExitDialog());
        return value;
      }
    )
  );

  Widget _futureMap() => FutureBuilder(
    future: widget.missingPeopleModel.getPeopleWhereCityAndProvince(
      city,
      province: province,
    ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return MapBox(snapshot.data, widget.mapController);
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}
