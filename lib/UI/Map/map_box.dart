import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'map_dialog.dart';

class MapBox extends StatelessWidget {
  final List people;
  final MapController _mapController;

  MapBox(this.people, this._mapController);

  Future _missingPeopleDialog(BuildContext scaffoldContext) async =>
    await showDialog(
      context: scaffoldContext,
      builder: (_) {
        return MapDialog(people);
      }
    );

  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Future<Position> position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return FutureBuilder(
      future: position,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _mapBox(snapshot.data, context);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // --------------------------------------------------------------

  Widget _mapBox(Position loc, BuildContext scaffoldContext) => FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      minZoom: 10.0,
      center: LatLng(loc.latitude, loc.longitude),
    ),
    layers: [
      _openMapLayer(),
      _markerLayer(loc, scaffoldContext),
    ],
  );

  TileLayerOptions _openMapLayer() => TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
      );

  MarkerLayerOptions _markerLayer(Position loc, BuildContext scaffoldContext) =>
    MarkerLayerOptions(
      markers: [_cityMarkerHandler(loc, scaffoldContext)]
    );

  Marker _cityMarkerHandler(Position loc, BuildContext scaffoldContext) =>
    people.isNotEmpty
        ? _cityMissingPeopleMarker(loc, scaffoldContext)
        : Marker();

  Marker _cityMissingPeopleMarker(Position loc, BuildContext scaffoldContext) =>
    Marker(
      width: 80,
      height: 80,
      point: LatLng(loc.latitude, loc.longitude),
      builder: (context) => IconButton(
        icon: Icon(
          Icons.people,
          color: Colors.brown,
        ),
        onPressed: () => _missingPeopleDialog(scaffoldContext),
        iconSize: 80,
      )
    );
}
