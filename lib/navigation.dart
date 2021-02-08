import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class Navigation extends StatefulWidget {
  final double latitude, longitude;
  // final FirebaseUser user;
  const Navigation({Key key, this.latitude, this.longitude}) : super(key: key);

  @override
  _Navigation createState() => _Navigation(this.latitude, this.longitude);
}

class _Navigation extends State<Navigation> {
  double lat, long;
  _Navigation(this.lat, this.long);

  final String token =
      'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNra2xqc2M4YzJoZm0ydW1uNm53Z3ZyOXEifQ.p50Gpf15pef91BNEnneRuQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  LatLng userlocation;
  Location location = new Location();

  String _platformVersion = 'Unknown';
  String _instruction = "";
  final _origin = WayPoint(
      name: "Way Point 1",
      latitude: 38.9111117447887,
      longitude: -77.04012393951416);
  final _stop1 = WayPoint(
      name: "Way Point 2",
      latitude: 38.91113678979344,
      longitude: -77.03847169876099);
  final _stop2 = WayPoint(
      name: "Way Point 3",
      latitude: 38.91040213277608,
      longitude: -77.03848242759705);
  final _stop3 = WayPoint(
      name: "Way Point 4",
      latitude: 38.909650771013034,
      longitude: -77.03850388526917);
  final _stop4 = WayPoint(
      name: "Way Point 5",
      latitude: 38.90894949285854,
      longitude: -77.03651905059814);
  final _farAway = WayPoint(
      name: "Far Far Away", latitude: 36.1175275, longitude: -115.1839524);

  MapBoxNavigation _directions;
  MapBoxNavigationViewController _controller;
  MapBoxOptions _options;
  bool _arrived = false;
  bool _userOffROute = false;
  bool _fasterRouteFound = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  var wayPoints = List<WayPoint>();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Text('Start',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await _directions.startNavigation(
                    wayPoints: wayPoints, options: _options);
              },
            ),
            backgroundColor: Colors.grey[650],
            resizeToAvoidBottomPadding: true,
            body: SizedBox(
              child: MapboxMap(
                accessToken: token,
                styleString: style,
                initialCameraPosition: CameraPosition(
                  zoom: 15.0,
                  target: LatLng(30.3753, 69.3451),
                ),
                onMapCreated: (MapboxMapController controller) async {
                  userlocation = await _determinePosition();

                  debugPrint(userlocation.toString() +
                      " Here is cordinates of user location");

                  location.onLocationChanged
                      .listen((LocationData currentLocation) async {
                    if (!mounted) return;
                    setState(() {
                      wayPoints.clear();
                      userlocation = LatLng(
                          currentLocation.latitude, currentLocation.longitude);
                      wayPoints.add(WayPoint(
                          latitude: userlocation.latitude,
                          longitude: userlocation.longitude,
                          name: "User"));
                      wayPoints.add(WayPoint(
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          name: "Destination"));
                      print(wayPoints.toString() + " here waypoints");
                    });

                    await controller.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(userlocation.latitude, userlocation.longitude),
                      ),
                    );

                    await controller.addCircle(
                      CircleOptions(
                        circleRadius: 10.0,
                        circleColor: '#4d94ff',
                        circleOpacity: 1,
                        geometry: LatLng(
                            userlocation.latitude, userlocation.longitude),
                        draggable: false,
                      ),
                    );
                  });
                  /* wayPoints.add(WayPoint(latitude: widget.latitude, longitude: widget.longitude, name: "Destination"));
                  wayPoints.add(WayPoint(latitude: userlocation.latitude, longitude: userlocation.longitude, name: "User"));

                 var root =  await _controller.buildRoute(wayPoints: wayPoints);

                 print(root.toString() + "Root build");*/
                },
              ),

              /*MapBoxNavigationView(
                options: _options,
                  onCreated: (MapBoxNavigationViewController controller) async {
                   _controller =controller;
                   controller.initialize();

                  }),
*/
            )));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: 73.1839524,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        animateBuildRoute: true,
        longPressDestinationEnabled: false,
        language: "en");

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;
    _distanceRemaining = await _controller.distanceRemaining;
    _durationRemaining = await _controller.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.user_off_route:
        setState(() {
          _userOffROute = true;
        });
        break;
      case MapBoxEvent.faster_route_found:
        setState(() {
          _fasterRouteFound = true;
        });
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  _determinePosition() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    return LatLng(_locationData.latitude, _locationData.longitude);
  }
}
