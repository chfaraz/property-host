import 'package:cloud_firestore_platform_interface/src/geo_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/screens/edit_Postscreen2.dart';
import 'package:signup/screens/postscreen2.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../AppLogic/validation.dart';
import 'package:signup/choseOnMap.dart';

class EditPostFirstScreen extends StatefulWidget {
  @override
  _EditPostFirstScreenState createState() => _EditPostFirstScreenState();
  final AdPost adPost;
  EditPostFirstScreen({this.adPost});
}

class _EditPostFirstScreenState extends State<EditPostFirstScreen> {
// Controllers of text fields

  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();

  TextEditingController MetTimeController = new TextEditingController();
  TextEditingController AvailDays = new TextEditingController();
  TextEditingController cityController = new TextEditingController();

  // ends here

  String title;
  String desc;
  int price;
  String location;
  String purpose;

  String description;

  String dropdownTo;
  String dropdownFrom;
  String dropdownCondition;
  String _selectedPurpose;
  GeoPoint CordFromMap;

  List<String> _purpose = ['For Sale', 'For Rent'];

  GlobalKey<FormState> _key = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;
  AdPost adpost = new AdPost();
  String _selectedDay;
  String _selectedDay2;
  TimeRange _selectedTime;
  List<String> _Day = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
    'Only Monday',
    'Only Tuesday',
    'Only Wednesday',
    'Only Thursday',
    'Only Friday',
    'Only Saturday',
    'Only Sunday',
  ];
  List<String> _Day2 = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  @override
  void initState() {
    super.initState();
    titleController.text = widget.adPost.title;
    descController.text = widget.adPost.desc;
    priceController.text = widget.adPost.price.toString();
    MetTimeController.text = widget.adPost.time;
    AvailDays.text = widget.adPost.AvailDays;
    cityController.text = widget.adPost.City;
    addressController.text = widget.adPost.Address;
    _selectedPurpose = widget.adPost.purpose;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return SafeArea(
        child: GestureDetector(
      onPanDown: (pd) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
//      backgroundColor: Colors.grey[600],
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
          title: Container(margin:EdgeInsets.only(right:30),child: Center
            (child:
          Text
            ("Update Your "
              "Ad"))),
        ),
        body: Container(
//        decoration: BoxDecoration(
//          image: DecorationImage(
//            image: AssetImage("assets/background.png"),
//            fit: BoxFit.cover,
//          ),
//        ),
          //   padding: EdgeInsets.all(16.0),
          child: Form(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                /*   Center(
                  child: Text(
                    "Post New Ad",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),*/
                AddPost(context),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                ),
              ], //:TODO: implement upload pictures
            ),
          ),
        ),
      ),
    ));
  }

  Widget AddPost(BuildContext context) {
    final node = FocusScope.of(context);
    return Form(
      key: _key,
      autovalidate: _validate,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Column(children: <Widget>[
          TextFormField(
            controller: titleController,
            keyboardType: TextInputType.text,
            validator: validateTitle,
            onSaved: (String val) {
              title = val;
            },
            maxLines: 1,
            autofocus: true,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.title,
                  color: Color(0xff2470c7),
                ),
                //  hintText: widget.adPost.title,
                labelText: 'Title'),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
          ),
          TextFormField(
            controller: descController,
            keyboardType: TextInputType.text,
            validator: ValidateDescp,
            onSaved: (String val) {
              description = val;
            },
            maxLines: 2,
            autofocus: true,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.description,
                  color: Color(0xff2470c7),
                ),
                labelText: 'Description'),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            //textAlign: TextAlign,
          ),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: validatePrice,
            maxLength: 11,
            decoration: InputDecoration(
                prefixIcon: Container(
                  margin: EdgeInsets.only(left: 14, bottom: 15),
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    '\u{20A8}',
                    style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                  ),
                ),
                labelText: 'Price'),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
          ),
          TextFormField(
            controller: cityController,
            keyboardType: TextInputType.text,
            validator: ValidateDescp,
            // onSaved: (String val) {
            //   description = val;
            // },
            maxLines: 1,
            autofocus: true,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.location_city,
                  color: Color(0xff2470c7),
                ),
                labelText: 'City'),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            //textAlign: TextAlign,
          ),
          TextFormField(
            autofocus: true,
            controller: addressController,
            keyboardType: TextInputType.text,
            validator: ValidateLocation,
            // onSaved: (String val) {
            //   description = val;
            // },
            maxLines: 1,
            //autofocus: true,
            decoration: InputDecoration(
                prefixIcon: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.pin_drop,
                    color: Color(0xff2470c7),
                  ),
                ),
                labelText: 'Enter Address ! Example: G-10/1 Islamabad ,'),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
          ),
          _showonMap(context),
          _getPurposeDropDown(),
          //_UnitAreaDropDown(),
          //_propertySize(),
          _selectMeetingTime(),

          Container(
            margin: EdgeInsets.only(top: 20),
            child: RaisedButton(
              child: Text("Next"),
              onPressed: () {
                if (_key.currentState.validate()) {
                  _key.currentState.save();

                  if (CordFromMap != null) {
                    if (_selectedTime != null) {
                      if (_selectedDay2 == null) {
                        adpost.title = titleController.text;
                        adpost.desc = descController.text;
                        adpost.price = int.parse(priceController.text);
                        adpost.City = cityController.text;
                        adpost.Address = addressController.text;
                        adpost.purpose = _selectedPurpose;
                        adpost.AvailDays = _selectedDay;
                        adpost.location = CordFromMap;
                        adpost.propertyType = widget.adPost.propertyType;
                        adpost.propertyDeatil = widget.adPost.propertyDeatil;
                        adpost.ImageUrls = widget.adPost.ImageUrls;
                        adpost.postId = widget.adPost.postId;
                      } else {
                        adpost.title = titleController.text;
                        adpost.desc = descController.text;
                        adpost.price = int.parse(priceController.text);
                        adpost.City = cityController.text;
                        adpost.Address = addressController.text;
                        adpost.purpose = _selectedPurpose;
                        adpost.AvailDays = _selectedDay + "-" + _selectedDay2;
                        adpost.location = CordFromMap;
                        adpost.propertyType = widget.adPost.propertyType;
                        adpost.propertyDeatil = widget.adPost.propertyDeatil;
                        adpost.ImageUrls = widget.adPost.ImageUrls;
                        adpost.postId = widget.adPost.postId;
                      }
                      Navigator.push(this.context,
                          MaterialPageRoute(builder: (context) {
                        return EditPostSecondScreen(adpost);
                      }));
                    } else {
                      showInSnackBar("Please Mention Meeting Time");
                    }
                  } else {
                    showInSnackBar("Please choose your location");
                  }
                } else {
                  setState(() {
                    _validate = true;
                  });
                }
              },
              textColor: Colors.black,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              splashColor: Colors.grey,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _showonMap(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 9, bottom: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.map,
                color: Colors.white,
                textDirection: TextDirection.ltr,
              ),
              label: FlatButton(
                onPressed: () {
                  _navigateAndDisplaySelection(context);
                },
                child: Text(
                  'Select Area on Map',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    CordFromMap = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChoseOnMap()),
    );
    print("${CordFromMap} " + " got result from map screen");
  }

  Widget _getPurposeDropDown() {
    return Builder(
      builder: (context) => Row(
        children: <Widget>[
          //Icon(Icons.map, color: Colors.grey),
          Container(
              //margin: EdgeInsets.only(left: 5,),
              //width: 7.0,
              ),
          Flexible(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.home,
                        color: Color(0xff2470c7),
                      ),
                    ),
                    labelText: 'Select Purpose'),
                value: _selectedPurpose,
                onChanged: (newValue) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _selectedPurpose = newValue;
                    //                _selectedPropertyTypeData = _getCities().first;
                  });
                },
                items: _purpose.map((purpose) {
                  return DropdownMenuItem(
                    child: Text(purpose),
                    value: purpose,
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a purpose' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectMeetingTime() {
    return Container(
      //constraints: BoxConstraints(maxWidth: 250),
//margin: EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
//              Container(
//                  //margin: EdgeInsets.only(right: 10, top: 15),
//                  child: Text(
//                    'Available Days:',
//                    style: TextStyle(fontSize: 14),
//                  )),
              Container(
                //              width:225,
                child: Column(
                  children: <Widget>[
                    _getDayDropDown(),
                    _selectedDay == "Mon"
                        ? _getDay2Dropdown()
                        : _selectedDay == "Tue"
                            ? _getDay2Dropdown()
                            : _selectedDay == "Wed"
                                ? _getDay2Dropdown()
                                : _selectedDay == "Thu"
                                    ? _getDay2Dropdown()
                                    : _selectedDay == "Fri"
                                        ? _getDay2Dropdown()
                                        : _selectedDay == "Sat"
                                            ? _getDay2Dropdown()
                                            : _selectedDay == "Sun"
                                                ? _getDay2Dropdown()
                                                : Container(),
                  ],
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) => Row(
              children: <Widget>[
//                Container(
//                    margin: EdgeInsets.only(right: 10, top: 15),
//                    child: Text(
//                      'Mention Time :',
//                      style: TextStyle(fontSize: 15),
//                    )),
                Row(
                  children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
//                    child: Container(
//                      width: 200,
//                      child: TextFormField(
//                        controller: MetTimeController,
//                        keyboardType: TextInputType.text,
//                        maxLines: 1,
//                        //autofocus: true,
//
//                        decoration: InputDecoration(
//                            prefixIcon: Icon(
//                              Icons.access_time,
//                              color: Color(0xff2470c7),
//                            ),
//                            labelText: '1-3 pm ,'),
//
//                        validator: (value) =>
//                        value.isEmpty ? 'Time Field can\'t be empty' : null,
//                      ),
//                    ),
//                  ),
                    Container(
                      margin: EdgeInsets.only(top: 25, left: 52),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: RaisedButton.icon(
                              onPressed: () {},
                              icon: Icon(
                                Icons.access_time,
                                color: Colors.white,
                                textDirection: TextDirection.ltr,
                              ),
                              label: FlatButton(
                                onPressed: () async {
                                  _selectedTime = await showTimeRangePicker(
                                      context: context,
                                      start: TimeOfDay(hour: 9, minute: 0),
                                      end: TimeOfDay(hour: 12, minute: 0),
                                    //  use24HourFormat: false,
                                      strokeWidth: 4,
                                      ticks: 24,
                                      ticksOffset: -7,
                                      ticksLength: 15,
                                      ticksColor: Colors.grey,
                                      labels: [
                                        "12 am",
                                        "3 am",
                                        "6 am",
                                        "9 am",
                                        "12 pm",
                                        "3 pm",
                                        "6 pm",
                                        "9 pm"
                                      ].asMap().entries.map((e) {
                                        return ClockLabel.fromIndex(
                                            idx: e.key, length: 8, text: e.value);
                                      }).toList(),
                                      labelOffset: 35,
                                      rotateLabels: false,
                                      padding: 60);

                                  adpost.Fromtime = _selectedTime.startTime.format(context);
                                  adpost.endtime = _selectedTime.endTime.format(context);
                                  print("result " +
                                      _selectedTime.startTime.format(context) +
                                      " - " +
                                      _selectedTime.endTime.format(context));
                                },
                                child: Text(
                                  'Set Your Available Time',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
//                    RaisedButton.icon(
//
//                      icon: Icon(
//                        Icons.map,
//                        color: Colors.white,
//                        textDirection: TextDirection.ltr,
//                      ),
//                      label: FlatButton(
//
//
//
//                      child: Text("Set Your Available Time",style: TextStyle(color: Colors.white),),
//                    ),
//                      color: Colors.deepPurple,
//                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDayDropDown() {
    return Builder(
      builder: (context) => Row(
        children: <Widget>[
          //Icon(Icons.map, color: Colors.grey),
          Flexible(
            child: Container(
              //     width:230,
              child: ButtonTheme(
                alignedDropdown: true,
                child: Center(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        // margin: EdgeInsets.only(right: 20,left: 5),
                        child: Icon(
                          Icons.calendar_today,
                          color: Color(0xff2470c7),
                        ),
                      ),
                      labelText: 'Select Your Available Days',
                    ),
                    value: _selectedDay,
                    onChanged: (newValue) {
                      setState(() {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectedDay = newValue;
                        //_selectedpropertyDetailType = _getPropertyTypeDetails().first;
                      });
                    },
                    items: _Day.map((propertyType) {
                      return DropdownMenuItem(
                        child: Center(
                            child: Text(
                          propertyType,
                        )),
                        value: propertyType,
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Day is required' : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDay2Dropdown() {
    return Builder(
      builder: (context) => Row(
        children: <Widget>[
          //Icon(Icons.map, color: Colors.grey),
//          Container(
//            //margin: EdgeInsets.only(left: 5,),
//            width: 7.0,
//          ),
          Flexible(
            child: Container(
              //width:230,
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      prefixIcon: Container(
                        // margin: EdgeInsets.only(right: 20,left: 5),
                        child: Icon(
                          Icons.calendar_today,
                          color: Color(0xff2470c7),
                        ),
                      ),
                     /* prefixIcon: Container(
                        margin: EdgeInsets.only(right: 30),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xff2470c7),
                        ),
                      ),*/
                      labelText: 'To'),
                  //hint: Text('Choose Property Type Detail'),
                  value: _selectedDay2,
                  onChanged: (newValue) {
                    setState(() {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      _selectedDay2 = newValue;
                    });
                  },
                  items: _Day2.map((propertyType) {
                    return DropdownMenuItem(
                      child: Text(propertyType),
                      value: propertyType,
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Field cant be null' : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
