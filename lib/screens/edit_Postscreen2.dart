import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/home.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/services/PostAdCreation.dart';
import 'package:signup/viewPostAdds.dart';
import '../utils.dart';

class EditPostSecondScreen extends StatefulWidget {
  @override
  _EditPostSecondScreenState createState() => new _EditPostSecondScreenState();
 final AdPost _adpost;

  EditPostSecondScreen(this._adpost, {Key key}) : super(key: key);
}

class _EditPostSecondScreenState extends State<EditPostSecondScreen> {
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  List<File> fileImageList = List<File>();
  List<Uint8List> _list = [];

  String _error = 'No Error Dectected';
  bool isUploading = false;
  List<NetworkImage> _listOfImages = <NetworkImage>[];

  PostAddFirebase createpost = PostAddFirebase();
  AdPost adPost = new AdPost();

  double TotalPropertySizeInMarla;

  // main features controllers

  TextEditingController buildYear = new TextEditingController();
  TextEditingController parkingSpace = new TextEditingController();
  TextEditingController Rooms = new TextEditingController();
  TextEditingController BathRooms = new TextEditingController();
  TextEditingController kitchens = new TextEditingController();
  TextEditingController Floors = new TextEditingController();
  TextEditingController propertySizeWidth = new TextEditingController();
  TextEditingController propertySizeHeight = new TextEditingController();
  TextEditingController propertySizeMarla = new TextEditingController();
  TextEditingController propertySizeKanal = new TextEditingController();
  TextEditingController flooring = new TextEditingController();

  //ends here

  GlobalKey<FormState> _key = new GlobalKey();

  bool _validate = false;



  String dropdownTo;
  String dropdownFrom;
  String dropdownCondition;
  String _selectedpropertyType;
  String _selectedpropertyDetailType;
  String _selectedpropertySize;
  int value = 0;
  bool isButtonPressed1 = false;
  bool isButtonPressed2 = false;
  bool isButtonPressed3 = false;
  bool isButtonPressed4 = false;
  bool isButtonPressed5 = false;
  bool isButtonPressed6 = false;
  bool isButtonPressed7 = false;

  bool _checkBoxVal = false;
  bool _checkBoxVal2 = false;
  bool _checkBoxVal3 = false;
  bool _checkBoxVal4 = false;
  bool _checkBoxVal5 = false;
  bool _checkBoxVal6 = false;
  bool _checkBoxVal7 = false;
  bool _checkBoxVal8 = false;

  List<String> _propertyType = ['Homes', 'Plots', 'Commercial'];
  List<String> _propertySize = [
    'Marla - Kanal',
    'Width - Height',
  ];

  List<String> _propertyTypeHomes = ['House', 'Flat', 'Farm House', 'Pent House'];

  List<String> _propertyTypePlots = [
    'Residential Plot',
    'Commercial Plot',
  ];

  List<String> _propertyTypeCommercial = ['Office', 'Shop', 'WareHouse', 'Other'];

  List<String> _getPropertyTypeDetails() {
    switch (_selectedpropertyType) {
      case ("Homes"):
        return _propertyTypeHomes;
      case ("Plots"):
        return _propertyTypePlots;
      case ("Commercial"):
        return _propertyTypeCommercial;
    }

    List<String> deflt2 = ['Please Select Property Type'];
    return deflt2;
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }


