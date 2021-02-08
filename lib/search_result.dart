import 'dart:async';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:location/location.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/nearByPlacesOfProperty.dart';
import 'package:signup/services/PostAdCreation.dart';

import 'Arguments.dart';
import 'ImageCarousel.dart';
import 'navigation.dart';

Column _bottomLayerMenu() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ListTile(
        leading: Icon(
          Icons.school,
          color: Colors.blue,
        ),
        title: Text('Schools'),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(
          Icons.local_hospital,
          color: Colors.blue,
        ),
        title: Text(
          'Hospitals',
        ),
        onTap: () {},
      ),
      // ListTile(
      //   leading: Icon(
      //     Icons.park,
      //     color: Colors.blue,
      //   ),
      //   title: Text(
      //     'Parks',
      //   ),
      //   onTap: (){},
      // ),
    ],
  );
}

class SearcResult extends StatefulWidget {
  final String location;
  final PositionCallback onPositionChanged;
  SearcResult({Key key, @required this.location, this.onPositionChanged}) : super(key: key);

  @override
  _SearcResult createState() => _SearcResult();
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

class _SearcResult extends State<SearcResult> {
  String token = 'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  Stream search;
  var infoWindowVisible = false;
  AdPost forviewDetailAdpost = AdPost();
  GlobalKey<FormState> _key = new GlobalKey();
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;
  String changeState = "For Sale";

  List<Image> _listOfImages = <Image>[];
  List<Marker> allmarkers = List<Marker>();
  Location location = new Location();
  latLng.LatLng center = latLng.LatLng(33.6844, 73.0479);
  AdPost adpost = new AdPost();
  TextEditingController priceFrom = new TextEditingController();
  TextEditingController searchField = new TextEditingController();
  TextEditingController priceTo = new TextEditingController();
  TextEditingController NoOfRoom = new TextEditingController();
  TextEditingController NoOfBath = new TextEditingController();
  TextEditingController propertySizeWidth = new TextEditingController();
  TextEditingController propertySizeHeight = new TextEditingController();
  TextEditingController propertySizeMarla = new TextEditingController();
  TextEditingController propertySizeKanal = new TextEditingController();

  @override
  void initState() {
    // getLatlongOfAds();
    // _determinePosition();
    adpost.Address = widget.location;
    adpost.purpose = "For Sale";
    adpost.propertyType = "All";
    adpost.propertyDeatil = "";
    adpost.priceFrom = null;
    adpost.priceTo = null;
    adpost.propertySize = null;
    adpost.width = null;
    adpost.length = null;
    firstFunction();
  }

  firstFunction() async {
    await searchForCordinates(adpost);
    getLatlongOfAdsRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    priceFrom.dispose();
    priceTo.dispose();
    NoOfRoom.dispose();
    NoOfBath.dispose();
  }

  latLng.LatLng _lastposition;
  double x1;
  double y1;
  double x2;
  double y2;
  String sizeType = 'Marla - Kanal';

  getLatlongOfAdsRefresh() {
    PostAddFirebase().getCordinatesOfAdsRefresh(sizeType, x1, y1, x2, y2, adpost).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  var redrawObject;
  var redrawfields;

  bool isLoading = false;

  searchForCordinates(AdPost adPost) async {
    try {
      if (widget.location == null) {
        var geocoding = Geocoder.local;
        var centers = await geocoding.findAddressesFromQuery(adPost.Address);
        print("we got the cordinates agaisnt address + ${centers.toString()}+ ${centers.first.coordinates.toString()}");
        center = latLng.LatLng(centers.first.coordinates.latitude, centers.first.coordinates.longitude);
        print(center.toString() + " searched data");
      } else {
        var geocoding = Geocoder.local;
        var centers = await geocoding.findAddressesFromQuery(adPost.Address);
        print("we got the cordinates agaisnt address + ${centers.toString()}+ ${centers.first.coordinates.toString()}");
        x1 = centers.first.coordinates.latitude + 0.015;
        y1 = centers.first.coordinates.longitude + 0.015;
        x2 = centers.first.coordinates.latitude - 0.015;
        y2 = centers.first.coordinates.longitude - 0.015;
        setState(() {
          center = latLng.LatLng(centers.first.coordinates.latitude, centers.first.coordinates.longitude);
        });
      }
    } catch (e) {
      print("Error occured in getting cordinates: $e");
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/locationNotFound');
    }
    redrawObject = Object();
  }

  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[marker()],
    );
  }

