import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'popup_map_actions.dart';
import 'popup_map_box.dart';

// class hold the view and each person position
class Locations {
  String currentView = "You";
  Location missingPersonLoc;
  Position yourPos;
}

// Popup map dialog
class PopUpMap extends StatelessWidget {
  final MapController _mapController = MapController();
  final Locations _locations = Locations();

  // Missing person city, province and url
  final String city;
  final String province;
  final String url;

  PopUpMap(this.city, this.province, this.url);

  // get the missing person lat lng from their city and province
  Future _getMissingPersonLatLng() async {
    List<Location> locations;

    try {
      locations = await locationFromAddress(
          "$city, ${province != '--' ? province : ''}");
    } catch (e) {
      print(e);
    }

    return locations;
  }

  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Map"),
      content: _futureMap(),
      actions: [
        MapActions(
          _mapController,
          _locations,
        )
      ],
    );
  }

  // --------------------------------------------------------------
  // Future handlers

  // Wait for your current position
  Widget _futureMap() {
    Future<Position> position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return FutureBuilder(
      future: position,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _locations.yourPos = snapshot.data;
          return _futureMissingPersonLatLng();
        } else {
          return _loadingStatus(snapshot.connectionState);
        }
      },
    );
  }

  // Wait for the missing person lat lng
  Widget _futureMissingPersonLatLng() => FutureBuilder(
        future: _getMissingPersonLatLng(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _locations.missingPersonLoc = snapshot.data[0];
            return MapBox(_mapController, _locations, url);
          } else {
            return _loadingStatus(snapshot.connectionState);
          }
        },
      );

  // --------------------------------------------------------------
  // widget when you are waiting
  Widget _loadingStatus(ConnectionState connectionState) {
    if (connectionState == ConnectionState.waiting)
      return Center(child: CircularProgressIndicator());
    else
      return Center(child: Text("Location was not found"));
  }
}