  @override
  void initState() {
    super.initState();
    _selectedpropertyType = widget._adpost.propertyType;
    _selectedpropertyDetailType = widget._adpost.propertyDeatil;
    print(_selectedpropertyType + _selectedpropertyDetailType);
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime _selectedDate;

  //Method for showing the date picker
  void _pickDateDialog(BuildContext context) async  {
    final DateTime picked = await showDatePicker(
      context: context,
     // initialEntryMode: DatePickerEntryMode.input,
      initialDatePickerMode: DatePickerMode.year,
      initialDate: _selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        print(_selectedDate.toString());
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.grey[600],
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue[800], Colors.blue[800]],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.5, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp
            ),
          ),
        ),
        title: Center(child:Text("Update Your Ad")),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              AddPost(),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
              ),
            ], //:TODO: implement upload pictures
          ),
        ),
      ),
    );
  }

  var alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    descTextAlign: TextAlign.start,
    animationDuration: Duration(milliseconds: 600),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
    alertAlignment: Alignment.center,
  );

  Widget AddPost() {
    return Form(
      key: _key,
      autovalidate: _validate,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          child: Column(
            children: <Widget>[
              //_showExpansionListPropertySize()
              _getPropertySizeDropDown(),
              _selectedpropertySize == "Width - Height"
                  ? _showExpansionListPropertySizeWidthHeight()
                  : _selectedpropertySize == "Marla - Kanal"
                      ? _showExpansionListPropertySizeMarlaKanal()
                      : Container(),
              _getPropertyTypeDropDown(),
              _getPropertyTypeDetailDropDown(),

              _selectedpropertyDetailType == 'House'
                  ? _showExpansionList()
                  : _selectedpropertyDetailType == 'Flat'
                              ? _showExpansionList()
                              : _selectedpropertyDetailType == 'Farm House'
                                  ? _showExpansionList()
                                  : _selectedpropertyDetailType == 'Residential Plot'
                                      ? _showExpansionListPlot()
                                      : _selectedpropertyDetailType == 'Commercial Plot'
                                          ? _showExpansionListPlot()
                                              : _selectedpropertyDetailType == 'Office'
                                                  ? _showExpansionListCommercial()
                                                  : _selectedpropertyDetailType == 'Shop'
                                                      ? _showExpansionListCommercial()
                                                      : _selectedpropertyDetailType == 'Ware House'
                                                          ? _showExpansionListCommercial()
                                                          : _selectedpropertyDetailType == 'Factory'
                                                                  ? _showExpansionListCommercial()
                                                                  : _selectedpropertyDetailType == 'Other'
                                                                      ? _showExpansionListCommercial()
                                                                      : _hideExpansionList(),

              UploadPropertyImages(),

              //ReadImagesFromFirebaseStorage(),
              //_uploadImagesInput(),
              //_showSelectImages(),
              //_showAddImages(),
              Container(
                margin: EdgeInsets.only(left: 7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    //buildGridView(),
                    Container(
                      width: 200,
                      height: MediaQuery.of(context).size.height / 4,
                      //color: Colors.green,
                      child: buildGridView(),
                    ),
                    RaisedButton(
                      child: Text("Submit"),
                      onPressed: () async {
                        if (_key.currentState.validate() && images.length > 0) {
                          _key.currentState.save();
                          if (_selectedpropertySize == 'Marla - Kanal') {
                            print("marla kanal");
                            bool check = marlaKanalCheck();
                            if (check == null) {
                              print("true");
                           Navigator.of(context).pushNamed('/postingAd');
                              /*Alert(
                                context: context,
                                style: alertStyle,
                                type: AlertType.info,
                                title: "YEY !!",
                                desc: "Your Ad will be displayed soon.",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Thankyou",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    //      onPressed: () => Navigator.pop(context),
                                    color: Color.fromRGBO(0, 179, 134, 1.0),
                                    radius: BorderRadius.circular(0.0),
                                  ),
                                ],
                              ).show();*/
                              await runMyFutureGetImagesReference();
                            Navigator.pop(context);
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                            } else {
                              print('data${check}');
                            }
                          }
                          if (_selectedpropertySize == 'Width - Height') {
                            print("width height");
                            bool check2 = widthHeightCheck();
                            if (check2 == null) {
                              print("true");
                              
                            Navigator.of(context).pushNamed('/postingAd');
                            /*  Alert(
                                context: context,
                                style: alertStyle,
                                type: AlertType.info,
                                title: "YEY !!",
                                desc: "Your Ad will be displayed soon.",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Thankyou",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    //      onPressed: () => Navigator.pop(context),
                                    color: Color.fromRGBO(0, 179, 134, 1.0),
                                    radius: BorderRadius.circular(0.0),
                                  ),
                                ],
                              ).show();*/
                              await runMyFutureGetImagesReference();
                             Navigator.pop(context);
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                            } else {
                              print('data${check2}');
                            }
                          }

                        } else {
                          setState(() {
                            showInSnackBar("Please select images");
                            _validate = true;
                          }
                              // _validate = true;
                              );
                        }
                      },
                      textColor: Colors.black,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      splashColor: Colors.grey,
                    ),
                  ],
                ),
              ),

              //_showSubmitButton(),
            ],
          )),
    );
  }
  Future<bool> runMyFutureGetImagesReference() async {
    List<String> values = await GetImageReferences();

    print(values.length.toString() + "entered in runMyfuture method");

    if (_selectedpropertyType == "Homes") {
      if (_selectedpropertyDetailType == "Pent House") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.Fromtime = widget._adpost.Fromtime;
        adPost.endtime = widget._adpost.endtime;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.postId = widget._adpost.postId;

        adPost.ImageUrls = values;

        createpost.updatePostAddHomesPentHouse(adPost);
      } else {
        setState(() {
          if (buildYear.text.isEmpty || parkingSpace.text.isEmpty || Rooms.text.isEmpty || BathRooms.text.isEmpty || kitchens.text.isEmpty || Floors.text.isEmpty) {
            _validate = true;
          } else {
            adPost.title = widget._adpost.title;
            adPost.desc = widget._adpost.desc;
            adPost.price = widget._adpost.price;
            adPost.Address = widget._adpost.Address;
            adPost.City = widget._adpost.City;
            adPost.AvailDays = widget._adpost.AvailDays;
            adPost.Fromtime = widget._adpost.Fromtime;
            adPost.endtime = widget._adpost.endtime;
            adPost.propertySize = TotalPropertySizeInMarla.toString();
            adPost.length = propertySizeHeight.text;
            adPost.width = propertySizeWidth.text;
            adPost.purpose = widget._adpost.purpose;
            adPost.propertyType = _selectedpropertyType;
            adPost.propertyDeatil = _selectedpropertyDetailType;
            adPost.buildyear = buildYear.text;
            adPost.ParkingSpace = parkingSpace.text;
            adPost.Rooms = Rooms.text;
            adPost.bathrooms = BathRooms.text;
            adPost.Kitchens = kitchens.text;
            adPost.Floors = Floors.text;
            adPost.location = widget._adpost.location;
            adPost.postId = widget._adpost.postId;
            adPost.ImageUrls = values;

            createpost.updatePostAddHomes(adPost);

            // print(imageUrls);
          }
        });
      }
    } else if (_selectedpropertyType == "Plots") {
      if (_selectedpropertyDetailType == "Residential Plot") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.Fromtime = widget._adpost.Fromtime;
        adPost.endtime = widget._adpost.endtime;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.possesion = _checkBoxVal;
        adPost.ParkingSpaces = _checkBoxVal3;
        adPost.corners = _checkBoxVal2;
        adPost.disputed = _checkBoxVal4;
        adPost.balloted = _checkBoxVal5;
        adPost.suiGas = _checkBoxVal6;
        adPost.waterSupply = _checkBoxVal7;
        adPost.sewarge = _checkBoxVal8;
        adPost.location = widget._adpost.location;
        adPost.postId = widget._adpost.postId;
        adPost.ImageUrls = values;

        createpost.updatePostAddResidentialPlots(adPost);
      } else {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.Fromtime = widget._adpost.Fromtime;
        adPost.endtime = widget._adpost.endtime;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.ImageUrls = values;
        adPost.postId = widget._adpost.postId;
        createpost.updatePostPlots(adPost);
      }
    } else {
      if (_selectedpropertyDetailType == "WareHouse") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.Fromtime = widget._adpost.Fromtime;
        adPost.endtime = widget._adpost.endtime;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.postId = widget._adpost.postId;
        adPost.ImageUrls = values;

        createpost.updatePostAddWareHouse(adPost);
      } else {
        setState(() {
          if (buildYear.text.isEmpty || parkingSpace.text.isEmpty || Rooms.text.isEmpty || Floors.text.isEmpty) {
            _validate = true;
          } else {
            adPost.title = widget._adpost.title;
            adPost.desc = widget._adpost.desc;
            adPost.price = widget._adpost.price;
            adPost.Address = widget._adpost.Address;
            adPost.City = widget._adpost.City;
            adPost.AvailDays = widget._adpost.AvailDays;
            adPost.Fromtime = widget._adpost.Fromtime;
            adPost.endtime = widget._adpost.endtime;
            adPost.propertySize = TotalPropertySizeInMarla.toString();
            adPost.length = propertySizeHeight.text;
            adPost.width = propertySizeWidth.text;
            adPost.purpose = widget._adpost.purpose;
            adPost.propertyType = _selectedpropertyType;
            adPost.propertyDeatil = _selectedpropertyDetailType;
            adPost.buildyear = buildYear.text;
            adPost.ParkingSpace = parkingSpace.text;
            adPost.Rooms = Rooms.text;
            adPost.Floors = Floors.text;
            adPost.Elevators = _checkBoxVal;
            adPost.MaintenanceStaff = _checkBoxVal2;
            adPost.WasteDisposal = _checkBoxVal3;
            adPost.Security = _checkBoxVal4;
            adPost.location = widget._adpost.location;
            adPost.postId = widget._adpost.postId;
            adPost.ImageUrls = values;
            createpost.updatePostAddCommerical(adPost);
          }
        });
      }
    }
  }