  marker() {
    if (adpost.purpose == "For Sale") {
      return Icon(Icons.home, color: Colors.black);
    } else {
      return Icon(Icons.home, color: Colors.green);
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }

  MapController mapController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          floatingActionButton: FloatingActionButton(
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
          ),
          backgroundColor: Colors.blue[600],
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('Property Host'),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                    height: 35.0,
                    child: Form(
                      //      key: formKeys[0],
                      autovalidate: _validate,
                      child: TextFormField(
                        controller: searchField,
                        //   validator: ValidateLocation,
                        keyboardType: TextInputType.streetAddress,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                          letterSpacing: 2.0,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink[700], width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[100], width: 2.0),
                          ),
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.only(left: 15.0, bottom: 0.0, top: 10.0),
                          suffixIcon: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(width: 1.0, color: Colors.black),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.search),
                              color: Colors.grey[800],
                              onPressed: () async {
                                adpost.Address = searchField.text.toString();
                                print("Search button pressed" + searchField.text.toString());
                                await searchForCordinates(adpost);
                                redrawObject = Object();
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    )),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Color(0xFF737373),
                                  child: Container(
                                    child: _bottomForSaleMenu(),
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
                        child: Text(changeState),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                               isScrollControlled: true,
                              builder: (context) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: MediaQuery.of(context)
                                        .viewInsets.bottom),
                                    child: Container(
                                      height: 400,
                                      color: Color(0xFF737373),
                                      child: Container(
                                        child: _bottomPriceMenu(),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(10),
                                            topRight: const Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Text('Price'),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Color(0xFF737373),
                                  height: 120,
                                  child: Container(
                                    key: ValueKey<Object>(redrawfields),
                                    child: Column(
                                      children: <Widget>[
                                        _bottomSizeMenu(),
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
                        child: Text('Size'),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return Container(
                                  color: Color(0xFF737373),
                                  height: 168,
                                  child: Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              color:    adpost.propertyType ==
                                                  'Homes' ?Colors.blue[300]:Colors
                                                  .white,
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(10.0),
                                                topRight: const Radius.circular(10.0),
                                              )
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.home,  color:
                                            Colors.red,),
                                            title: Text('Home',style: TextStyle
                                              (fontWeight: FontWeight
                                                .w500,fontFamily: "Poppins",color: adpost.propertyType ==
                                                'Homes' ? Colors.white:Colors.black, ),),
                                            onTap: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                adpost.propertyType = 'Homes';
                                              });
                                              if(propertySizeWidth.text!=""){
                                                if (adpost.propertySize != null) {
                                                _convertWidthLengthToMarla();
                                              }
                                              }
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return Container(
                                                      color: Color(0xFF737373),
                                                      height: 340,
                                                      child: Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: adpost
                                                                      .propertyDeatil == "House" ?Colors.blue[300]:Colors
                                                                      .white,
                                                                  borderRadius: new BorderRadius.only(
                                                                    topLeft: const Radius.circular(10.0),
                                                                    topRight: const Radius.circular(10.0),
                                                                  )
                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('House',style:
                                                                TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily: ""
                                                                      "Poppins",
                                                                  color: adpost
                                                                      .propertyDeatil == ""
                                                                      "House" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'House';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == "Flat" ?Colors.blue[300]:Colors
                                                                    .white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('Flat',style:
                                                                TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily: ""
                                                                      "Poppins",
                                                                  color: adpost
                                                                      .propertyDeatil == ""
                                                                      "Flat" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Flat';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),

                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == "Farm House" ?Colors.blue[300]:Colors
                                                                    .white,

                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('Farm House',style:
                                                                TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily: ""
                                                                      "Poppins",
                                                                  color: adpost
                                                                      .propertyDeatil == ""
                                                                      "Farm House" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Farm House';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == "Pent House" ?Colors.blue[300]:Colors
                                                                    .white,

                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('Pent House',style:
                                                                TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily: ""
                                                                      "Poppins",
                                                                  color: adpost
                                                                      .propertyDeatil == ""
                                                                      "Pent House" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Pent House';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == "All" ?Colors.blue[300]:Colors
                                                                    .white,

                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ("All",
                                                                  style:
                                                                  TextStyle(fontWeight: FontWeight
                                                                      .w500,
                                                                    fontFamily: ""
                                                                        "Poppins",
                                                                    color: adpost
                                                                        .propertyDeatil == "All" ?
                                                                    Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyType = 'Homes';
                                                                  adpost.propertyDeatil = '';
                                                                  getLatlongOfAdsRefresh();
                                                                  Navigator.pop(context);
                                                                },
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
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:    adpost.propertyType ==
                                                'Plots' ?Colors.blue[300]:Colors
                                                .white,
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.map,  color:
                                            Colors.green,),
                                            title: Text('Plots',style: TextStyle
                                              (fontWeight: FontWeight
                                                .w500,fontFamily: "Poppins",color: adpost.propertyType ==
                                                'Plots' ? Colors.white:Colors
                                                .black, ),),
                                            onTap: () {
                                              Navigator.pop(context);
                                              adpost.propertyType = 'Plots';
                                              getLatlongOfAdsRefresh();

                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return Container(
                                                      color: Color(0xFF737373),
                                                      height: 112,
                                                      child: Container(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: adpost
                                                                      .propertyDeatil == 'Residential Plot' ?Colors.blue[300]:Colors
                                                                      .white,
                                                                  borderRadius: new BorderRadius.only(
                                                                    topLeft: const Radius.circular(10.0),
                                                                    topRight: const Radius.circular(10.0),
                                                                  )
                                                              ),
                                                              child: ListTile(
                                                                title: Text('Residential Plot',style: TextStyle(fontWeight: FontWeight
                                                                    .w500,fontFamily: "Poppins",color: adpost
                                                                    .propertyDeatil == "Residential Plot" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Residential Plot';
                                                                 if(propertySizeWidth.text!=""){
                                                if (adpost.propertySize != null) {
                                                _convertWidthLengthToMarla();
                                              }
                                              }
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == 'Commercial Plot' ?Colors.blue[300]:Colors
                                                                    .white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text('Commercial Plot',style: TextStyle(fontWeight: FontWeight
                                                                    .w500,fontFamily: "Poppins",color: adpost
                                                                    .propertyDeatil == "Commercial Plot" ? Colors.white:Colors.black, ),),
                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Commercial Plot';
                                                                 if(propertySizeWidth.text!=""){
                                                if (adpost.propertySize != null) {
                                                _convertWidthLengthToMarla();
                                              }
                                              }
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
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
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:    adpost.propertyType ==
                                                'Commercial' ?Colors.blue[300]:Colors
                                                .white,
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.location_city,
                                              color: Colors.yellow,),
                                            title: Text('Commercial',style: TextStyle
                                              (fontWeight: FontWeight
                                                .w500,fontFamily: "Poppins",color: adpost.propertyType ==
                                                'Commercial' ? Colors.white:Colors
                                                .black, ),),
                                            onTap: () {
                                              Navigator.pop(context);
                                              adpost.propertyType = 'Commercial';
                                             if(propertySizeWidth.text!=""){
                                                if (adpost.propertySize != null) {
                                                _convertWidthLengthToMarla();
                                              }
                                              }
                                              getLatlongOfAdsRefresh();
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return Container(
                                                      color: Color(0xFF737373),
                                                      height: 240,
                                                      child: Container(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: <Widget>[
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: adpost.propertyDeatil == "Office" ?Colors.blue[300]:Colors
                                                                      .white,
                                                                  borderRadius: new BorderRadius.only(
                                                                    topLeft: const Radius.circular(10.0),
                                                                    topRight: const Radius.circular(10.0),
                                                                  )
                                                              ),

                                                              child: ListTile(

                                                                title: Text('Office',style: TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily: "Poppins",color: adpost.propertyDeatil == 'Office' ? Colors.white:Colors.black, ),),

                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Office';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost
                                                                    .propertyDeatil == "Shop" ?Colors.blue[300]:Colors
                                                                    .white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('Shop',
                                                                  style:
                                                                  TextStyle(fontWeight: FontWeight
                                                                      .w500,
                                                                    fontFamily: "Poppins",color: adpost.propertyDeatil == 'Shop' ? Colors.white:Colors.black, ),),

                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Shop';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost.propertyDeatil == "Ware House" ?Colors.blue[300]:Colors
                                                                    .white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('Ware House',
                                                                  style:
                                                                  TextStyle(fontWeight: FontWeight
                                                                      .w500,
                                                                    fontFamily: "Poppins",color: adpost.propertyDeatil == 'Ware House' ? Colors.white:Colors.black, ),),

                                                                onTap: () {
                                                                  adpost.propertyDeatil = 'Ware House';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: adpost.propertyDeatil == "All" ?Colors.blue[300]:Colors
                                                                    .white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text
                                                                  ('All',style:
                                                                TextStyle(fontWeight: FontWeight
                                                                    .w500,
                                                                  fontFamily:
                                                                  "Poppins",
                                                                  color: adpost.propertyDeatil == "All" ? Colors.white:Colors.black, ),),

                                                                onTap: () {
                                                                  adpost.propertyType = 'Commercial';
                                                                  adpost.propertyDeatil = '';
                                                                  getLatlongOfAdsRefresh();

                                                                  Navigator.pop(context);
                                                                },
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
                        child: Text('Type'),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),

                Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 1.32,
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

                                if (adpost.priceFrom != null) {
                                  if (adpost.propertySize == null && adpost.propertyType == "All" && adpost.propertyDeatil == "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) && snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo)) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";

                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                         if(lng<y1 && lng>y2){
                                            allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                         }
                                       
                                      } else {
                                        print("no data matched your search");
                                      }
                                    }
                                  } else if (adpost.propertySize == null && adpost.propertyType != "All" && adpost.propertyDeatil == "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertyType'] == adpost.propertyType) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                         if(lng<y1&&lng>y2){
                                              allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                         }
                                      
                                      }
                                    }
                                  } else if (adpost.propertySize == null && adpost.propertyType != "All" && adpost.propertyDeatil != "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertyType'] == adpost.propertyType &&
                                          snapshot.data.documents[i]['PropertySubType'] == adpost.propertyDeatil) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                        if(lng<y1&&lng>y2){
  allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                        }
                                      
                                      }
                                    }
                                  } else if (adpost.propertySize != null && adpost.width == null && adpost.propertyType != "All" && adpost.propertyDeatil != "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertyType'] == adpost.propertyType &&
                                          snapshot.data.documents[i]['PropertySubType'] == adpost.propertyDeatil &&
                                          snapshot.data.documents[i]['PropertySize'] == adpost.propertySize) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                          if(lng<y1&&lng>y2){
  allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                          }
                                      
                                      }
                                    }
                                  } else if (adpost.propertySize != null && adpost.width != null && adpost.propertyType != "All" && adpost.propertyDeatil != "") {
                                    int width = int.parse(adpost.width);
                                    int length = int.parse(adpost.length);
                                    List<int> items = [width, length];
                                    Map<int, String> result = Map.fromIterable(items, key: (v) => v.id, value: (v) => v.name);
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertyType'] == adpost.propertyType &&
                                          snapshot.data.documents[i]['PropertySubType'] == adpost.propertyDeatil &&
                                          snapshot.data.documents[i]['Width_Length'] == result) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                         if(lng<y1&&lng>y2){
                                              allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                          }
                                      
                                      }
                                    }
                                  } else if (adpost.propertySize != null && adpost.propertyType != "All" && adpost.propertyDeatil == "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertyType'] == adpost.propertyType &&
                                          snapshot.data.documents[i]['PropertySize'] == adpost.propertySize) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                         if(lng<y1&&lng>y2){
                                             allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                          }
                                       
                                      }
                                    }
                                  } else if (adpost.propertySize != null && adpost.propertyType == "All" && adpost.propertyDeatil == "") {
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                      if (snapshot.data.documents[i]['Price'] >= int.parse(adpost.priceFrom) &&
                                          snapshot.data.documents[i]['Price'] <= int.parse(adpost.priceTo) &&
                                          snapshot.data.documents[i]['PropertySize'] == adpost.propertySize) {
                                        double lat = snapshot.data.documents[i]['Location'].latitude;
                                        double lng = snapshot.data.documents[i]['Location'].longitude;
                                        // debugPrint(lng.toString());
                                        String size = "";
                                        if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal'
                                                  "\n" +
                                              _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                          size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Marla';
                                        } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                            _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                          size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                              " "
                                                  'Kanal';
                                        }
                                        var Price = snapshot.data.documents[i]['Price'].toString();
                                        var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                         if(lng<y1&&lng>y2){
                                             allmarkers.add(new Marker(
                                          point: latLng.LatLng(lat, lng),
                                          builder: (context) => GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      ///// Changes Started
                                                      _listOfImages = [];
                                                      for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                        //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                        _listOfImages.add(
                                                          Image.network(
                                                            snapshot.data.documents[i].data['ImageUrls'][j],
                                                            // snapshot.data.documents[index].data['Image Urls'][0],
                                                            //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                              if (loadingProgress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                                ),
                                                              );
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        height: 420,
                                                        color: Color(0xFF737373),
                                                        child: Container(
                                                          child: Column(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Container(
                                                                  //margin: EdgeInsets.only(left: 20),
                                                                  width: 250,
                                                                  height: 170,
                                                                  child: Center(
                                                                    child: Carousel(
                                                                      boxFit: BoxFit.fill,
                                                                      images: _listOfImages,
                                                                      autoplay: false,
                                                                      indicatorBgPadding: 1.0,
                                                                      dotSize: 4.0,
                                                                      dotColor: Colors.blue,
                                                                      dotBgColor: Colors.transparent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ///// Changes Started
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width / 2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{20A8}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(commaPrice.toString()),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 2,
                                                                    height: 30,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  Container(
                                                                    //margin: EdgeInsets.only(left: 20),
                                                                    width: MediaQuery.of(context).size.width / 2.2,
                                                                    child: ListTile(
                                                                      leading: Container(
                                                                        margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                        padding: EdgeInsets.only(top: 15),
                                                                        child: Text(
                                                                          '\u{1F3E1}',
                                                                          style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                        ),
                                                                      ),
                                                                      title: Text(size),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),

                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('View Detail'),
                                                                  onTap: () {
                                                                    forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                    forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                    forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                    Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                                  }),
                                                              ListTile(
                                                                leading: Icon(
                                                                  Icons.directions,
                                                                  color: Colors.redAccent,
                                                                ),
                                                                ///// Changes End
                                                                title: Text('Navigate to property'),
                                                                onTap: () {
                                                                  double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                  double long = snapshot.data.documents[i].data['Location'].longitude;

                                                                  //   Navigator.pushNamed(context, '/navigation');
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                                },
                                                              ),
                                                              ListTile(
                                                                  leading: Icon(
                                                                    Icons.details,
                                                                    color: Colors.green,
                                                                  ),
                                                                  title: Text('NearBy Places'),
                                                                  onTap: () {
                                                                    double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                    double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)));
                                                                  }),
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
                                        ));
                                          }
                                       
                                      }
                                    }
                                  }
                                } else {
                                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                                    double lat = snapshot.data.documents[i]['Location'].latitude;
                                    double lng = snapshot.data.documents[i]['Location'].longitude;
                                    // debugPrint(lng.toString());
                                    String size = "";
                                    if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                        _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                      size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                          " "
                                              'Kanal'
                                              "\n" +
                                          _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                          " "
                                              'Marla';
                                    } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) == "0" &&
                                        _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) != "0") {
                                      size = _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                          " "
                                              'Marla';
                                    } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) != "0" &&
                                        _convertMarlaToMarla(snapshot.data.documents.elementAt(i)['PropertySize']) == "0") {
                                      size = _convertMarlaToKanal(snapshot.data.documents.elementAt(i)['PropertySize']) +
                                          " "
                                              'Kanal';
                                    }
                                    var Price = snapshot.data.documents[i]['Price'].toString();
                                    var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                                     if(lng<y1&&lng>y2){
                                             allmarkers.add(new Marker(
                                      point: latLng.LatLng(lat, lng),
                                      builder: (context) => GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) {
                                                  ///// Changes Started
                                                  _listOfImages = [];
                                                  for (int j = 0; j < snapshot.data.documents[i].data['ImageUrls'].length; j++) {
                                                    //  imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                                                    _listOfImages.add(
                                                      Image.network(
                                                        snapshot.data.documents[i].data['ImageUrls'][j],
                                                        // snapshot.data.documents[index].data['Image Urls'][0],
                                                        //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                          if (loadingProgress == null) return child;
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                            ),
                                                          );
                                                        },
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    height: 420,
                                                    color: Color(0xFF737373),
                                                    child: Container(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Container(
                                                              //margin: EdgeInsets.only(left: 20),
                                                              width: 250,
                                                              height: 170,
                                                              child: Center(
                                                                child: Carousel(
                                                                  boxFit: BoxFit.fill,
                                                                  images: _listOfImages,
                                                                  autoplay: false,
                                                                  indicatorBgPadding: 1.0,
                                                                  dotSize: 4.0,
                                                                  dotColor: Colors.blue,
                                                                  dotBgColor: Colors.transparent,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          ///// Changes Started
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(context).size.width / 2,
                                                                child: ListTile(
                                                                  leading: Container(
                                                                    margin: EdgeInsets.only(left: 4, bottom: 15),
                                                                    padding: EdgeInsets.only(top: 15),
                                                                    child: Text(
                                                                      '\u{20A8}',
                                                                      style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                    ),
                                                                  ),
                                                                  title: Text(commaPrice.toString()),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 2,
                                                                height: 30,
                                                                color: Colors.grey,
                                                              ),
                                                              Container(
                                                                //margin: EdgeInsets.only(left: 20),
                                                                width: MediaQuery.of(context).size.width / 2.2,
                                                                child: ListTile(
                                                                  leading: Container(
                                                                    margin: EdgeInsets.only(left: 14, bottom: 15),
                                                                    padding: EdgeInsets.only(top: 15),
                                                                    child: Text(
                                                                      '\u{1F3E1}',
                                                                      style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                                                    ),
                                                                  ),
                                                                  title: Text(size),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          ListTile(
                                                              leading: Icon(
                                                                Icons.details,
                                                                color: Colors.green,
                                                              ),
                                                              title: Text('View Detail'),
                                                              onTap: () {
                                                                forviewDetailAdpost.postId = snapshot.data.documents[i].documentID.toString();
                                                                forviewDetailAdpost.userId = snapshot.data.documents[i].data['uid'].toString();
                                                                forviewDetailAdpost.price = int.parse(snapshot.data.documents[i].data['Price'].toString());
                                                                Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(forviewDetailAdpost));
                                                              }),
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons.directions,
                                                              color: Colors.redAccent,
                                                            ),
                                                            ///// Changes End
                                                            title: Text('Navigate to property'),
                                                            onTap: () {
                                                              double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                              double long = snapshot.data.documents[i].data['Location'].longitude;

                                                              //   Navigator.pushNamed(context, '/navigation');
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Navigation(latitude: lat, longitude: long)));
                                                            },
                                                          ),
                                                          ListTile(
                                                              leading: Icon(
                                                                Icons.details,
                                                                color: Colors.green,
                                                              ),
                                                              title: Text('NearBy Places'),
                                                              onTap: () {
                                                                double lat = snapshot.data.documents[i].data['Location'].latitude;
                                                                double long = snapshot.data.documents[i].data['Location'].longitude;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => NearByPlacesOfProperty(lat: lat, long: long)),
                                                                );
                                                              }),
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
                                    ));
                                         }
                                   
                                  }
                                }
                                return FlutterMap(
                                  options: new MapOptions(
                                      plugins: [
                                        MarkerClusterPlugin(),
                                      ],
                                      zoom: 14,
                                      minZoom: 5.0,
                                      maxZoom: 18.0,
                                      interactive: true,
                                      center: new latLng.LatLng(center.latitude, center.longitude),
                                      onPositionChanged: (mapPosition, boolValue) {
                                        _lastposition = mapPosition.center;
                                        x1 = _lastposition.latitude + 0.015;
                                        y1 = _lastposition.longitude + 0.015;
                                        x2 = _lastposition.latitude - 0.015;
                                        y2 = _lastposition.longitude - 0.015;
                                        Future.delayed(const Duration(milliseconds: 2000), () {
                                          getLatlongOfAdsRefresh();
                                        });
                                      } /*new LatLng(33.692705, 73.047778)*/
                                      ),
                                  key: ValueKey<Object>(redrawObject),
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
                                      markers: allmarkers,
                                      polygonOptions: PolygonOptions(borderColor: Colors.blueAccent, color: Colors.black12, borderStrokeWidth: 3),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          child: Text(markers.length.toString()),
                                          onPressed: null,
                                          heroTag: "Yes",
                                        );
                                      },
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
          )),
    );
  }
  Column _bottomForSaleMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: adpost.purpose == "For Sale" ?Colors.blue[300]:Colors
                  .white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              )
          ),
          child: ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.black,
            ),
            title: Text('For Sale',style: TextStyle(fontWeight: FontWeight
                .w500,fontFamily: "Poppins",color: adpost.purpose == "For Sale" ? Colors.white:Colors.black, ),),
            onTap: () {
              setState(() {
                changeState = "For Sale";
                adpost.purpose = "For Sale";
                getLatlongOfAdsRefresh();

                Navigator.pop(context);
              });
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: adpost.purpose == "For Rent" ?Colors.blue[300]:Colors.white,
          ),
          child: ListTile(
            leading: Icon(
              Icons.home,
              color: Colors
                  .green,
            ),
            title: Text('For Rent',style: TextStyle(fontWeight: FontWeight
                .w500,fontFamily: "Poppins",color: adpost.purpose == "For Rent"
                ? Colors.white:Colors.black, ),),
            onTap: () {
              setState(() {
                changeState = "For Rent";
                adpost.purpose = "For Rent";
                getLatlongOfAdsRefresh();
                Navigator.pop(context);
              });
            },
          ),
        ),
      ],
    );
  }

   Column _bottomPriceMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin:EdgeInsets.only(top:30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "Set Price Range",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Form(
          autovalidate: _validate,
          key: formKeys[2],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  width: 120,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'From'),
                    controller: priceFrom,
                    validator: validatePrice,
                  ),
                ),
              ),
              Container(
                width: 120,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'To'),
                  controller: priceTo,
                  validator: validatePrice,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top:40),
          child: RaisedButton(
            elevation: 5.0,
            padding: EdgeInsets.fromLTRB(40, 10, 40, 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
            onPressed: () {
              if (formKeys[2].currentState.validate()) {
                formKeys[2].currentState.save();
                adpost.priceFrom = priceFrom.text.toString();
                adpost.priceTo = priceTo.text.toString();
                getLatlongOfAdsRefresh();
                Navigator.pop(context);
              } else {
                setState(() {
                  _validate = true;
                });
              }
            },
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            color: Colors.blue[600],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top:35),
          child: RaisedButton(
            elevation: 5.0,
            padding: EdgeInsets.fromLTRB(46, 10, 46, 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
            onPressed: () {
              adpost.priceFrom = null;
              adpost.priceTo = null;
              getLatlongOfAdsRefresh();
              Navigator.pop(context);
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            color: Colors.blue[600],
          ),
        )
      ],
    );
  }

  Column _bottomSizeMenu() {
    return Column(
     // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.aspect_ratio,
            color: Colors.blue,
          ),
          title: Text('Marla - Kanal'),
          onTap: () {
            Navigator.pop(context);
            showModalBottomSheet(
              isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context)
                        .viewInsets.bottom),
                    child: Container(

                      color: Color(0xFF737373),
                      height:400,
                      child: Container(
                        key: ValueKey<Object>(redrawfields),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _showExpansionListPropertySizeMarlaKanal(),
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
                    ),
                  );
                });
          },
        ),
        ListTile(
          leading: Icon(
            Icons.open_with,
            color: Colors.blue,
          ),
          title: Text('Width - Length'),
          onTap: () {
            if (adpost.propertyDeatil == "") {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/BrokenLinkScreen');
            } else {
              Navigator.pop(context);
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context)
                          .viewInsets.bottom),
                      child: Container(
                        color: Color(0xFF737373),
                        height: 400,
                        child: Container(
                          key: ValueKey<Object>(redrawfields),
                          child: Column(
                            children: <Widget>[
                              _showExpansionListPropertySizeWidthHeight(),
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
                      ),
                    );
                  });
            }
          },
        ),
      ],
    );
  }

  _convertWidthLengthToMarla() {
    if (adpost.propertyType == 'Plots') {
      if (adpost.propertyDeatil == 'Commercial Plot') {
        adpost.propertySize = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 225).toString();
      } else {
        adpost.propertySize = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 250).toString();
      }
    } else if (adpost.propertyType == 'Commercial') {
      adpost.propertySize = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 225).toString();
    } else {
      adpost.propertySize = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 250).toString();
    }
  }

  Widget _showExpansionListPropertySizeWidthHeight() {
    return Form(
        key: formKeys[1],
        autovalidate: _validate,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              margin: EdgeInsets.only(top:30),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Container(
                      width: 120,
                      child: TextFormField(
                        controller: propertySizeWidth,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        maxLength: 2,
                        validator: validateWidthheight,
                        //autofocus: true,

                        decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.view_week,
                                color: Color(0xff2470c7),
                              ),
                            ),
                            labelText: 'Width'),
                      ),
                    ),
                  ),
                  //SizedBox(width: 7,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Container(
                      width: 120,
                      child: TextFormField(
                        controller: propertySizeHeight,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        maxLength: 2,
                        validator: validateWidthheight,
                        //autofocus: true,

                        decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.dehaze,
                                color: Color(0xff2470c7),
                              ),
                            ),
                            labelText: 'Length'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top:50),
            child: RaisedButton(
              elevation: 5.0,
              padding: EdgeInsets.fromLTRB(40, 10, 40, 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
              onPressed: () {
                if (formKeys[1].currentState.validate()) {
                  formKeys[1].currentState.save();
                  _convertWidthLengthToMarla();
                  getLatlongOfAdsRefresh();
                  Navigator.pop(context);
                } else {
                  _validate = true;
                }
              },
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              color: Colors.blue[600],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top:40),
            child: RaisedButton(
              elevation: 5.0,
              padding: EdgeInsets.fromLTRB(46, 10, 46, 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
              onPressed: () {
                adpost.propertySize = null;
                getLatlongOfAdsRefresh();
                Navigator.pop(context);
              },
              child: Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              color: Colors.blue[600],
            ),
          )
        ]));
  }

  Widget _showExpansionListPropertySizeMarlaKanal() {
    return Form(
        key: formKeys[3],
        autovalidate: _validate,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                margin: EdgeInsets.only(top:30),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: propertySizeKanal,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          //autofocus: true,
                          decoration: InputDecoration(
                              prefixIcon: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.edit,
                                  color: Color(0xff2470c7),
                                ),
                              ),
                              labelText: 'Kanal'),
                        ),
                      ),
                    ),

                    //SizedBox(width: ,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Container(
                        width: 120,
                        child: TextFormField(
                          controller: propertySizeMarla,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          maxLines: 1,

                          decoration: InputDecoration(
                              prefixIcon: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.edit,
                                  color: Color(0xff2470c7),
                                ),
                              ),
                              labelText: 'Marla'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top:50),
              child: RaisedButton(
                elevation: 5.0,
                padding: EdgeInsets.fromLTRB(40, 10, 40, 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
                onPressed: () {
                  if (formKeys[3].currentState.validate()) {
                    formKeys[3].currentState.save();

                    if (propertySizeMarla.text != "" && propertySizeKanal.text != "") {
                      double marla = double.parse(propertySizeMarla.text);
                      int kanal = int.parse(propertySizeKanal.text);
                      kanal = ((kanal * 100) / 5).round();
                      marla = kanal + marla;
                      adpost.propertySize = marla.toString();
                    } else if (propertySizeMarla.text != "" && propertySizeKanal.text == "") {
                      double marla = double.parse(propertySizeMarla.text);
                      adpost.propertySize = marla.toString();
                    } else if (propertySizeMarla.text == "" && propertySizeKanal.text != "") {
                      int kanal = int.parse(propertySizeKanal.text);
                      kanal = ((kanal * 100) / 5).round();
                      adpost.propertySize = kanal.toString();
                    } else {}
                    getLatlongOfAdsRefresh();
                    Navigator.pop(context);
                  } else {
                    _validate = true;
                  }
                },
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                color: Colors.blue[600],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top:40),
              child: RaisedButton(
                elevation: 5.0,
                padding: EdgeInsets.fromLTRB(46, 10, 46, 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.blue, width: 2.0)),
                onPressed: () {
                  adpost.propertySize = null;
                  getLatlongOfAdsRefresh();
                  Navigator.pop(context);
                },
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                color: Colors.blue[600],
              ),
            )
          ],
        ));
  }






  _convertMarlaToKanal(size) {
    int x = double.parse(size).toInt();
    double z = x / 20;
    String y = z.toString();
    String kanal = y.substring(0, y.indexOf('.'));
    return kanal;
  }

  _convertMarlaToMarla(size) {
    int x = double.parse(size).toInt();
    int marla = x.remainder(20);
    return marla.toString();
  }
}
