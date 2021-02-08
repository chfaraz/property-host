import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoder/services/base.dart';
import 'package:location/location.dart';
import "package:latlong/latlong.dart" as latLng;

import 'navigation.dart';

class LocateAgent extends StatefulWidget {
  final double lat, long;
  const LocateAgent({Key key, this.lat, this.long}) : super(key: key);
  @override
  _LocateAgent createState() => _LocateAgent(this.lat, this.long);
}

class AppState extends InheritedWidget {
  const AppState({
    bool checkedSchool,
    bool checkedHospital,
    Key key,
    this.mode,
    Widget child,
  })  : assert(mode != null),
        assert(child != null),
        super(key: key, child: child);

  final Geocoding mode;

  static AppState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppState);
  }

  @override
  bool updateShouldNotify(AppState old) => mode != old.mode;
}

class _LocateAgent extends State<LocateAgent> {
  double lat, long;
  _LocateAgent(this.lat, this.long);

  String token = 'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  Stream search;
  var infoWindowVisible = false;

  GlobalKey<FormState> _key = new GlobalKey();
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;

  List<Marker> allmarkers = List<Marker>();
  Location location = new Location();
  latLng.LatLng center;

  @override
  void initState() {

  }

  @override
  void dispose() {
    super.dispose();
  }

  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[marker()],
    );
  }

  marker() {
    return Icon(Icons.accessibility);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }

  MapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        /* floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: Color(0xFF737373),
                    child: Container(
                      child: _bottomLayerMenu(),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),*/
        backgroundColor: Colors.grey[600],
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Property Host'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
            ),
          ),
        ),
        body: FlutterMap(
          options: new MapOptions(
            plugins: [
              MarkerClusterPlugin(),
            ],
            zoom: 12,
            minZoom: 8.0,
            maxZoom: 18.0,
            interactive: true,
            center: new latLng.LatLng(widget.lat, widget.long), /*new LatLng(33.692705, 73.047778)*/
          ),
          layers: [
            new TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mawais/ckhbnqs160ohy19kbat8opzj3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGE2bHhkaDA5MDAydHJzMGMxZG1jeWkifQ.K_7JYzNOsuRLWyOhiw7EJQ",
                additionalOptions: {'accessToken': token, 'id': 'mapbox.mapbox-streets-v8'}),
            MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              size: Size(30, 30),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: [
                new Marker(
                  point: latLng.LatLng(widget.lat, widget.long),
                  builder: (context) => GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                height: 180,
                                color: Color(0xFF737373),
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      /*ListTile(
                                                          leading: Icon(
                                                              Icons.details),
                                                          title: Text(
                                                              'View Detail'),
                                                          onTap: () => Navigator
                                                              .of(context)
                                                              .pushNamed(
                                                              ImageCarousel
                                                                  .routeName,
                                                              arguments: ScreenArguments(
                                                                  snapshot.data.documents[i].documentID.toString(), snapshot.data.documents[i].data['uid'].toString()))),*/
                                      ListTile(
                                        leading: Icon(Icons.directions),
                                        title: Text('Navigate to Agent'),
                                        onTap: () {
                                          // double lat = snapshot.data.documents[i].data['Location'].latitude;
                                          // double long = snapshot.data.documents[i].data['Location'].longitude;

                                          //   Navigator.pushNamed(context, '/navigation');
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: widget.lat, longitude: widget.long)));
                                        },
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            });
                        debugPrint("Tapp tapp loot ka no mazak");
                      },
                      child: _buildCustomMarker()),
                )
              ],
              polygonOptions: PolygonOptions(borderColor: Colors.blueAccent, color: Colors.black12, borderStrokeWidth: 3),
              builder: (context, markers) {
                return FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: null,
                );
              },
            ),
          ],
        )
        );
  }
}
