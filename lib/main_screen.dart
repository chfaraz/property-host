import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/GetUserDetail.dart';
import 'package:signup/helper/helperfunctions.dart';
import 'package:signup/root/root.dart';
import 'package:signup/search_result.dart';
import 'package:signup/states/currentUser.dart';
import 'package:flutter/services.dart';
import 'package:signup/userProfile.dart';

class MainScreen extends StatefulWidget {
  final bool isAgent;
  // final FirebaseUser user;
  const MainScreen({Key key, this.isAgent}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState(this.isAgent);
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool isPressed = false;
  bool userLoggedIn = false;

  Future<String> currentUser() async {
    user = await _auth.currentUser();
    return user != null ? user.uid : null;
  }

/*  @override
  void deactivate() {
    // TODO: implement deactivate
    print("deactivate");
    super.deactivate();
  }*/

  /*
    Dispose is called when the State object is removed, which is permanent.
    This method is where you should unsubscribe and cancel all animations, streams, etc.
    */
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("app is resumed back");
    }
  }

  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initUser();
  }

  String userid;

  initUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      userid = user.uid;
      print("${widget.isAgent} + ${userid}");
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    setState(() {});
  }

  bool isAgent = true;
  bool _validate = false;
  GlobalKey<FormState> _key = new GlobalKey();
  TextEditingController txtSearch = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //final authData = snapshot.data;
  _MainScreenState(this.isAgent);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    return user != null
        ? StreamBuilder(
            stream: Firestore.instance.collection('users').where("uid", isEqualTo: userid).snapshots(),

            // ignore: missing_return
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasError && snapshot.data != null) {
                //   debugPrint(snapshot.data.documents[0].data['displayName'].toString());
                if (snapshot.data.documents[0].data['displayName'] != null) {
                  return SafeArea(
                    child: Scaffold(
                      resizeToAvoidBottomInset: false, // this is new
                      resizeToAvoidBottomPadding: false, //
                      //backgroundColor: Colors.grey,
                      backgroundColor: Color(0xffDBDBDB),
                      //backgroundColor:  Color(0xff2196F3),

                      appBar: AppBar(
                        //   backgroundColor:  Color(0xff2196F3),
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
                        title: Text('Property Host'),

                        centerTitle: true,
//                  actions: <Widget>[
//                      Expanded(
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceAround,
//                        children: <Widget>[
//                          //Image.asset('assets/index.jpg', fit: BoxFit.cover,height:16,width:16),
//                          Container(
//                              margin: new EdgeInsets.only(left: 50),
//                              child: Text(
//                                'Property Host',
//                                style: TextStyle(
//                                    fontWeight: FontWeight.bold, fontSize: 19),
//                              )),
//
//                         user != null ? StreamBuilder(
//                              stream: Firestore.instance.collection('users')
//                                  .where("uid", isEqualTo: userid)
//                                  .snapshots(),
//
//                              // ignore: missing_return
//                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                                if (snapshot.connectionState == ConnectionState.active) {
//                                  return Expanded(
//                                    child: ListView.builder(
//                                        itemCount: snapshot.data.documents.length,
//                                        // ignore: missing_return
//                                        itemBuilder: (BuildContext context, int index) {
//                                          // String Data = snapshot.data.documents.elementAt(
//                                          //index)['displayName'];
//                                          // String Result = Data.substring(0, Data.lastIndexOf(" "));
//                                          //var text = Data.substring(Result, Data.lastIndexOf('') - Result);
//                                          //String ret = Result[0] +""+ Result[1];
//                                          //print("Error");
//                                          return user !=null
//                                              ? Container(
//                                            margin: EdgeInsets.only(
//                                                top: 19, left: 80),
//                                            child: Text(
//                                              snapshot.data.documents.elementAt(
//                                                  index)['displayName'],
//                                              style: TextStyle(
//                                                  fontWeight: FontWeight.bold,
//                                                  color: Colors.black,
//                                                  fontStyle: FontStyle.italic),
//                                            ),
//                                          )
//                                              : IconButton(
//                                            icon: Icon(Icons.person),
//                                            // ignore: missing_return
//                                            onPressed: () {
//                                              //Navigator.pushNamed(context, '/LoginScreen');
//                                              //   Navigator.pushNamed(context, '/PhoneVerification');
//                                              Navigator.pushNamed(
//                                                  context, '/Signup');
//                                            },
//                                          );
//                                        }
//                                    ),
//                                  );
//                                }
//                                else if (snapshot.connectionState ==
//                                    ConnectionState.waiting) {
//                                  return Container(child: Center(
//                                      child: CircularProgressIndicator()));
//                                  //return CircularProgressIndicator();
//                                  //final userDocument = snapshot.data;
//                                  //final title=  snapshot.data.userocument['displayName']);
//                                  //CircularProgressIndicator();
//
//                                }
//                              }): IconButton(
//                            icon: Icon(Icons.person),
//                            // ignore: missing_return
//                            onPressed: () {
//                              //Navigator.pushNamed(context, '/PhoneVerification');
//                              Navigator.pushNamed(context, '/Signup');
//                            },
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
                        //     backgroundColor: Colors.teal[600],
                        elevation: 0.0,
                      ),

                      drawer: Theme(
                        data: Theme.of(context).copyWith(
                            //        canvasColor: Colors.blueGrey,
                            ),
                        child: user != null
                            ? Drawer(
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: <Widget>[
                                    Container(
                                      height: 120.0,
                                      //width: 500,
                                      child: StreamBuilder(
                                          stream: Firestore.instance.collection('users').where("uid", isEqualTo: userid).snapshots(),

                                          // ignore: missing_return
                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                      return DrawerHeader(
//                          margin: EdgeInsets.zero,
//                          padding: EdgeInsets.zero,
//                       //   decoration: BoxDecoration(
////                          image: DecorationImage(
////                              fit: BoxFit.fill,
////                              image: AssetImage('assets/index.jpg'))),
//                          child: Stack(children: <Widget>[
//                            ClipRRect(
//                              borderRadius: BorderRadius.circular(85),
//                              child: Image.network("https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg"),
//                            ),
//
//                            Positioned(
//                                bottom: 1.0,
//                                left: 110.0,
//                                //top:10,
//                                child: Text("Menu",
//                                    style: TextStyle(
//                                        color: Colors.black,
//                                        fontSize: 30.0,
//                                        //fontFamily: "Roboto",
//                                        fontWeight: FontWeight.w400))),
//                          ]));
                                            {
                                              if (snapshot.connectionState == ConnectionState.active) {
                                                return ListView.builder(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: snapshot.data.documents.length,
                                                    // ignore: missing_return
                                                    itemBuilder: (BuildContext context, int index) {
//                String Data = snapshot.data.documents.elementAt(
//                    index)['displayName'];
//                String Result = Data.substring(0, Data.lastIndexOf(" "));
                                                      //var text = Data.substring(Result, Data.lastIndexOf('') - Result);
                                                      //String ret = Result[0] +""+ Result[1];
                                                      print(user.uid);
                                                      return user != null
                                                          ? DrawerHeader(
                                                              margin: EdgeInsets.zero,
                                                              padding: EdgeInsets.zero,
                                                              //   decoration: BoxDecoration(
//                          image: DecorationImage(
//                              fit: BoxFit.fill,
//                              image: AssetImage('assets/index.jpg'))),
                                                              child: Stack(children: <Widget>[
//                          Card(
//                            //height: 250,
//                            color: Colors.deepOrangeAccent,
//                          ),
                                                                Row(
                                                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    snapshot.data.documents.elementAt(index)['image'] == null
                                                                        ? Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Container(
                                                                              width: 100,
                                                                              height: 90,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(100),
                                                                                border: Border.all(
                                                                                  color: Colors.white,
                                                                                  width: 6.0,
                                                                                ),
                                                                              ),
                                                                              child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(80),
                                                                                  child: Image.network("https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg",
                                                                                      width: 80, height: 80, fit: BoxFit.fill)),
                                                                            ),
                                                                          )
                                                                        : Padding(
                                                                            padding: const EdgeInsets.all(8.0),
                                                                            child: Container(
                                                                              width: 100,
                                                                              height: 90,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(100),
                                                                                border: Border.all(
                                                                                  color: Colors.white,
                                                                                  width: 6.0,
                                                                                ),
                                                                              ),
                                                                              child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(80),
                                                                                  child: Image.network(snapshot.data.documents.elementAt(index)['image'],
                                                                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                                                    if (loadingProgress == null) return child;
                                                                                    return Center(
                                                                                      child: CircularProgressIndicator(
                                                                                        value: loadingProgress.expectedTotalBytes != null
                                                                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                                                            : null,
                                                                                      ),
                                                                                    );
                                                                                  }, width: 80, height: 80, fit: BoxFit.fill)),
                                                                            ),
                                                                          ),
                                                                    Row(
//crossAxisAlignment: CrossAxisAlignment.end,
                                                                      children: [
                                                                        Container(
                                                                          margin: EdgeInsets.only(bottom: 50, left: 30),
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            //crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Welcome !",
                                                                                style: TextStyle(color: Colors.black38),
                                                                              ),
                                                                              Text(
                                                                                snapshot.data.documents.elementAt(index)['displayName'],
                                                                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                //CircleAvatar(

                                                                //borderRadius: BorderRadius.circular(85),
                                                                //height:200,
//                               decoration: BoxDecoration(
//                          image: DecorationImage(
//                              fit: BoxFit.fill,
//                              image: NetworkImage("https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg",)),),
//                            //child: Image.network("https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg"),
                                                                //),
//                          Positioned(
//                              bottom: 1.0,
//                              left: 10.0,
//                              //top:10,
//                              child: Text(Result,
//                                  style: TextStyle(
//                                      color: Colors.black,
//                                      fontSize: 30.0,
//                                      //fontFamily: "Roboto",
//                                      fontWeight: FontWeight.w400))),
                                                              ]))
                                                          : IconButton(
                                                              icon: Icon(Icons.person),
                                                              // ignore: missing_return
                                                              onPressed: () {
                                                                Navigator.pushNamed(context, '/Signup');
                                                              },
                                                            );
                                                    });
                                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(child: Center(child: CircularProgressIndicator()));
                                                //return CircularProgressIndicator();
                                                //final userDocument = snapshot.data;
                                                //final title=  snapshot.data.userocument['displayName']);
                                                //CircularProgressIndicator();

                                              }
                                            }
                                          }),
                                    ),

                                    Container(
                                      //margin:EdgeInsets.only(top:35),
                                      height: 50,
                                      //color: Colors.white.withAlpha(128),
                                      // color: Colors.grey[800],
                                      child: ListTile(
                                        title: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.add_box,
                                              color: Color(0xff2470c7),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text("Post an Ad"),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/postscreen1');
                                        },
                                      ),
                                    ),
                                    //SizedBox(height: 1.0),
                                    // ignore: unrelated_type_equality_checks
                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Container(
                                      height: 50,
                                      // color: Colors.grey[800],
                                      child: ListTile(
                                        title: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.people_outline,
                                              color: Color(0xff2470c7),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text("Agents List"),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/MyProfile');
                                        },
                                      ),
                                    ),

                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Container(
                                      height: 50,
                                      //color: Colors.grey[800],
                                      child: ListTile(
                                        title: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.library_books,
                                              color: Color(0xff2470c7),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text("Your Ads"),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/ViewAdds');
                                        },
                                      ),
                                    ),
                                    //SizedBox(height: 1.0),
                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Container(
                                      height: 50,
                                      //color: Colors.grey[800],
                                      child: ListTile(
                                        title: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.person,
                                              color: Color(0xff2470c7),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text("My Profile"),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          //  Navigator.pushNamed(context, '/UserProfile');
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(isAgent: widget.isAgent)));
                                        },
                                      ),
                                    ),
                                    //    : Container(),
                                    //SizedBox(height: 1.0),
                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          //color: Colors.grey[800],
                                          child: ListTile(
                                            title: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.chat_bubble,
                                                  color: Color(0xff2470c7),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 8.0),
                                                  child: Text("Chat"),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.pushNamed(context, '/ChatRoom');
                                            },
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.5,
                                          color: Colors.lightBlueAccent,
                                        ),
                                      ],
                                    ),

