import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/Arguments.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/screens/edit_Postscreen1.dart';
import 'package:signup/services/MakeBid.dart';
import 'package:signup/services/PostAdCreation.dart';
import 'package:signup/services/chatDatabase.dart';
import 'package:signup/showImage.dart';
import 'package:signup/viewPostAdds.dart';
import './widgets/TextIcon.dart';
import 'chat/chat.dart';
import 'helper/constants.dart';
import 'helper/helperfunctions.dart';
import 'package:number_to_words/number_to_words.dart';

class ImageCarousel extends StatefulWidget {
  static const routeName = '/ImageCarousel';
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final Firestore _firestore = Firestore.instance;
  FirebaseUser user;
  bool _validate = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  List<NetworkImage> _listOfImages = <NetworkImage>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Image> _listOfImages = <Image>[];
  List<String> imagesUrlString = <String>[];
  bool isLoading = false;
  chatdatabase Chatdatabase = new chatdatabase();
  String existingChatRoomId;

  AdPost _adPost = new AdPost();
  String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";

  @override
  void initState() {
    super.initState();
    // CurrentUser _current = Provider.of<CurrentUser>(context, listen: false);

    initUser();
  }

  Future<String> currentUser() async {
    user = await _auth.currentUser();
    return user != null ? user.uid : null;
  }

