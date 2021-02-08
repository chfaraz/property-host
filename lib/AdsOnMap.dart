/*

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:signup/ImageCarousel.dart';
import 'package:signup/services/PostAdCreation.dart';

import 'Arguments.dart';
import 'models/Adpost.dart';
import 'navigation.dart';


class AdsOnMap extends StatefulWidget {

  final AdPost adpost;
  // final FirebaseUser user;
  const AdsOnMap({Key key, this.adpost}):super(key: key);

  @override
  _AdsOnMap createState() => _AdsOnMap(this.adpost);

}
  class _AdsOnMap extends State<AdsOnMap> {

  AdPost adPost;
  _AdsOnMap(this.adPost);

  String token = 'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

 // MapboxMapController _mapController;
 List <GeoPoint> cordinates = List<GeoPoint>();
  LatLng _center = LatLng(33.640348, 72.993679);
  var infoWindowVisible = false;


  List<Marker> allmarkers = List<Marker>();



  @override
  void initState(){
 super.initState();
  }

  @override
  void dispose(){
    super.dispose();

}



  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[marker()],
    );
  }


  marker() {
    return Icon(Icons.home);
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     home:Scaffold(
      backgroundColor: Colors.grey[600],
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('Property Host'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        elevation: 0.0,
      ),
      body: _buildMap(),

     ));

  }

  Widget _buildMap() {
    return   StreamBuilder(
        stream: CombineLatestStream.list(PostAddFirebase().ListOfstreams(widget.adpost)),
        builder: (context,  AsyncSnapshot<dynamic> snapshot) {
          allmarkers = [];
          if (!snapshot.hasData)  return Center(child:Text('Loading maps...Please Wait'));

          List<dynamic> combinedSnapshot = snapshot.data.toList();
          print(combinedSnapshot.length);

          for (int i = 0; i < combinedSnapshot.length; i++) {
            print(i.toString());
            if(combinedSnapshot[i].documents.length >0){
              for(int j=0; j<combinedSnapshot[i].documents.length; j++){
                if(combinedSnapshot[i].documents[j].documentID != combinedSnapshot[i+1].documents[j+1].documentID) {
                  print(combinedSnapshot[i].documents.length.toString() + "i am length of inside documents ");
                  double lat = combinedSnapshot[i].documents[j]['Location']
                      .latitude;
                  double lng = combinedSnapshot[i].documents[j]['Location']
                      .longitude;
                  print(i.toString() + "i am i" + j.toString() + " I am j");
       //     debugPrint(lng.toString());
            allmarkers.add(new Marker(
            point: LatLng(lat, lng),
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
                                  ListTile(
                                    leading: Icon(Icons
                                        .attach_money),
                                    title: Text(combinedSnapshot[i].documents[j]['Price']
                                        .toString()),
                                  ),
                                  ListTile(
                                      leading: Icon(
                                          Icons.details),
                                      title: Text(
                                          'View Detail'),
                                      onTap: () => Navigator.of(this.context).pushNamed(ImageCarousel.routeName,
                                          arguments: ScreenArguments(combinedSnapshot[i].documents[j].documentID.toString(), combinedSnapshot[i].documents[j]['uid'].toString()))),
                                  ListTile(
                                    leading: Icon(
                                        Icons.directions),
                                    title: Text(
                                        'Navigate to property'),
                                    onTap: (){

                                      double lat = combinedSnapshot[i].documents[j]['Location'].latitude;
                                      double long = combinedSnapshot[i].documents[j]['Location'].longitude;

                                      //   Navigator.pushNamed(context, '/navigation');
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Navigation(
                                          latitude: lat,longitude: long)));
                                    },
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .canvasColor,
                                borderRadius:
                                BorderRadius.only(
                                  topLeft: const Radius
                                      .circular(10),
                                  topRight: const Radius
                                      .circular(10),
                                ),
                              ),
                            ),
                          );
                        });
                    debugPrint(
                        "Tapp tapp loot ka no mazak");
                  },
                  child: _buildCustomMarker()),
            ));

                } //matching if
              } //nestd for loop
            } // dhecking document length
          } //first for loop
          return FlutterMap(
              options: new MapOptions(
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                  zoom: 12,
                  minZoom: 8.0,
                  maxZoom: 18.0,
                  interactive: true,
                  center:
                  new LatLng(33.692705, 73.047778)),
              layers: [
                new TileLayerOptions(
                    urlTemplate:
                    "https://api.mapbox.com/styles/v1/mawais/ckhbnqs160ohy19kbat8opzj3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGE2bHhkaDA5MDAydHJzMGMxZG1jeWkifQ.K_7JYzNOsuRLWyOhiw7EJQ",
                    additionalOptions: {
                      'accessToken': token,
                      'id': 'mapbox.mapbox-streets-v8'
                    }),
                MarkerClusterLayerOptions(
                  maxClusterRadius: 120,
                  size: Size(30, 30),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: allmarkers,
                  polygonOptions: PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      child:
                      Text(markers.length.toString()),
                      onPressed: null,
                    );
                  },
                ),
              ]);
        });


  }


}





*/