/*  Future<bool> runMyFutureGetImagesReference() async {
    List<String> values = await GetImageReferences();

    print(values.length.toString() + "entered in runMyfuture method");

    if (_selectedpropertyType == "Homes") {
      if (_selectedpropertyDetailType == "Pent House") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.time = widget._adpost.time;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.ImageUrls = values;

        createpost.updatePostAddHomesPentHouse(adPost);
      } else {
        setState(() {
          if (buildYear.text.isEmpty || parkingSpace.text.isEmpty || Rooms.text.isEmpty || BathRooms.text.isEmpty || kitchens.text.isEmpty || Floors.text.isEmpty) {
            _validate = true;
          } else {
            adPost.title = widget._adpost.title;
            adPost.desc = widget._adpost.desc;
            adPost.price = widget._adpost.price;
            adPost.Address = widget._adpost.Address;
            adPost.City = widget._adpost.City;
            adPost.AvailDays = widget._adpost.AvailDays;
            adPost.time = widget._adpost.time;
            adPost.propertySize = TotalPropertySizeInMarla.toString();
            adPost.length = propertySizeHeight.text;
            adPost.width = propertySizeWidth.text;
            adPost.purpose = widget._adpost.purpose;
            adPost.propertyType = _selectedpropertyType;
            adPost.propertyDeatil = _selectedpropertyDetailType;
            adPost.buildyear = buildYear.text;
            adPost.ParkingSpace = parkingSpace.text;
            adPost.Rooms = Rooms.text;
            adPost.bathrooms = BathRooms.text;
            adPost.Kitchens = kitchens.text;
            adPost.Floors = Floors.text;
            adPost.location = widget._adpost.location;
            adPost.ImageUrls = values;

            createpost.updatePostAddHomes(adPost);

            // print(imageUrls);
          }
        });
      }
    } else if (_selectedpropertyType == "Plots") {
      if (_selectedpropertyDetailType == "Residential Plot") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.time = widget._adpost.time;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.possesion = _checkBoxVal;
        adPost.ParkingSpaces = _checkBoxVal2;
        adPost.corners = _checkBoxVal3;
        adPost.disputed = _checkBoxVal4;
        adPost.balloted = _checkBoxVal5;
        adPost.suiGas = _checkBoxVal6;
        adPost.waterSupply = _checkBoxVal7;
        adPost.sewarge = _checkBoxVal8;
        adPost.location = widget._adpost.location;
        adPost.ImageUrls = values;

        createpost.CreatePostAddResidentialPlots(adPost);
      } else {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.time = widget._adpost.time;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.ImageUrls = values;
        createpost.updatePostAddPlots(adPost);
      }
    } else {
      if (_selectedpropertyDetailType == "WareHouse") {
        adPost.title = widget._adpost.title;
        adPost.desc = widget._adpost.desc;
        adPost.price = widget._adpost.price;
        adPost.Address = widget._adpost.Address;
        adPost.City = widget._adpost.City;
        adPost.AvailDays = widget._adpost.AvailDays;
        adPost.time = widget._adpost.time;
        adPost.propertySize = TotalPropertySizeInMarla.toString();
        adPost.length = propertySizeHeight.text;
        adPost.width = propertySizeWidth.text;
        adPost.purpose = widget._adpost.purpose;
        adPost.propertyType = _selectedpropertyType;
        adPost.propertyDeatil = _selectedpropertyDetailType;
        adPost.location = widget._adpost.location;
        adPost.ImageUrls = values;

        createpost.CreatePostAddWareHouse(adPost);
      } else {
        setState(() {
          if (buildYear.text.isEmpty || parkingSpace.text.isEmpty || flooring.text.isEmpty || Rooms.text.isEmpty || Floors.text.isEmpty) {
            _validate = true;
          } else {
            adPost.title = widget._adpost.title;
            adPost.desc = widget._adpost.desc;
            adPost.price = widget._adpost.price;
            adPost.Address = widget._adpost.Address;
            adPost.City = widget._adpost.City;
            adPost.AvailDays = widget._adpost.AvailDays;
            adPost.time = widget._adpost.time;
            adPost.propertySize = TotalPropertySizeInMarla.toString();
            adPost.length = propertySizeHeight.text;
            adPost.width = propertySizeWidth.text;
            adPost.purpose = widget._adpost.purpose;
            adPost.propertyType = _selectedpropertyType;
            adPost.propertyDeatil = _selectedpropertyDetailType;
            adPost.buildyear = buildYear.text;
            adPost.ParkingSpace = parkingSpace.text;
            adPost.Rooms = Rooms.text;
            adPost.Floors = Floors.text;
            adPost.Flooring = flooring.text;
            adPost.Elevators = _checkBoxVal;
            adPost.MaintenanceStaff = _checkBoxVal2;
            adPost.WasteDisposal = _checkBoxVal3;
            adPost.Security = _checkBoxVal4;
            adPost.location = widget._adpost.location;
            adPost.ImageUrls = values;
            createpost.updatePostAddCommerical(adPost);
          }
        });
      }
    }

    //  showAlert("uploaded successfully");
    //  Navigator.of(context).pop();
  }*/

  Widget _getPropertyTypeDropDown() {
    return Row(
      children: <Widget>[
        //Icon(Icons.map, color: Colors.grey),
        Container(
          //margin: EdgeInsets.only(left: 5,),
          width: 7.0,
        ),
        Flexible(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  prefixIcon: Container(
                    //margin: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.scatter_plot,
                      color: Color(0xff2470c7),
                    ),
                  ),
                  labelText: 'Choose Property Type'),
              value: _selectedpropertyType,
              onChanged: (newValue) {
                setState(() {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectedpropertyType = newValue;
                  _selectedpropertyDetailType = _getPropertyTypeDetails().first;
                });
              },
              items: _propertyType.map((propertyType) {
                return DropdownMenuItem(
                  child: Text(propertyType),
                  value: propertyType,
                );
              }).toList(),
              validator: (value) => value == null ? 'Property Type is required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getPropertySizeDropDown() {
    return Row(
      children: <Widget>[
        //Icon(Icons.map, color: Colors.grey),
        Container(
          //margin: EdgeInsets.only(left: 5,),
          width: 7.0,
        ),
        Flexible(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  prefixIcon: Container(
                    //margin: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.account_balance,
                      color: Color(0xff2470c7),
                    ),
                  ),
                  labelText: 'Select Property Size Type'),
              value: _selectedpropertySize,
              onChanged: (newValue) {
                setState(() {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectedpropertySize = newValue;
                  //_selectedpropertyDetailType = _getPropertyTypeDetails().first;
                });
              },
              items: _propertySize.map((propertyType) {
                return DropdownMenuItem(
                  child: Text(propertyType),
                  value: propertyType,
                );
              }).toList(),
              validator: (value) => value == null ? 'Property Size is required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getPropertyTypeDetailDropDown() {
    return Row(
      children: <Widget>[
        //Icon(Icons.map, color: Colors.grey),
        Container(
          //margin: EdgeInsets.only(left: 5,),
          width: 7.0,
        ),
        Flexible(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  prefixIcon: Container(
                    //margin: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.merge_type,
                      color: Color(0xff2470c7),
                    ),
                  ),
                  labelText: 'Choose Property Detail'),
              //hint: Text('Choose Property Type Detail'),
              value: _selectedpropertyDetailType,
              onChanged: (newValue) {
                setState(() {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _selectedpropertyDetailType = newValue;
                });
              },
              items: _getPropertyTypeDetails().map((propertyType) {
                return DropdownMenuItem(
                  child: Text(propertyType),
                  value: propertyType,
                );
              }).toList(),
              validator: (value) => value == null ? 'Property type detail required' : null,
            ),
          ),
        ),
      ],
    );
  }

  showAlert(String a) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(a),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Ok",
                style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w600, color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
       // print(asset.getByteData(quality: 100));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 2)),
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
            ),
          ),
          //  ),
        );
      }),
    );
  }

  Widget UploadPropertyImages() {
    return Container(
        child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  NiceButton(
                      width: 250,
                      elevation: 8.0,
                      radius: 52.0,
                      text: "Select Images",
                      background: Colors.blueAccent,
                      onPressed: () async {
                        List<File> fileImageArray=[];
                        List<Asset> asst =  await loadAssets();
                        if (asst.length == 0) {
                          showInSnackBar("No images selected");
                        }
                        // SizedBox(height: 10,);
                        else {

                          // images.forEach((images) async {
                          //   final filePath = await FlutterAbsolutePath.getAbsolutePath(images.identifier);
                          //
                          //   File tempFile = File(filePath);
                          //   if (tempFile.existsSync()) {
                          //     fileImageArray.add(tempFile);
                          //     print(fileImageArray.length.toString());
                          //   }
                          // });
                          //  await compressImage(fileImageArray);
                          if (asst != null) {
                            asst.forEach((_image) async {
                              var _data = await _image.getByteData();
                              var compressed = await FlutterImageCompress.compressWithList(
                                _data.buffer.asUint8List(),
                                minHeight: 800,
                                minWidth: 600,
                              );
                              _list.add(Uint8List.fromList(compressed));
                            });
                          }

                          showInSnackBar('Images Successfully loaded');
                        }
                      }),
                ],
              ),
            )));
  }