  initUser() async {
    user = await _auth.currentUser();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {});
  }

  String name;
  double bid;
  int number;
  String postId;
  double minimumBid = 0.0;

  GlobalKey<FormState> _key = new GlobalKey();
  final navigaterKey = GlobalKey<NavigatorState>();
  PostBidFirebase createBid = PostBidFirebase();
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    descTextAlign: TextAlign.start,
    animationDuration: Duration(milliseconds: 200),
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

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    postId = args.adpost.postId;

    // This is the type used by the popup menu below.

    Stream<DocumentSnapshot> getData() async* {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      Firestore.instance.collection("users").where("uid", isEqualTo: user.uid).snapshots();
    }

    createAlertDialog(BuildContext context) {
      final TextEditingController _bid = TextEditingController();

      return showDialog(
          context: _scaffoldKey.currentContext,
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: AlertDialog(
                content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return StreamBuilder(
                      stream: Firestore.instance.collection("users").where("uid", isEqualTo: user.uid).snapshots(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                            child: Form(
                                key: _key,
                                autovalidate: _validate,
                                child: Column(children: <Widget>[
                                  TextFormField(
                                    //  controller: _firstName,
                                    keyboardType: TextInputType.text,
                                    readOnly: true,
                                    //  validator: validateName,
                                    /*onSaved: (String val){
                                          name = val;
                                          print(name);
                                        },*/

                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: snapshot.data.documents[0].data["displayName"].toString()),
                                  ),
                                  TextFormField(
                                    //   controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 11,
                                    readOnly: true,
                                    //   validator:validateMobile,
                                    /* onSaved: (String val){
                                          number = int.parse(val);
                                          print(number);
                                        },*/
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: "0${snapshot.data.documents[0].data["phoneNumber"].toString()}"),
                                  ),
                                  TextFormField(
                                    controller: _bid,
                                    keyboardType: TextInputType.phone,
                                    validator: validateBid,
                                    onSaved: (String val) {
                                      bid = double.parse(val);
                                      print(bid);
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Container(
                                          margin: EdgeInsets.only(left: 14, bottom: 15),
                                          padding: EdgeInsets.only(top: 15),
                                          child: Text(
                                            '\u{20A8}',
                                            style: TextStyle(color: Color(0xff2470c7), fontSize: 21),
                                          ),
                                        ),
                                        labelText: 'Enter Offer in rupee'),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: RaisedButton(
                                      color: Color(0xff1E88E5),
                                      onPressed: () async {
                                        if (_key.currentState.validate()) {
                                          _key.currentState.save();
                                          double percent = (70 / 100);
                                          print(args.adpost.price.toString() + "this is price");
                                          print("percent + ${percent}");
                                          minimumBid = (percent * args.adpost.price);
                                          print(minimumBid.toString());
                                          if (bid < minimumBid || bid > args.adpost.price) {
                                            Alert(
                                              context: context,
                                              style: alertStyle,
                                              type: AlertType.warning,
                                              title: "Alert !!",
                                              desc: "Please make reason able Offer.",
                                              buttons: [
                                                DialogButton(
                                                  child: Text(
                                                    "Ok",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => Navigator.pop(this.context),
                                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                                  radius: BorderRadius.circular(0.0),
                                                ),
                                              ],
                                            ).show();
                                          } else {
                                            name = snapshot.data.documents[0].data["displayName"].toString();
                                            number = int.parse(snapshot.data.documents[0].data["phoneNumber"]);
                                            await makesBid(name, number, bid, postId);

                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          setState(() {
                                            _validate = true;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff1E88E5),
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Text(
                                          "Enter Offer",
                                          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ])),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      });
                }),
              ),
            );
          });
    }

    createContactDialog(BuildContext context) async {
      String userName;

      return showDialog(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: AlertDialog(
                  title: Text('Contact information\n'
                      'or Send a message'),
                  content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                    return StreamBuilder(
                        stream: Firestore.instance.collection("users").where("uid", isEqualTo: args.adpost.userId).snapshots(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: ListBody(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: TextIcon(
                                        icon: FontAwesomeIcons.user,

                                        //text: "Bedroom",
                                        text: (userName = snapshot.data.documents[0].data["displayName"].toString()),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: TextIcon(
                                        icon: FontAwesomeIcons.phone,

                                        //text: "Bedroom",
                                        text: (snapshot.data.documents[0].data["phoneNumber"].toString()),
                                      ),
                                    ),
                                  ),
                                  //  Text(snapshot.data.documents[0].data["email"].toString()),

                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: FlatButton(
                                      onPressed: () {
                                        sendMessage(args.adpost.userId, userName);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 18),
                                        height: 45,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Color(0xff1E88E5),
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Message",
                                            style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ]),
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        });
                  }),
                ),
              ),
            );
          });
    }

    deletePostAlert(BuildContext context) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you Sure you Want to Delete the Post?'),
              content: Form(
                key: _key,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  child: Text('Delete'),
                  onPressed: () async {
                    print("delete button is called post id is" + args.adpost.postId);

                    await PostAddFirebase().CopyAdToOldCollection(args.adpost.postId);
                    await PostAddFirebase().removePost(args.adpost.postId);
                    Navigator.pop(context);
                    Navigator.push(this.context, MaterialPageRoute(builder: (context) {
                      return ViewAdds();
                    }));
                  },
                ),
                MaterialButton(
                  elevation: 5.0,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigaterKey,
      home: Scaffold(
        key: _scaffoldKey,

        //  backgroundColor: Colors.blue[800],
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
            ),
          ),
          //backgroundColor: Colors.grey[800],

          title: Text("Ad Details"),
          centerTitle: true,
          leading: Container(
            //margin: EdgeInsets.only(right: 30),
            child: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          actions: <Widget>[
            user.uid == args.adpost.userId
                ? PopupMenuButton(
              itemBuilder: (content) => [
                PopupMenuItem(
                  value: 1,
                  child: Text("Edit"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Delete"),
                )
              ],
              onSelected: (int menu) {
                if (menu == 1) {
                  // navigaterKey.currentState.push(MaterialPageRoute(builder: (context) => EditPostFirstScreen(adPost: _adPost)));
                  Navigator.push(
                      this.context, MaterialPageRoute(builder: (context)=> EditPostFirstScreen(adPost: _adPost)));
                } else if (menu == 2) {
                  deletePostAlert(context);
                }
              },
            )
                : SizedBox()

//                             if(snapshot.data.documents.elementAt(
//                                 index)['uid'] != args.userId)
//                               {
//                                 return SizedBox();
//                               }
            //   }

//    ]
//
//                else{
//                  return SizedBox();
//                }
          ],
        ),

        body: user != null
            ? Container(
          child:
          //stream: Firestore.instance.collection('PostAdd').document(Pos)
          StreamBuilder(
            stream: Firestore.instance.collection('PostAdd').where("PostID", isEqualTo: args.adpost.postId).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    var am = "AM";
                    var pm = "PM";
                    var str = snapshot.data.documents.elementAt(index)['MeetingTime'];
                    var parts = str.split('-');
                    var dataBefore = parts[0].trim();                 //
                    // prefix: "date"
                    var dataAfter = parts.sublist(1).join('-').trim(); //
                    // date: "'2019:04:01'"

                    String propertySizeUnit = "";
                    if (_convertMarlaToKanal(snapshot.data.documents.elementAt(index)['PropertySize']) != "0" &&
                        _convertMarlaToMarla(snapshot.data.documents.elementAt(index)['PropertySize']) != "0") {
                      propertySizeUnit = _convertMarlaToKanal(snapshot.data.documents.elementAt(index)['PropertySize']) +
                          "  "
                              'Kanal'
                              "\n" +
                          _convertMarlaToMarla(snapshot.data.documents.elementAt(index)['PropertySize']) +
                          "  "
                              'Marla';
                    } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(index)['PropertySize']) == "0" &&
                        _convertMarlaToMarla(snapshot.data.documents.elementAt(index)['PropertySize']) != "0") {
                      propertySizeUnit = _convertMarlaToMarla(snapshot.data.documents.elementAt(index)['PropertySize']) +
                          " "
                              'Marla';
                    } else if (_convertMarlaToKanal(snapshot.data.documents.elementAt(index)['PropertySize']) != "0" &&
                        _convertMarlaToMarla(snapshot.data.documents.elementAt(index)['PropertySize']) == "0") {
                      propertySizeUnit = _convertMarlaToKanal(snapshot.data.documents.elementAt(index)['PropertySize']) +
                          " "
                              'Kanal';
                    }
                    var date = snapshot.data.documents.elementAt(index)['PostTime'].toDate();
                    var date2 = DateTime.now();
                    var difference = date2.difference(date).inDays;
                    var Price = snapshot.data.documents.elementAt(index)['Price'].toString();
                    var commaPrice = Price.replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                    var priceInWords = NumberToWord().convert('en-in', snapshot.data.documents.elementAt(index)['Price']).toString();
                    _listOfImages = [];

                    _adPost.title = snapshot.data.documents[index].data['Title'];
                    _adPost.desc = snapshot.data.documents[index].data['Description'];
                    _adPost.price = snapshot.data.documents[index].data['Price'];
                    _adPost.Address = snapshot.data.documents[index].data['Address']['Street'];
                    _adPost.AvailDays = snapshot.data.documents[index].data['AvailableDays'];
                    _adPost.City = snapshot.data.documents[index].data['Address']['city'];
                    _adPost.time = snapshot.data.documents[index].data['MeetingTime'];
                    _adPost.purpose = snapshot.data.documents[index].data['Purpose'];
                    _adPost.width = snapshot.data.documents[index].data['Width_Length']['Width'];
                    _adPost.length = snapshot.data.documents[index].data['Width_Length']['Length'];
                    _adPost.propertySize = snapshot.data.documents[index].data['PropertySize'];
                    _adPost.propertyType = snapshot.data.documents[index].data['PropertyType'];
                    _adPost.propertyDeatil = snapshot.data.documents[index].data['PropertySubType'];
                    _adPost.ImageUrls = snapshot.data.documents[index].data['ImageUrls'];
                    _adPost.postId = args.adpost.postId;

                    for (int i = 0; i < snapshot.data.documents[index].data['ImageUrls'].length; i++) {
                      imagesUrlString.add(snapshot.data.documents[index].data['ImageUrls'][i]);
                      _listOfImages.add(
                        Image.network(
                          snapshot.data.documents[index].data['ImageUrls'][i],
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
                    //final List<Image> children = snapshot.data.documents.map<Image>((e) => Image.network(e["Image Urls"].toString())).toList();
                    //List<NetworkImage> _listOfImages = <NetworkImage>[snapshot.data.documents[index].data["Image Urls"][index]];
                    return Column(
                      children: <Widget>[
                        Center(
                          child: Container(
                            height: 200,
                            child: Center(
                              child: Carousel(
                                boxFit: BoxFit.fill,
                                images: _listOfImages,
                                autoplay: false,
                                indicatorBgPadding: 1.0,
                                dotSize: 4.0,
                                dotColor: Colors.blue,
                                dotBgColor: Colors.transparent,
                                onImageTap: (index) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImageScreen(imagesUrlString.elementAt(index))));
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                snapshot.data.documents.elementAt(index)['Title'],
                                style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w700, fontSize: 20),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 16.0),
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey, width: 0.4),
                                    bottom: BorderSide(color: Colors.grey, width: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                        ? Container()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['MainFeatures']['Rooms'].toString() == null
                                        ? SizedBox.shrink()
                                        : TextIcon(
                                      icon: FontAwesomeIcons.bed,

                                      //text: "Bedroom",
                                      text: ('${snapshot.data.documents.elementAt(index)['MainFeatures']['Rooms'].toString()} Rooms'),
                                    ),
//                                      snapshot
//                                          .data.documents.elementAt(index)["UnitArea"] !=null? TextIcon(
//                                        icon: FontAwesomeIcons.home,
//                                        text: ('${snapshot
//                                            .data.documents
//                                            .elementAt(index)['PropertySize']}' " " '${snapshot
//                                            .data.documents
//                                            .elementAt(index)['UnitArea']}'),
//                                      ): SizedBox.shrink(),
                                    //              snapshot
                                    //                    .data.documents.elementAt(index)['Main Features']['Bathrooms'].toString()=="false" ? SizedBox.shrink() :
                                    snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                        ? Container()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                        ? SizedBox.shrink()
                                        : snapshot.data.documents.elementAt(index)['MainFeatures']['Bathrooms'].toString() == null
                                        ? SizedBox.shrink()
                                        : TextIcon(
                                      icon: FontAwesomeIcons.shower,
                                      text:
                                      ('${snapshot.data.documents.elementAt(index)['MainFeatures']['Bathrooms'].toString()} Bathroom'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                padding: const EdgeInsets.only(bottom: 10.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey, width: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        allWordsCapitilize(priceInWords) + 'Rupees',
                                        style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 0,
                                  ),
                                  Container(
                                      width: 150,
                                      child: Text(
                                        'Time On Property Host: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    difference.toString() + "  Days",
                                    style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Description",
                                style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  _adPost.desc = snapshot.data.documents.elementAt(index)['Description'],
                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w400, fontSize: 16, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Center(
                                  child: Text(
                                    "Details",
                                    style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 20),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Card(
                                  color: Colors.grey[100],
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //crossAxisAlignment: CrossAxisAlignment.start,

                                    children: <Widget>[
                                      Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Type: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['PropertyType'],
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Sub Type: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['PropertySubType'],
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Price: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  commaPrice,
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Container(
                                          height: 60,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Address: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Flexible(
                                                    child: Container(
                                                        child: Text(
                                                          snapshot.data.documents[index].data['Address']['Street'],
                                                          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                        ))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Area: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Text(
                                                  propertySizeUnit,
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['Width_Length']['Width'] != ''
                                          ? Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Width: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Text(
                                                  snapshot.data.documents.elementAt(index)['Width_Length']['Width'].toString() + ' Feet',
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                          :SizedBox.shrink(),
                                      snapshot.data.documents.elementAt(index)['Width_Length']['Width'] != ''
                                          ? Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Length: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                Text(
                                                  snapshot.data.documents.elementAt(index)['Width_Length']['Length'].toString() + ' Feet',
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                          : SizedBox.shrink(),
                                      Card(
                                        child: Container(
                                          height: 50,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 70,
                                                    child: Text(
                                                      'Purpose: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['Purpose'],
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                            ? SizedBox.shrink()
                            : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                            ? Container()
                            : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                            ? SizedBox.shrink()
                            : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                            ? SizedBox.shrink()
                            : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                            ? SizedBox.shrink()
                            : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                            ? Container()
                            : Container(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Center(
                                  child: Text(
                                    "Main Features",
                                    style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 20),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Card(
                                  color: Colors.grey[100],
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Sewarege'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          // color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Sewarage: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Sewarege']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Sewarege']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Balloted'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Balloted: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Balloted']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Balloted']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Corner'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Corner: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Corner']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Corner']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Disputed'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Disputed: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Disputed']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Disputed']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['MainFeatures']
                                      ['Parkfacing']
                                          .toString() ==
                                          null
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Park Facing: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Parkfacing']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Parkfacing']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Possession'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Possession: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Possession']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Possession']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['suigas'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Sui Gas: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['suigas']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['suigas']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['watersupply'].toString() == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),

                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 100,
                                                        child: Text(
                                                          'Water Supply: ',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['watersupply']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['watersupply']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Buildyear'].toString() == null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Built in Year: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['MainFeatures']['Buildyear'],
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Parkingspace'].toString() == null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Parking Spaces: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['MainFeatures']['Parkingspace'],
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Rooms'].toString() == null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Beds: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Flexible(
                                                    child: Text(
                                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Rooms'],
                                                      style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 12,
                                                          color: Colors.grey[800]),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      //  snapshot
                                      //    .data.documents.elementAt(index)['Main Features']['Bathrooms'].toString()=="false" ? SizedBox.shrink() :
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['MainFeatures']['Bathrooms']
                                          .toString() ==
                                          null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Bathrooms: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['MainFeatures']
                                                  ['Bathrooms'],
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
                                          "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['PropertySubType'] ==
                                          "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['MainFeatures']['kitchens']
                                          .toString() ==
                                          "false"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents
                                          .elementAt(index)['MainFeatures']
                                      ['kitchens']
                                          .toString() ==
                                          null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Kitchens: ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents
                                                      .elementAt(index)[
                                                  'MainFeatures']['kitchens']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Floors'].toString() == null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Floors: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['MainFeatures']['Floors'].toString(),
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Flooring'].toString() == "false"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Flooring'] ==
                                          null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Flooring: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),

                                                Text(
                                                  snapshot.data.documents
                                                      .elementAt(index)['MainFeatures']['Flooring']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
//                                      snapshot.data.documents.elementAt(index)['MainFeatures']['Wastedisposal'].toString() == "false"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Office"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Shop"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Factory"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Building"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Other"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
//                                          "Agricultural Plot"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
//                                          "Residential Plot"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
//                                          "commercial Plot"
//                                          ? Container()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
//                                          "Industrial Plot"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] ==
//                                          "Plot Form"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents
//                                          .elementAt(index)['PropertySubType'] ==
//                                          "Plot File"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents
//                                          .elementAt(index)['PropertySubType'] ==
//                                          "Pent House"
//                                          ? SizedBox.shrink()
//                                          : snapshot.data.documents
//                                          .elementAt(index)['MainFeatures']
//                                      ['Wastedisposal']
//                                          .toString() ==
//                                          null
//                                          ? SizedBox.shrink()
//                                          : Card(
//                                        child: Container(
//                                          height: 50,
//                                          //color: Colors.grey[100],
//                                          child: Padding(
//                                            padding: const EdgeInsets.all(8.0),
//                                            child: Row(
//                                              mainAxisAlignment:
//                                              MainAxisAlignment.start,
//                                              //crossAxisAlignment: CrossAxisAlignment.center,
//                                              children: <Widget>[
//                                                //                             Icon(Icons.schedule,),
//                                                Container(
//                                                    width: 100,
//                                                    child: Text(
//                                                      'Waste Disposal: ',
//                                                      style: TextStyle(
//                                                          fontWeight:
//                                                          FontWeight.bold),
//                                                    )),
//                                                SizedBox(
//                                                  width: 50,
//                                                ),
//                                                snapshot.data.documents
//                                                    .elementAt(
//                                                    index)['MainFeatures']['Wastedisposal']
//                                                    .toString()== "true"?
//                                                Text("Available",style: TextStyle(
//                                                    fontFamily: "Poppins",
//                                                    fontWeight: FontWeight
//                                                        .w500,
//                                                    fontSize: 12,
//                                                    color: Colors.grey[800]),):snapshot.data
//                                                    .documents
//                                                    .elementAt(
//                                                    index)['MainFeatures']['Wastedisposal']
//                                                    .toString()== "false"?
//                                                Text("Not Available",style: TextStyle(
//                                                    fontFamily: "Poppins",
//                                                    fontWeight: FontWeight
//                                                        .w500,
//                                                    fontSize: 12,
//                                                    color: Colors.grey[800]),
//                                                ):SizedBox.shrink(),
//                                              ],
//                                            ),
//                                          ),
//                                        ),
//                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()

                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Elevators'] ==
                                          null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Elevators: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Elevators']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Elevators']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()

                                          : snapshot.data.documents.elementAt(index)['MainFeatures']['Wastedisposal'] ==
                                          null
                                          ? SizedBox.shrink()
                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Waste Disposal: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Wastedisposal']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['Wastedisposal']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
//                                    snapshot
//                                        .data.documents.elementAt(index)['Main Features']['Floors']!=null?Container(
//                                      height: 50,
//                                      color: Colors.grey[100],
//                                      child: Padding(
//                                        padding: const EdgeInsets.all(8.0),
//                                        child: Row(
//                                          mainAxisAlignment: MainAxisAlignment.start,
//                                          //crossAxisAlignment: CrossAxisAlignment.center,
//                                          children: <Widget>[
//                                            //                             Icon(Icons.schedule,),
//                                            Container(
//                                                width: 70,
//
//                                                child: Text(
//                                                  'Floors: ',
//                                                  style: TextStyle(
//                                                      fontWeight: FontWeight.bold),
//                                                )),
//                                            SizedBox(
//                                              width: 50,
//                                            ),
//
//                                            Text(snapshot
//                                                .data.documents.elementAt(index)['Main Features']['Floors']),
//                                          ],
//                                        ),
//                                      ),
//                                    ):SizedBox.shrink(),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['MaintenanceStaff'] == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Maintenance Staff: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['MaintenanceStaff']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['MaintenanceStaff']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      snapshot.data.documents.elementAt(index)['MainFeatures']['SecurityStaff'] == null
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "WareHouse"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Flat"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Upper Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Lower Portion"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Farm House"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Agricultural Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Residential Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Commercial Plot"
                                          ? Container()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Industrial Plot"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot Form"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Plot File"
                                          ? SizedBox.shrink()
                                          : snapshot.data.documents.elementAt(index)['PropertySubType'] == "Pent House"
                                          ? SizedBox.shrink()

                                          : Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Security Staff: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['MainFeatures']['SecurityStaff']
                                                    .toString()== "true"?
                                                Text("Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),):snapshot.data
                                                    .documents
                                                    .elementAt(
                                                    index)['MainFeatures']['SecurityStaff']
                                                    .toString()== "false"?
                                                Text("Not Available",style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontSize: 12,
                                                    color: Colors.grey[800]),
                                                ):SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Center(
                                  child: Text(
                                    "Meeting Schedule",
                                    style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 20),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Card(
                                  color: Colors.grey[100],
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Available Days: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 35,
                                                ),

                                                Text(
                                                  snapshot.data.documents.elementAt(index)['AvailableDays'],
                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Container(
                                          height: 50,
                                          //color: Colors.grey[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                //                             Icon(Icons.schedule,),
                                                Container(
                                                    width: 100,
                                                    child: Text(
                                                      'Meeting Time: ',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    )),
                                                SizedBox(
                                                  width: 35,
                                                ),

                                                Text(snapshot.data.documents.elementAt(index)['MeetingTime'],
//                                           dataBefore,
                    //"${dataBefore}AM -",

                                                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                ),
                                                // Text(
                                                //   " ${dataAfter}PM",
                                                //   style: TextStyle
                                                //     (fontFamily: "Poppins",
                                                //       fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[800]),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        user.uid == snapshot.data.documents.elementAt(index)['uid']
                            ? Column(
                          children: <Widget>[
                            Container(
                              // margin: EdgeInsets.only(top: 30),
                              child: Container(
                                //color: Colors.grey[500],
                                color: Colors.teal[700],
                                width: 331,
                                height: 25,
                                child: Center(
                                  child: Text(
                                    'Offers List',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              //width: 320,
                              height: 100,
                              margin: EdgeInsets.only(left: 14, right: 14, bottom: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black26,
                                ),
                                borderRadius: new BorderRadius.only(
                                  bottomLeft: const Radius.circular(10.0),
                                  bottomRight: const Radius.circular(10.0),
                                ),
                              ),
                              child: StreamBuilder(
                                  stream: Firestore.instance.collection('BidList').where('PostID', isEqualTo: args.adpost.postId).snapshots(),
                                  // ignore: missing_return
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.data == null) return CircularProgressIndicator();
                                    if (snapshot.data.documents.length != 0) {
                                      return ListView.builder(
                                          itemCount: snapshot.data.documents.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Container(
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    title: Text(
                                                      snapshot.data.documents[index].data['Name'].toString().toUpperCase(),
                                                      style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                                    ),
                                                    leading: CircleAvatar(
                                                      //backgroundImage: NetworkImage(w),
                                                      // backgroundColor: Colors.blueGrey,
                                                      backgroundImage: CachedNetworkImageProvider(data.toString()),
                                                    ),
                                                    // subtitle: Text(username),
                                                    //subtitle: Text(accountCreated.toString()),
                                                    subtitle: Row(
                                                      children: [
                                                        Text(
                                                          'Number: ',
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                                        ),
                                                        Text(
                                                          snapshot.data.documents[index].data['Number'].toString().toUpperCase(),
                                                          style: TextStyle(fontSize: 12, color: Colors.black45),
                                                        ),
                                                      ],
                                                    ),
                                                    //trailing: Text(timeago.format(timestamp.toDate())),
                                                    trailing: Container(
                                                      margin: EdgeInsets.all(10),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Bid',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                          Text(
                                                            snapshot.data.documents[index].data['Bid'].toString().toUpperCase(),
                                                            style: TextStyle(fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(),
                                                ],
                                              ),
                                            );
                                          });
                                    } else {
                                      return Container(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(top: 7),
                                              child: Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Container(
                                                    child: Center(
                                                      child: Text(
                                                        'No Offers Yet !',
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      );
                                    }
                                    // else if(snapshot.hasError || snapshot == null)

//
                                  }),
                            ),
                          ],
                        )
                            : SizedBox.shrink(),
                        user.uid != snapshot.data.documents.elementAt(index)['uid']
                            ? Row(
                          children: <Widget>[
                            snapshot.data.documents.elementAt(index)['Purpose'] == "For Rent"
                                ? Container()
                                : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                onPressed: () {
                                  createAlertDialog(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 18),
                                  height: 45,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Color(0xff1E88E5),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Make Offer",
                                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            snapshot.data.documents.elementAt(index)['Purpose'] != "For Rent"
                                ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlatButton(
                                onPressed: () {
                                  createContactDialog(context);
                                },
                                child: Container(
                                  height: 45,
                                  width: 100,
                                  margin: EdgeInsets.only(left: 0),
                                  decoration: BoxDecoration(
                                    color: Color(0xff1E88E5),
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Contact",
                                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                margin: EdgeInsets.only(left: 85),
                                child: FlatButton(
                                  onPressed: () {
                                    createContactDialog(context);
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 80,
                                    margin: EdgeInsets.only(left: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      border: Border.all(width: 1.0),
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Contact",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Container(),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 15, left: 5),
//                          child: Text(
//                          snapshot.data['displayName'],
//                            style: TextStyle(
//                              color: Colors.black,
//                              fontSize: 16,
//                              fontWeight: FontWeight.bold,
//                            ),
//                          ),
//                        ),
                        //Text(snapshot.data['displayName'],),
                        //Text(snapshot.data['email'],),
//Image.network(snapshot.data['url'],),
                      ],
                    );
                  },
                );
              } else {
                debugPrint('Loading...');
                return Center(
                  child: Text('Loading...'),
                );
              }
            },
          ),
        )
            : Center(child: Text("Error")),
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  ///
  sendMessage(String uid, String userName) async {
    List<String> users = [user.uid, uid];
    String chatRoomName = getChatRoomId(Constants.myName, userName);
    String chatRoomId = getChatRoomId(user.uid, uid);
    //print("${users} " + " ${chatRoomId}");
    print(chatRoomId);
    Map<String, dynamic> chatRoom = {
      "user1": {"id": user.uid, "Block": false},
      "user2": {"id": uid, "Block": false},
      "chatRoomName": chatRoomName,
      "users": users
    };

    bool check = await checkUserExistingChat(chatRoomId,user.uid,uid);
    if (check == true) {
      print("user chat exists navigating to chats");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
              chatRoomId: existingChatRoomId,
              userName: userName,
              sendUserId: user.uid,
            )),
      );

    } else {
      print("check is false new chat begin");
      Chatdatabase.addChatRoom(chatRoom, chatRoomId);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
              chatRoomId: chatRoomId,
              userName: userName,
              sendUserId: user.uid,
            )),
      );
    }
  }

  Future<bool> checkUserExistingChat(chatRoomId,userId,uid) async {
    List<String> chatNew = [];
    bool flag = false;
    List<String> id = [];
    QuerySnapshot documentSnapshot = await chatdatabase().checkChatRoomIdInDataBase();
    print(documentSnapshot.documents.length.toString());

    documentSnapshot.documents.forEach((element) {
      print(element.documentID.toString() + "inside the foreach");
      chatNew.add(element.documentID);
    });
    for (int i = 0; i < chatNew.length; i++) {
      id = chatNew[i].split("_");
      for (int j = 0; j < id.length; j++) {
        if (id.contains(user.uid) && id.contains(uid)) {
          print(chatNew[i].toString() + "chatNew");
          // chatNew[i] = user.uid;
          existingChatRoomId = chatNew[i].toString();
          flag = true;
          return flag;
        }
      }
    }

    return flag;
  }

  void makesBid(String name, int number, double bid, String postId) async {
    createBid.CreateBid(name, number, bid, postId);
    //showAlert("uploaded successfully");
    //Navigator.of(context).pop();
  }

  bool _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      return true;
    } else {
      // validation error
      setState(() {
        _validate = true;
        return false;
      });
    }
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

  String allWordsCapitilize(String str) {
    return str.toLowerCase().split(' ').map((word) {
      String leftText = word.length > 1 ? word.substring(1, word.length) : '';
      return word?.length > 0 ? word[0].toUpperCase() + leftText : '';
    }).join(' ');
  }
}
