import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

// Popup map box in the dialog
class MapBox extends StatelessWidget {
  // Map controller, the location (you or the person), the person image
  final MapController _mapController;
  final _locations;
  final String url;

  MapBox(this._mapController, this._locations, this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: _mapBox(),
    );
  }

  Widget _mapBox() => FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      minZoom: 10.0,
      center: LatLng(
        _locations.yourPos.latitude,
        _locations.yourPos.longitude,
      ),
    ),
    layers: [
      _openMapLayer(),
      _markerLayer(),
      _polyLineLayer(),
    ],
  );

  // --------------------------------------------------------------
  // Map Layer, Marker Layer and Lines Layer

  // Map Layers
  TileLayerOptions _openMapLayer() => TileLayerOptions(
    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
  );

  // Marker Layer
  MarkerLayerOptions _markerLayer() {
    // The direct distance between you and the person in Km
    int distanceInMeters = Geolocator.distanceBetween(
          _locations.yourPos.latitude,
          _locations.yourPos.longitude,
          _locations.missingPersonLoc.latitude,
          _locations.missingPersonLoc.longitude,
        ) ~/
        1000.0;
    return MarkerLayerOptions(markers: [
      _yourLocMarker(),
      _missingPersonMarker(distanceInMeters),
    ]);
  }

  // Line Layer
  PolylineLayerOptions _polyLineLayer() => PolylineLayerOptions(polylines: [
    _lineBetweenYouAndMissingPerson(),
  ]);

  // --------------------------------------------------------------
  // Markers

  // Your marker
  Marker _yourLocMarker() => Marker(
    width: 80,
    height: 80,
    point:
        LatLng(_locations.yourPos.latitude, _locations.yourPos.longitude),
    builder: (context) => Icon(
      Icons.home,
      color: Colors.brown,
      size: 80,
    ),
  );

  // The person marker
  Marker _missingPersonMarker(int distanceInMeters) => Marker(
    width: 200,
    height: 200,
    point: LatLng(_locations.missingPersonLoc.latitude,
        _locations.missingPersonLoc.longitude),
    builder: (context) => Column(
      children: [
        _missingPersonDistance(distanceInMeters),
        _missingPersonAvatar(),
      ],
    )
  );

  // The person marker avatar distance text
  Widget _missingPersonDistance(int distanceInMeters) => Flexible(
    child: Text(
      "$distanceInMeters KM",
      style: TextStyle(
        color: Colors.white,
        backgroundColor: Colors.brown,
      ),
    )
  );

  // The person marker avatar image
  Widget _missingPersonAvatar() => Flexible(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network(url,
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) => Icon(
          Icons.person,
          color: Colors.brown,
          size: 80,
        )
      ),
    ),
  );

  // --------------------------------------------------------------
  // Line

  Polyline _lineBetweenYouAndMissingPerson() => Polyline(
    points: [
      LatLng(_locations.yourPos.latitude, _locations.yourPos.longitude),
      LatLng(_locations.missingPersonLoc.latitude,
          _locations.missingPersonLoc.longitude),
    ],
    isDotted: true,
    color: Colors.red,
    strokeWidth: 10,
  );
}