// ignore: non_constant_identifier_names
  Future<List<String>> GetImageReferences() async {
    String error = "No error detected";
    List<String> urls = <String>[];
    // var firebaseUser = await FirebaseAuth.instance.currentUser();

    try {
      for (var imageFile in _list) {
        await postImage(imageFile).then((downloadUrl) {
          urls.add(downloadUrl.toString());
          print("i am third line of awaiting post image");
          if (_list.length ==images.length) {
            print(urls.length.toString() + " images selected");

            return urls;

          }
        }).catchError((err) {
          print(err);
        });
      }
    } on Exception catch (e) {
      error = e.toString();
      print(error);
    }
    return urls;
  }

  Widget ReadImagesFromFirebaseStorage() {
    return Row(children: <Widget>[
      Expanded(
          child: SizedBox(
              height: 500,
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('PostAdd').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            _listOfImages = [];
                            for (int i = 0; i < snapshot.data.documents[index].data['ImageUrls'].length; i++) {
                              _listOfImages.add(NetworkImage(snapshot.data.documents[index].data['ImageUrls'][i]));
                            }
                            return Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(10.0),
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Carousel(
                                      boxFit: BoxFit.cover,
                                      images: _listOfImages,
                                      autoplay: false,
                                      indicatorBgPadding: 5.0,
                                      dotPosition: DotPosition.bottomCenter,
                                      animationCurve: Curves.fastOutSlowIn,
                                      animationDuration: Duration(milliseconds: 2000)),
                                ),
                                Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.red,
                                )
                              ],
                            );
                          });
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })))
    ]);
  }