//
                                    Container(
                                      height: 50,
                                      //color: Colors.grey[800],
                                      child: ListTile(
                                        title: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.ac_unit,
                                              color: Color(0xff2470c7),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text("View Offers"),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(context, '/ViewOffers');
                                          //Navigator.pushNamed(context, '/navigation');
                                        },
                                      ),
                                    ),
                                    //SizedBox(height: 1.0),
                                    Divider(
                                      thickness: 0.5,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    isAgent
                                        ? Container()
                                        : Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                //color: Colors.grey[800],
                                                child: ListTile(
                                                  title: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.check_circle_outline,
                                                        color: Color(0xff2470c7),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 8.0),
                                                        child: Text("Apply for Agent"),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.pushNamed(context, '/AgentSignup');
                                                  },
                                                ),
                                              ),
                                              Divider(
                                                thickness: 0.5,
                                                color: Colors.lightBlueAccent,
                                              ),
                                            ],
                                          ),
                                    //SizedBox(height: 1.0),

                                    user != null
                                        ? Container(
                                            height: 50,
                                            //color: Colors.grey[800],
                                            child: ListTile(
                                                title: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.person_pin,
                                                      color: Color(0xff2470c7),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 8.0),
                                                      child: Text("Sign Out"),
                                                    ),
                                                  ],
                                                ),
                                                onTap: ()
                                                    //      Navigator.pop(context);
                                                    async {
                                                  //signOut();
                                                  // Navigator.pushNamed(context, '/LoginScreen');

                                                  String _returnString = await _currentUser.signOut();
                                                  if (_returnString == 'Success') {
                                                    Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => OurRoot()),
                                                      (route) => false,
                                                    );
                                                  }
                                                }),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      body: SingleChildScrollView(
                        reverse: true,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      height: MediaQuery.of(context).size.height / 1.4,
                                      width: 370,
                                      decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(12),
                                        //boxShadow: BoxShadow(2),
                                        image: DecorationImage(
                                          image: AssetImage('assets/front1.jpeg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Container(
                                        //margin: EdgeInsets.only(top: 20,left: 13),
                                        child: Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Column(
                                            children: <Widget>[
//                        Text(
//                          'Find Your Dream Home With Property Host',
//                          textAlign: TextAlign.center,
//                          style: TextStyle(
//                            color: Colors.grey[350],
//                            fontWeight: FontWeight.w900,
//                            fontSize: 30.0,
//                          ),
//                        ),
                                              SizedBox(height: 80.0),
                                              Container(
                                                  margin: EdgeInsets.only(top: 180),
                                                  child: Form(
                                                    key: _key,
                                                    autovalidate: _validate,
                                                    child: TextFormField(
                                                      controller: txtSearch,
                                                      validator: ValidateSearch,
                                                      style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14.0,
                                                        letterSpacing: 2.0,
                                                      ),
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.grey[700], width: 3.0),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.grey[500], width: 3.0),
                                                        ),
                                                        hintText: 'Enter the Location: ',
                                                        hintStyle: TextStyle(color: Colors.black),
                                                      ),
                                                    ),
                                                  )),
                                              Container(
                                                margin: EdgeInsets.only(top: 30),
                                                child: RaisedButton.icon(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(9.0),
//                                                side: BorderSide(
//                                                    color: Colors.pink[500],
//                                                    width: 1.5
                                                    //      )
                                                  ),
                                                  onPressed: () {
                                                    if (_key.currentState.validate()) {
                                                      _key.currentState.save();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => SearcResult(
                                                                    location: txtSearch.text,
                                                                  )));
                                                    } else {
                                                      setState(() {
                                                        _validate = true;
                                                      });
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.search,
                                                    color: Colors.black,
                                                    size: 12.0,
                                                  ),
                                                  label: Text(
                                                    'Search',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w800,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return UserDetail(
                    mobileNumber: snapshot.data.documents[0].data['phoneNumber'].toString(),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
            })
        : Center(
            child: Text("loading..."),
          );
  }
}
