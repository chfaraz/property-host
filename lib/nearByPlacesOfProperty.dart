import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:signup/services/PostAdCreation.dart';

class NearByPlacesOfProperty extends StatefulWidget {
  final double lat, long;
  const NearByPlacesOfProperty({Key key, this.lat, this.long}) : super(key: key);
  @override
  _NearByPlacesOfProperty createState() => _NearByPlacesOfProperty(this.lat, this.long);
}

class _NearByPlacesOfProperty extends State<NearByPlacesOfProperty> {
  double lat, long;
  _NearByPlacesOfProperty(this.lat, this.long);

  String token = 'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  Stream search;
  var infoWindowVisible = false;
  var redrawObject;

  latLng.LatLng _lastposition;
  double x1;
  double y1;
  double x2;
  double y2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;

  List<Marker> allmarkers = List<Marker>();
  String selectedButton = 'Schools';
  bool school = true;
  bool hospital = false;
  bool park = false;

  @override
  void initState() {
    x1 = widget.lat + 0.014;
    y1 = widget.long + 0.014;
    x2 = widget.lat - 0.014;
    y2 = widget.long - 0.014;
    super.initState();
    getSchools();
    print(x1.toString() + y1.toString());
    print(x2.toString() + y2.toString());
    print(widget.lat.toString() + widget.long.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSchools() async {
    PostAddFirebase().getCordinatesOfSchoolsRefresh(x1, y1, x2, y2).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  getHospitals() async {
    PostAddFirebase().getCordinatesOfHospitalsRefresh(x1, y1, x2, y2).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  getParks() async {
    PostAddFirebase().getCordinatesOfParksRefresh(x1, y1, x2, y2).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[marker()],
    );
  }

  marker() {
    if (selectedButton == 'Schools') {
      return Icon(
        Icons.school,
        color: Colors.blue[400],
      );
    } else if (selectedButton == 'Hospitals') {
      return Icon(
        Icons.local_hospital,
        color: Colors.pink,
      );
    } else if (selectedButton == 'Parks') {
      return Icon(
        Icons.local_parking,
        color: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedButton == 'Schools') {
      school = true;
      hospital = false;
      park = false;
    } else if (selectedButton == 'Hospitals') {
       school = false;
      hospital = true;
      park = false;
    } else if (selectedButton == 'Parks') {
       school = false;
      hospital = false;
      park = true;
    }
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.blue,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Center(child: Text('Property Host')),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        selectedButton = 'Schools';
                        print("Schools tapped");
                        getSchools();
                      },
                      child: Text("Schools"),
                      color: school ? Colors.blue[300] : Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        selectedButton = 'Hospitals';
                        print("hospitals tapped");
                        getHospitals();
                      },
                      child: Text('Hospitals'),
                      color: hospital ? Colors.pink[300] : Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        selectedButton = 'Parks';
                        print("parks tapped");
                        getParks();
                      },
                      child: Text('Parks'),
                      color: park ? Colors.green : Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                ],
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 1.23,
                    child: Stack(
                      children: <Widget>[
                        StreamBuilder(
                            stream: search,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                                );
                              allmarkers = [];
                              //   debugPrint(snapshot.data.documents.length.toString());
                              allmarkers.add(new Marker(
                                point: latLng.LatLng(widget.lat, widget.long),
                                builder: (context) => GestureDetector(
                                    onTap: () {
                                      debugPrint("Tapp tapp loot ka no mazak");
                                    },
                                    child: Icon(
                                      Icons.home,
                                      color: Colors.black,
                                    )),
                              ));
                              for (int i = 0; i < snapshot.data.documents.length; i++) {
                                double lat = snapshot.data.documents[i]['Location'].latitude;
                                double lng = snapshot.data.documents[i]['Location'].longitude;
                                if (lng < y1 && lng > y2) {
                                  allmarkers.add(new Marker(
                                    point: latLng.LatLng(lat, lng),
                                    builder: (context) => GestureDetector(
                                        onTap: () {
                                          debugPrint(snapshot.data.documents.elementAt(i)['name']);
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  color: Color(0xFF737373),
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Container(
                                                          child: ListTile(
                                                            title: Text(snapshot.data.documents.elementAt(i)['name']),
                                                            onTap: () {},
                                                          ),
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
                                        },
                                        child: _buildCustomMarker()),
                                  ));
                                }
                              }

                              return FlutterMap(
                                options: new MapOptions(
                                    zoom: 14,
                                    minZoom: 5.0,
                                    maxZoom: 18.0,
                                    interactive: true,
                                    center: new latLng.LatLng(widget.lat, widget.long),
                                    onPositionChanged: (mapPosition, boolValue) {
                                      _lastposition = mapPosition.center;
                                      x1 = _lastposition.latitude + 0.014;
                                      y1 = _lastposition.longitude + 0.014;
                                      x2 = _lastposition.latitude - 0.014;
                                      y2 = _lastposition.longitude - 0.014;
                                      Future.delayed(const Duration(milliseconds: 2000), () {
                                        if (selectedButton == "Parks") {
                                          getParks();
                                        } else if (selectedButton == "Schools") {
                                          getSchools();
                                        } else {
                                          getHospitals();
                                        }
                                      });
                                    } /*new LatLng(33.692705, 73.047778)*/
                                    ),
                                key: ValueKey<Object>(redrawObject),
                                layers: [
                                  new TileLayerOptions(
                                      urlTemplate:
                                          "https://api.mapbox.com/styles/v1/mawais/ckhbnqs160ohy19kbat8opzj3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGE2bHhkaDA5MDAydHJzMGMxZG1jeWkifQ.K_7JYzNOsuRLWyOhiw7EJQ",
                                      additionalOptions: {'accessToken': token, 'id': 'mapbox.mapbox-streets-v8'}),
                                  new MarkerLayerOptions(
                                    markers: allmarkers,
                                  ),
                                ],
                              );
                            })
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
