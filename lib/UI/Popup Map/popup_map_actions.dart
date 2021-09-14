import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

// The Pop up map actions buttons
class MapActions extends StatelessWidget {
  final MapController _mapController;
  final _locations;

  MapActions(this._mapController, this._locations);

  // Move the map when you press the next button
  void _moveView() async {
    await _mapController.onReady;
    double curZoom = _mapController.zoom;

    LatLng newCenter;

    if (_locations.currentView == "You") {
      _locations.currentView = "Them";
      newCenter = LatLng(
        _locations.missingPersonLoc.latitude,
        _locations.missingPersonLoc.longitude,
      );
    } else {
      _locations.currentView = "You";
      newCenter = LatLng(
        _locations.yourPos.latitude,
        _locations.yourPos.longitude,
      );
    }

    _mapController.move(newCenter, curZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => _moveView(),
          child: Text("Next"),
        ),
        SizedBox(width: 20),
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Exit"),
          ),
        ),
      ],
    );
  }
}
