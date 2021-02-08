import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signup/Arguments.dart';
import 'package:signup/ImageCarousel.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/models/AgentUser.dart';
import 'package:signup/models/user.dart';
import 'package:signup/rating.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/services/agentDatabase.dart';
import 'package:signup/services/chatDatabase.dart';

import 'chat/chat.dart';
import 'helper/constants.dart';
import 'helper/helperfunctions.dart';
import 'locateAgent.dart';

// ignore: must_be_immutable
class MyProfileFinal extends StatefulWidget {
  static const routeName = '/myProfileFinal';
  String uid;

  MyProfileFinal({this.uid});

  String image;

  @override
  _MyProfileStateFinal createState() => _MyProfileStateFinal(
        uid: this.uid,
      );
}

class _MyProfileStateFinal extends State<MyProfileFinal> {
  final reviewKey = GlobalKey<ScaffoldState>();
  String uid;
  String Two;
  final String _listings = "Listings";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAdmin = true;
  double allRatingSum = 0.0;
  String stars = "0";
  String userName;
  int averageOfRating = 0;
  chatdatabase Chatdatabase = new chatdatabase();
  String existingChatRoomId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _MyProfileStateFinal({this.uid});
  FirebaseUser user;
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }
  bool _validate = false;
  GlobalKey<FormState> _key = new GlobalKey();


  @override
  void initState() {
    super.initState();
    // CurrentUser _current = Provider.of<CurrentUser>(context, listen: false);

    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {});
  }

  AdPost adPost = new AdPost();


  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _showContact(context));

    // Size screenSize = MediaQuery.of(context.size;
    final data = ModalRoute.of(context).settings.arguments as String;


    ReportAlert(BuildContext context,String agentNumber,String agentname) {
      final TextEditingController report = TextEditingController();
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text('Report Form',style: TextStyle
                (fontSize: 16,fontFamily: "Poppins",fontWeight: FontWeight.w800),)),
             content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return user.uid !=data ? StreamBuilder(
                  stream: Firestore.instance.collection("users").where("uid", isEqualTo: user.uid).snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: ListBody(children: <Widget>[
                            Form(
                              key:_key,
                              autovalidate: _validate,
                             child: TextFormField(
                                controller: report,
                                keyboardType: TextInputType.text,
                                validator: ValidateDescp,
                                maxLength: 200,
                                // onSaved: (String val) {
                                //   bid = double.parse(val);
                                //   print(bid);
                                // },
                                decoration: InputDecoration(

                                    labelText: 'Enter Report'),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(right: 60,left: 30),
                              child: MaterialButton(
                                elevation: 5.0,
                                child: Text('Submit',style: TextStyle
                                  (fontSize: 14,fontFamily: "Poppins",fontWeight:
                                FontWeight.w500),),
                                onPressed: () async {
                                  print("pressed");
                                  if(_key.currentState.validate()){
                                    _key.currentState.save();
                                    OurUser user = OurUser();
                                    AgentUser agentuser = AgentUser();
                                    user.phoneNumber = snapshot.data.documents[0]['phoneNumber'];
                                    user.displayName =snapshot.data.documents[0]['displayName'] ;
                                    user.uid = snapshot.data.documents[0].documentID.toString();
                                    user.UserType= snapshot.data.documents[0]['UserType'].toString();
                                    user.feedback = report.text.toString();
                                    agentuser.phoneNumber =agentNumber;
                                    agentuser.Name = agentname ;
                                    agentuser.uid = data;
                                    AgentDatabase().ReportAgent(agentuser,user);

                                    Navigator.pop(context);
                                  }
                                  else{
                                    setState(() {
                                      _validate = true;
                                    });
                                  }

                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 30),
                              child: MaterialButton(
                                elevation: 5.0,
                                child: Text('Cancel',style: TextStyle
                                  (fontSize: 14,fontFamily: "Poppins",fontWeight:
                                FontWeight.w500),),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),

                          ]),
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }):Container();
            }),
            );
          });
    }

    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xffF5F5F5),
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('Agent Profile'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              Container(
                height: 50,
                width: 40,
                child: StreamBuilder(
                    stream: Firestore.instance.collection('users').where("uid", isEqualTo: data).snapshots(),
                    // ignore: missing_return
                    builder:
                    // ignore: missing_return
                        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,

                            // ignore: missing_return
                            itemBuilder: (BuildContext context, int index) {
                              {
                                return user.uid !=data
                                    ? PopupMenuButton(
                                  itemBuilder: (content) => [
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text("Report Agent"),
                                    ),

                                  ],
                                  onSelected: (int menu) {
                                    if (menu == 1) {
                                      ReportAlert(context,snapshot.data.documents[0]['phoneNumber'].toString(),snapshot.data.documents[0]['displayName'].toString());
                                    }
                                  },
                                )
                                    : SizedBox();
                              }
                            });
                      }else{
                        return Container();
                      }

                    }),
              ),
            ],
            elevation: 0.0,
          ),
          body: user != null
              ? Container(
                  child: StreamBuilder(
                    stream: Firestore.instance.collection('users').where("uid", isEqualTo: data).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: <Widget>[
                                Ink(
                                  color: Color(0xff2D3040),
                                  height: 120,
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 55.0),
                                      //              _buildProfileImage(),
                                      snapshot.data.documents.elementAt(index)['image'] != null
                                          ? Center(
                                              child: Container(
                                                width: 120.0,
                                                height: 120.0,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(snapshot.data.documents.elementAt(index)['image']),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(50.0),
                                                  border: Border.all(
                                                    color: Color(0xffE1E1E1),
                                                    width: 5.0,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Container(
                                                width: 100.0,
                                                height: 100.0,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(snapshot.data.documents.elementAt(index)['avatarUrl']),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(50.0),
                                                  border: Border.all(
                                                    color: Colors.black26,
                                                    width: 2.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      snapshot.data.documents.elementAt(index)['displayName'] != null
                                          ? Text(
                                              snapshot.data.documents.elementAt(index)['displayName'],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(height: 10.0),
                                      //       _buildBio(context),
                                      snapshot.data.documents.elementAt(index)['description'] != null
                                          ? Container(
                                              width: 270,
                                              //color: Colors.white,
                                              child: Text(
                                                snapshot.data.documents.elementAt(index)['description'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  //try changing weight to w500 if not thin

                                                  color: Colors.grey[600],
                                                  fontSize: 13.0,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(height: 8.0),
                                      Container(
                                        //color: Colors.grey[500],
                                        color: Colors.indigo[300],
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                                              child: Text(
                                                _listings,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w400,
                                                  //fontWeight: Fo
                                                  //fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // _buildPropertyList(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            margin: EdgeInsets.only(
                                              top: 20,
                                            ),
                                            height: 180,
                                            child: StreamBuilder(
                                                stream: Firestore.instance.collection("PostAdd").where("uid", isEqualTo: snapshot.data.documents[index].documentID).snapshots(),
                                                builder: (BuildContext context, snapshot1) {
                                                  if (snapshot1.hasData) {
                                                    return ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      shrinkWrap: true,
                                                      itemCount: snapshot1.data.documents.length,
                                                      // ignore: missing_return
                                                      itemBuilder: (BuildContext context, int index) {
                                                        return Container(
                                                          margin: EdgeInsets.only(right: 5),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              adPost.postId = snapshot1.data.documents[index].documentID.toString();
                                                              adPost.userId = snapshot1.data.documents[index].data['uid'].toString();
                                                              adPost.price = snapshot1.data.documents[index].data['Price'];
                                                              Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(adPost));
                                                            },
                                                            child: Container(
                                                              width: 160.0,
                                                              //height: 220,
                                                              child: Card(
                                                                child: Wrap(
                                                                  children: <Widget>[
                                                                    snapshot1.data.documents[index].data['ImageUrls'][0] != null
                                                                        ? Container(
                                                                            height: 120,
                                                                            width: double.infinity,
                                                                            child: Image.network(
                                                                              snapshot1.data.documents[index].data['ImageUrls'][0],
                                                                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                                                if (loadingProgress == null) return child;
                                                                                return Center(
                                                                                  child: CircularProgressIndicator(
                                                                                    value: loadingProgress.expectedTotalBytes != null
                                                                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                                                        : null,
                                                                                  ),
                                                                                );
                                                                              },
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    Container(
                                                                      color: Colors.indigo[100],
                                                                      child: ListTile(
                                                                        title: Container(
                                                                          margin: EdgeInsets.only(bottom: 12),
                                                                          child: snapshot1.data.documents[index].data['Title'].toString() != null
                                                                              ? Text(
                                                                                  snapshot1.data.documents[index].data['Title'].toString().toUpperCase(),
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Poppins',
                                                                                    color: Colors.black,
                                                                                    fontSize: 13.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  //style: TextStyle(fontStyle: F),
                                                                                )
                                                                              : Container(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    return CircularProgressIndicator();
                                                  }
                                                } //builder

                                                )),
                                      ),
                                      // ads stream builder ends here
                                      //   _showReviewForm(),

                                      Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              //color: Colors.grey[500],
                                              color: Colors.indigo[300],
                                              width: MediaQuery.of(context).size.width,
                                              height: 34,
                                              child: Center(
                                                child: Text(
                                                  'Personal Information',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      //    _showPersonalInformation(context),
                                      SizedBox(
                                        height: 17,
                                      ),
                                      Container(
                                          padding: EdgeInsets.all(20),
                                          child: Card(
                                            color: Colors.white,
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      snapshot.data.documents.elementAt(index)['displayName'] != null
                                                          ? ListTile(
                                                              leading: Icon(
                                                                Icons.email,
                                                                color: Color(0xff00AFFF),
                                                              ),
                                                              title: Text(
                                                                "Name",
                                                                style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Poppins", fontWeight: FontWeight.w400),
                                                              ),
                                                              subtitle: Container(
                                                                margin: EdgeInsets.only(top: 7),
                                                                child: Text(userName = snapshot.data.documents.elementAt(index)['displayName'], style: TextStyle(fontSize: 15, color: Colors.black54)),
                                                              ),
                                                            )
                                                          : Container(),
                                                      Divider(),
                                                      snapshot.data.documents.elementAt(index)['age'] == null
                                                          ? Container()
                                                          : Column(
                                                              children: [
                                                                ListTile(
                                                                  leading: Icon(
                                                                    Icons.person,
                                                                    color: Color(0xff00AFFF),
                                                                  ),
                                                                  title: Text("Age", style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Poppins", fontWeight: FontWeight.w400)),
                                                                  subtitle: Container(
                                                                    margin: EdgeInsets.only(top: 7),
                                                                    child: Text(snapshot.data.documents.elementAt(index)['age'], style: TextStyle(fontSize: 15, color: Colors.black54)),
                                                                  ),
                                                                ),
                                                                Divider(),
                                                              ],
                                                            ),
                                                      snapshot.data.documents.elementAt(index)['phoneNumber'] != null
                                                          ? ListTile(
                                                              leading: Icon(
                                                                Icons.phone,
                                                                color: Color(0xff00AFFF),
                                                              ),
                                                              title: Text("Phone Number", style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Poppins", fontWeight: FontWeight.w400)),
                                                              subtitle: Container(
                                                                margin: EdgeInsets.only(top: 7),
                                                                child: Text(snapshot.data.documents.elementAt(index)['phoneNumber'], style: TextStyle(fontSize: 15, color: Colors.black54)),
                                                              ),
                                                            )
                                                          : Container(),
                                                      Divider(),
                                                      snapshot.data.documents.elementAt(index)['city'] == null
                                                          ? Container()
                                                          : Column(
                                                              children: [
                                                                ListTile(
                                                                  leading: Icon(
                                                                    Icons.person,
                                                                    color: Color(0xff00AFFF),
                                                                  ),
                                                                  title: Text("City", style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Poppins", fontWeight: FontWeight.w400)),
                                                                  subtitle: Container(
                                                                    margin: EdgeInsets.only(top: 7),
                                                                    child: Text(snapshot.data.documents.elementAt(index)['city'],
                                                                        style: TextStyle(fontSize: 15, color: Colors.black54, fontFamily: "Poppins", fontWeight: FontWeight.w400)),
                                                                  ),
                                                                ),
                                                                Divider(),
                                                              ],
                                                            ),
                                                      snapshot.data.documents.elementAt(index)['address'] != null
                                                          ? ListTile(
                                                              leading: Icon(
                                                                Icons.person,
                                                                color: Color(0xff00AFFF),
                                                              ),
                                                              title: Text("Address", style: TextStyle(fontSize: 18, color: Colors.black)),
                                                              subtitle: Container(
                                                                margin: EdgeInsets.only(top: 7),
                                                                child: Text(snapshot.data.documents.elementAt(index)['address'], style: TextStyle(fontSize: 15, color: Colors.black54)),
                                                              ),
                                                            )
                                                          : Container(),
                                                      /* snapshot.data.documents.elementAt(index)['rating'] != null */
                                                      ListTile(
                                                        leading: Icon(
                                                          Icons.rate_review,
                                                          color: Color(0xff00AFFF),
                                                        ),
                                                        title: Text(
                                                          "Rating",
                                                          style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: "Poppins", fontWeight: FontWeight.w400),
                                                        ),
                                                        subtitle: Container(
                                                          margin: EdgeInsets.only(top: 7),
                                                          child: StreamBuilder(
                                                              stream: Firestore.instance.collection("Rating").where("agentId", isEqualTo: data).snapshots(),
                                                              builder: (BuildContext context, snapshot1) {
                                                                print(data.toString() + " it is agent id");
                                                                if (snapshot1.hasData && snapshot1.data != null) {
                                                                  allRatingSum = 0.0;
                                                                  stars = "";
                                                                  averageOfRating = 0;
                                                                  Two =snapshot1.data.documents.length.toString();
                                                                  if (snapshot1.data.documents.length > 0) {
                                                                    for (int i = 0; i < snapshot1.data.documents.length; i++) {
                                                                      allRatingSum += snapshot1.data.documents[i]['rate'].length;
                                                                      print(snapshot1.data.documents[i]['rate'].length.toString());
                                                                    }
                                                                    averageOfRating = (allRatingSum / snapshot1.data.documents.length).round();
                                                                    print("avergae + $averageOfRating");
                                                                    for (int j = 0; j < averageOfRating; j++) {
                                                                      stars += "⭐";
                                                                    }
                                                                    return Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(stars, style: TextStyle(fontSize: 18, color: Colors.black54)),
                                                                        Padding(
                                                                          padding: const EdgeInsets.all(4.0),
                                                                          child: Text
                                                                            ('/$Two', style: TextStyle(fontSize: 13, color: Colors.black54,fontFamily: "Poppins",fontWeight: FontWeight.w400 )),
                                                                        ),
//
                                                                      ],
                                                                    );
                                                                  } else {
                                                                    return Text('Yet to be rated');
                                                                  }
                                                                } else {
                                                                  return Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(stars, style: TextStyle(fontSize: 18, color: Colors.black54)),

//
                                                                    ],
                                                                  );
                                                                }
                                                              }),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                      snapshot.data.documents[index].documentID != user.uid
                                          ? Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                FlatButton(
                                                  onPressed: () {
                                                    double lat = snapshot.data.documents.elementAt(index)['Location'].latitude;
                                                    double long = snapshot.data.documents.elementAt(index)['Location'].longitude;
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => LocateAgent(lat: lat, long: long)),
                                                    );
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
                                                        "Locate Agent",
                                                        style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(right: 16),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      print(data.toString());
                                                      sendMessage(data, userName);
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
                                              ],
                                            )
                                          : SizedBox(),
                                      Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              //                    color: Colors.blue,
                                              color: Colors.indigo[300],
                                              width: MediaQuery.of(context).size.width,
                                              height: 34,
                                              child: Center(
                                                child: Text(
                                                  'User Reviews',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          //crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Click Icon for Reviews',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () => showComments(context, userId: user.uid, AgentId: snapshot.data.documents.elementAt(index)['uid']),
                                              child: Icon(
                                                Icons.chat,
                                                size: 28.0,
                                                color: Colors.blue[900],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      //   _editProfileButton(),

                                      /*user.uid ==
                                              snapshot.data.documents
                                                  .elementAt(index)['uid']
                                          ? Container(
                                              child: Center(
                                                child: FlatButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        '/AgentSignup');
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.grey[800],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10)),
                                                    child: Center(
                                                      child: Text(
                                                        "Edit Profile",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),*/
                                      SizedBox(height: 8.0),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
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
              : Center(child: Text("Error"))),
    );
  }

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

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget _showContact(BuildContext context) {
    return Container();
  }
}

showComments(BuildContext context, {String userId, String AgentId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      userId: userId,
      AgentId: AgentId,
      //   image: mediaUrl,
    );
  }));
}
