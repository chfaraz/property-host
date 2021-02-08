import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ChoseOnMap extends StatefulWidget {
  // final FirebaseUser user;

  @override
  _ChoseOnMap createState() => _ChoseOnMap();
}

class _ChoseOnMap extends State<ChoseOnMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapSample(),
    );
  }
}

double lat;
double lng;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  onCreaate() async {
    await _determinePosition();
  }

  Location location = new Location();
  LatLng result = LatLng(33.616780, 72.972136);
  LatLng cordinates;
  @override
  void initState() {
    super.initState();
  }

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor _markerIcon;

  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Text('OK',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        onPressed: () {
          double lat = cordinates.latitude;
          double long = cordinates.longitude;
          GeoPoint geopoint = new GeoPoint(lat, long);
          Navigator.pop(context, geopoint);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(result.latitude, result.longitude),
          zoom: 18.4746,
        ),
        onMapCreated: (GoogleMapController controller) async {
          await _determinePosition();
          location.onLocationChanged.listen((LocationData currentLocation) {
            if (!mounted) return;
          });
          await controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(result.latitude, result.longitude)),
          );
          setState(() {
            cordinates = LatLng(result.latitude, result.longitude);
          });
        },
        markers: _createMarker(),
      ),
    );
  }

  Set<Marker> _createMarker() {
    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    return <Marker>[
      Marker(
          markerId: MarkerId("marker_1"),
          position: LatLng(result.latitude, result.longitude),
          icon: _markerIcon,
          draggable: true,
          infoWindow: const InfoWindow(
            title: 'hold and drag this marker to your property',
          ),
          onDragEnd: ((newPosition) {
            print(newPosition.latitude);
            print(newPosition.longitude);
            setState(() {
              cordinates = LatLng(newPosition.latitude, newPosition.longitude);
            });
          })),
    ].toSet();
  }

  _determinePosition() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      result = LatLng(_locationData.latitude, _locationData.longitude);
    });
  }
}