/*  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();

  }*/

  Future<dynamic> postImage(Uint8List list) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData(list);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();

  }


/*  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    var _data = await imageFile.getByteData();
    StorageUploadTask uploadTask = reference.putData(await FlutterImageCompress.compressWithList(
      _data.buffer.asUint8List(),
      minHeight: 400,
      minWidth: 400,
    ));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }*/

  Future<List<Asset>> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = "No error Detected";

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      print(resultList.length.toString() + "it is result list");
      /*  print((await resultList[0].getThumbByteData(122, 100)));
      print((await resultList[0].getByteData()));
      print((await resultList[0].metadata));*/
      print("loadAssets is called");
    } on Exception catch (e) {
      error = e.toString();
      print(error.toString() + "on catch of load assest");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      print("Not mounted");
    } else {
      setState(() {
        images = resultList;
        _error = error;
      });
    }

    return images;
  }
  Widget _showExpansionList() {
    return Container(
      //margin: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 25, top: 25, bottom: 10),
      child: ExpansionTile(
        //leading:  Icon(Icons.arrow_drop_down_circle,color: Colors.blue,),
        title: Text(
          "Choose Main Features",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.blue,
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child:TextFormField(
                          controller: buildYear,
                          maxLength: 4,
                          validator: validateBuildYear,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Build Year:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 1,
                          validator: validateMainFeatures,
                          controller: parkingSpace,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Parking Space:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: validateMainFeatures,
                          maxLength: 2,
                          controller: Rooms,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Rooms:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 1,
                          controller: BathRooms,
                          validator: validateMainFeatures,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Bathrooms:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 1,
                          validator: validateMainFeatures,
                          controller: kitchens,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Kitchens:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: Floors,
                          maxLength: 1,
                          validator: validateMainFeatures,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Floors:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // dropdownfield of flooring
        ],
      ),
    );
  }

/*  Widget _showExpansionList() {
    return Container(
      //margin: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 25, top: 25, bottom: 10),
      child: ExpansionTile(
        //leading:  Icon(Icons.arrow_drop_down_circle,color: Colors.blue,),
        title: Text(
          "Choose Main Features",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.blue,
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: buildYear,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Build Year:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: parkingSpace,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Parking Space:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: Rooms,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Rooms:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: BathRooms,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Bathrooms:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: kitchens,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Kitchens:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: Floors,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Floors:',
                            errorText: _validate ? 'Value can,t be empty' : null,
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // dropdownfield of flooring
        ],
      ),
    );
  }*/

  Widget _showExpansionListPlot() {
    return Container(
      //margin: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 25, top: 25, bottom: 10),
      child: ExpansionTile(
        //leading:  Icon(Icons.arrow_drop_down_circle,color: Colors.blue,),
        title: Text(
          "Choose Main Features",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.blue,
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Possession:',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 50,
                          margin: const EdgeInsets.all(7.0),
                          child: Checkbox(
                            onChanged: (bool value) {
                              setState(() => this._checkBoxVal = value);
                            },
                            value: this._checkBoxVal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Corner:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      //margin: const EdgeInsets.only(left: 25.0, top: 12),
                      margin: const EdgeInsets.only(left: 50),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal2 = value);
                        },
                        value: this._checkBoxVal2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Park Facing:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(left: 5.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal3 = value);
                        },
                        value: this._checkBoxVal3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Disputed:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(left: 33, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal4 = value);
                        },
                        value: this._checkBoxVal4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Balloted:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(left: 40.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal5 = value);
                        },
                        value: this._checkBoxVal5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sui Gas:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(left: 46.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal6 = value);
                        },
                        value: this._checkBoxVal6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Water supply:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal7 = value);
                        },
                        value: this._checkBoxVal7,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sewarage:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 50,
                      margin: const EdgeInsets.only(left: 27.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal8 = value);
                        },
                        value: this._checkBoxVal8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showExpansionListCommercial() {
    return Container(
      //margin: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 25, top: 25, bottom: 10),
      child: ExpansionTile(
        //leading:  Icon(Icons.arrow_drop_down_circle,color: Colors.blue,),
        title: Text(
          "Choose Main Features",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.blue,
        ),
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: buildYear,
                          maxLength: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Build Year:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: validateBuildYear,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: parkingSpace,
                          maxLength: 1,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Parking Space:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: validateMainFeatures,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: Rooms,
                          maxLength: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Rooms:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: validateMainFeatures,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: Floors,
                          maxLength: 2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Floors:',
                            alignLabelWithHint: false,
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: validateMainFeatures,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Column(
          //   children: <Widget>[
          //     Row(
          //       children: <Widget>[
          //         Row(
          //           children: <Widget>[
          //             Container(
          //               width: 130,
          //               height: 50,
          //               margin: const EdgeInsets.all(8.0),
          //               child: TextFormField(
          //                 controller: flooring,
          //                 decoration: InputDecoration(
          //                   border: OutlineInputBorder(),
          //                   labelText: 'Flooring:',
          //                   alignLabelWithHint: false,
          //                   filled: true,
          //                 ),
          //                 keyboardType: TextInputType.text,
          //                 validator: validateMainFeatures,
          //                 textInputAction: TextInputAction.done,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ],
          // ),

          Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Elevators:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 105,
                      height: 50,
                      margin: const EdgeInsets.only(left: 82.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal = value);
                        },
                        value: this._checkBoxVal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Maintenance Staff:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 105,
                      height: 50,
                      margin: const EdgeInsets.only(top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal2 = value);
                        },
                        value: this._checkBoxVal2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Security Staff:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 105,
                      height: 50,
                      margin: const EdgeInsets.only(left: 44.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal3 = value);
                        },
                        value: this._checkBoxVal3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Waste Disposal:',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 105,
                      height: 50,
                      margin: const EdgeInsets.only(left: 27.0, top: 12),
                      child: Checkbox(
                        onChanged: (bool value) {
                          setState(() => this._checkBoxVal4 = value);
                        },
                        value: this._checkBoxVal4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Flooring  text field goes here
        ],
      ),
    );
  }

  Widget _showExpansionListPropertySizeWidthHeight() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                    labelText: 'Height'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showExpansionListPropertySizeMarlaKanal() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                //   validator: validatePropertySize,
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
                //   validator: validatePropertySize,
                //autofocus: true,

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
    );
  }

  Widget _hideExpansionList() {
    return Visibility(
      visible: false,
      child: Container(
        //margin: EdgeInsets.all(20),
        margin: EdgeInsets.only(left: 25, top: 25, bottom: 10),
        child: ExpansionTile(
          //leading:  Icon(Icons.arrow_drop_down_circle,color: Colors.blue,),
          title: Text(
            "Choose Main Features",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black45),
          ),
          trailing: Icon(
            Icons.arrow_drop_down_circle,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  widthHeightCheck() {
    if (propertySizeHeight.text.length < 2 || propertySizeWidth.text.length < 2) {
      showInSnackBar("invalid width height");
    } else {

      if (_selectedpropertyType == 'Homes') {
        TotalPropertySizeInMarla = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 250);
      } else if (_selectedpropertyType == 'Plots') {
        if (_selectedpropertyDetailType == 'Residential Plot') {
          TotalPropertySizeInMarla = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 250);
        } else if (_selectedpropertyDetailType == 'Commercial Plot') {
          TotalPropertySizeInMarla = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 225);
        }
      } else if (_selectedpropertyType == 'Commercial') {
        TotalPropertySizeInMarla = (int.parse(propertySizeWidth.text) * int.parse(propertySizeHeight.text) / 225);
      }
    }
  }

  marlaKanalCheck() {
    if (propertySizeKanal.text.isEmpty && propertySizeMarla.text.isEmpty) {
      showInSnackBar("required can not be empty");
      return false;
    } else {
      if (propertySizeKanal.text.isNotEmpty && propertySizeMarla.text.isNotEmpty) {
        String k = validatePropertySize(propertySizeKanal.text);

        if (k == null) {
          String marladouble = validatePropertySizeMarla(propertySizeMarla.text);
          print(marladouble.toString());
          if (marladouble == 'Alphabets' || marladouble == 'Special') {
            showInSnackBar("Alphabets and special character not allowed");
            return false;
          } else if (marladouble == 'double' && double.parse(propertySizeMarla.text) > 0) {
            double size = convertToMarla(int.parse(propertySizeKanal.text)).toDouble();
            TotalPropertySizeInMarla = size + double.parse(propertySizeMarla.text);
            print("marla property" + TotalPropertySizeInMarla.toString());
            print("double");
          } else if (marladouble == null && int.parse(propertySizeMarla.text) > 0) {
            int size = convertToMarla(int.parse(propertySizeKanal.text));
            TotalPropertySizeInMarla = double.parse(propertySizeMarla.text) + size.toDouble();
            print("marla property" + TotalPropertySizeInMarla.toString());
          } else {
            showInSnackBar("property size can not be in zero");
            return false;
          }
        } else {
          showInSnackBar("Numbers only please");
          return false;
        }
      } else if (propertySizeKanal.text.isNotEmpty && propertySizeMarla.text.isEmpty) {
        print("in kanal");
        String k = validatePropertySize(propertySizeKanal.text);
        if (k == null) {
          if (int.parse(propertySizeKanal.text) > 0) {
            int size = convertToMarla(int.parse(propertySizeKanal.text));
            TotalPropertySizeInMarla = size.toDouble();
            print("kanal property" + TotalPropertySizeInMarla.toString());
          } else {
            print("property size can not be in zero");
            showInSnackBar("property size can not be in zero");
            return false;
          }
        } else {
          print("Please give in whole number");
          showInSnackBar("Please give in whole number");
          return false;
        }
      } else if (propertySizeKanal.text.isEmpty && propertySizeMarla.text.isNotEmpty) {
        print("in marla");
        String marladouble = validatePropertySizeMarla(propertySizeMarla.text);
        if (marladouble == 'Alphabets') {
          print("Alphabets not allowerd");
          showInSnackBar("Alphabets not allowerd");
          return false;
        } else if (marladouble == null && double.parse(propertySizeMarla.text) > 0) {
          TotalPropertySizeInMarla = double.parse(propertySizeMarla.text);
          print("marla property" + TotalPropertySizeInMarla.toString());

          print("double");
        } else if (marladouble == 'int' && int.parse(propertySizeMarla.text) > 0) {
          int size = int.parse(propertySizeMarla.text);
          TotalPropertySizeInMarla = size.toDouble();
          print("marla property" + TotalPropertySizeInMarla.toString());
        } else {
          print("property size can not be in zero");
          showInSnackBar("property size can not be in zero");
          return false;
        }
      }
    }
  }

  int convertToMarla(int size) {
    int propertyInMarla = ((size * 100) / 5).round();

    return propertyInMarla;
  }
}
