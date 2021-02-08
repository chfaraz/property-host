import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signup/screens/editProfile.dart';

class UserProfile extends StatefulWidget {
  final bool isAgent;

  const UserProfile({Key key, this.isAgent}) : super(key: key);
  //final String data;
  //static const routeName = '/UserProfile';
  //const MyProfileFinal({Key key, this.data}) : super(key: key);
  @override
  _UserProfileState createState() => _UserProfileState(this.isAgent);
}

class _UserProfileState extends State<UserProfile> {
  //final String _fullName = "Ali Qureshi";
  //final String data;
  //final String _status = "Property Dealer";

  final String _listings = "Listings";
  String Two;
  //final String _bio ="\"Hi, I am a Property Dealer.If you need property suitbale for your needs. You can contact me.\"";

  int _rating = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isAgent = true;

  _UserProfileState(this.isAgent);

  //_MyProfileStateFinal(this.data);
  double allRatingSum = 0.0;
  String stars = "0";
  String userName;
  int averageOfRating = 0;


  //bool isAdmin = false;
  Future<String> currentUser() async {
    user = await _auth.currentUser();
    return user != null ? user.uid : null;
  }

  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    initUser();
  }

  String userid;

  initUser() async {
    user = await _auth.currentUser();
    if (user != null) {
      userid = user.uid;
      print(widget.isAgent);
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    setState(() {});
  }

  void rate(int rating) {
    //Other actions based on rating such as api calls.
    setState(() {
      _rating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _showContact(context));

    // Size screenSize = MediaQuery.of(context.size;
    //final data = ModalRoute.of(context).settings.arguments as String;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('My Profile'),
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
            centerTitle: true,
            actions: <Widget>[

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      //Image.asset('assets/index.jpg', fit: BoxFit.cover,height:16,width:16),
                      Container(
                          margin: new EdgeInsets.only(left: 130),
                          child: Text(
                            'My Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          )),

                      user != null
                          ? StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .where("uid", isEqualTo: userid)
                              .snapshots(),

                          // ignore: missing_return
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.active) {
                              return Expanded(
                                child: ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    // ignore: missing_return
                                    itemBuilder: (BuildContext context, int index) {
                                      // String Data = snapshot.data.documents.elementAt(
                                      //index)['displayName'];
                                      // String Result = Data.substring(0, Data.lastIndexOf(" "));
                                      //var text = Data.substring(Result, Data.lastIndexOf('') - Result);
                                      //String ret = Result[0] +""+ Result[1];
                                      //print("Error");

                                      return   snapshot
                                          .data.documents
                                          .elementAt(index)['UserType'] =='Agent' ? Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: Padding(
                                          padding: const EdgeInsets.only
                                            (left: 8,top: 5),
                                          child: IconButton(icon: Icon(Icons.notifications),
                                          onPressed: () {
                                                 Navigator.pushNamed(context, "/activityFeed");
                                                      },
                                                ),
                                        ),
                                      ):SizedBox();

                                    }
                                ),
                              );
                            }
                            else if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(child: Center(child: CircularProgressIndicator()));
                              //return CircularProgressIndicator();
                              //final userDocument = snapshot.data;
                              //final title=  snapshot.data.userocument['displayName']);
                              //CircularProgressIndicator();

                            }
                          })
                          : Container(),
                    ],
                  ),
                ),

//               IconButton(
//                icon: Icon(Icons.notifications),
//                onPressed: () {
//                  Navigator.pushNamed(context, "/activityFeed");
//                },
//              )
            ],
            backgroundColor: Colors.grey[800],
            elevation: 0.0,
          ),
          body: user !=null ? Container(
            child: StreamBuilder(
              stream: Firestore.instance.collection('users').where("uid", isEqualTo:user.uid).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: <Widget>[
                          Ink(
                            color: Color(0xff2D3040),
                            height: 140,
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                //              _buildProfileImage(),
                                SizedBox(height: 75.0),
                                //              _buildProfileImage(),
                                snapshot
                                    .data.documents
                                    .elementAt(index)['image'] !=null ?Center(
                                  child: Container(
                                    width: 120.0,
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(snapshot
                                            .data.documents
                                            .elementAt(index)['image']),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius:
                                        BorderRadius.circular(50.0),
                                    border: Border.all(
                                      color: Color(0xffE1E1E1),
                                      width: 5.0,
                                    ),
                                    ),
                                  ),
                                ):Container(

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
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fill)),
                                ),
                                //_buildFullName(),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Text(
                                    snapshot.data.documents
                                        .elementAt(index)['displayName'],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  ),
                                ),
                                //    _buildStatus(context),
//                                Container(
//                                  padding: EdgeInsets.symmetric(
//                                      vertical: 4.0, horizontal: 6.0),
//                                  decoration: BoxDecoration(
//                                    color: Theme
//                                        .of(context)
//                                        .scaffoldBackgroundColor,
//                                    borderRadius: BorderRadius.circular(4.0),
//                                  ),
//                                  child: Text(
//                                    snapshot.data.documents.elementAt(index)['title'],
//                                    style: TextStyle(
//                                      fontFamily: 'Spectral',
//                                      color: Colors.black,
//                                      fontSize: 20.0,
//                                      fontWeight: FontWeight.w300,
//                                    ),
//                                  ),
//                                ),

                                //       _buildBio(context),


//                                  //       _buildpropertyStatus(context),
//                                  Container(
//                                    //color: Colors.grey[500],
//                                    color: Colors.teal[700],
//                                    child: Row(
//                                      mainAxisAlignment:
//                                      MainAxisAlignment.center,
//                                      children: <Widget>[
//                                        Container(
//                                          padding: EdgeInsets.symmetric(
//                                              vertical: 4.0,
//                                              horizontal: 6.0),
//                                          child: Text(
//                                            _listings,
//                                            style: TextStyle(
//                                              fontFamily: 'Spectral',
//                                              color: Colors.white,
//                                              fontSize: 18.0,
//                                              fontWeight: FontWeight.bold,
//                                            ),
//                                          ),
//                                        ),
//                                      ],
//                                    ),
//                                  ),
//                                  // _buildPropertyList(),
////                                  Container(
////                                    margin: EdgeInsets.only(top: 15),
////                                    height: 200,
////                                    child: ListView(
////                                      scrollDirection: Axis.horizontal,
////                                      children: <Widget>[
////                                        GestureDetector(
////                                          onTap: () {
////                                            Navigator.pushNamed(
////                                                context, '/AdDetail');
////                                          },
////                                          child: Container(
////                                            width: 160.0,
////                                            child: Card(
////                                              child: Wrap(
////                                                children: <Widget>[
////                                                  Container(
////                                                    height: 140,
////                                                    width: double.infinity,
////                                                    child: Image.asset(
////                                                      'assets/index.jpg',
////
////                                                      fit: BoxFit.cover,
////                                                    ),
////                                                  ),
////                                                  Container(
////                                                    color: Colors.grey,
////                                                    child: ListTile(
////                                                      title: Text(
////                                                        'heading',
////                                                        style: TextStyle(
////                                                            fontSize: 16,
////                                                            color: Colors
////                                                                .black),
////                                                      ),
//////                                                      subtitle: Text(
//////                                                        'subHeading',
//////                                                        style: TextStyle(
//////                                                            fontSize: 14, color: Colors.white),
//////                                                      ),
////                                                    ),
////                                                  ),
////                                                ],
////                                              ),
////                                            ),
////                                          ),
////                                        ),
////                                        GestureDetector(
////                                          onTap: () {
////                                            Navigator.pushNamed(
////                                                context, '/AdDetail');
////                                          },
////                                          child: Container(
////                                            width: 160.0,
////                                            child: Card(
////                                              child: Wrap(
////                                                children: <Widget>[
////                                                  Container(
////                                                    height: 140,
////                                                    width: double.infinity,
////                                                    child: Image.asset(
////                                                      'assets/index.jpg',
////
////                                                      fit: BoxFit.cover,
////                                                    ),
////                                                  ),
////                                                  Container(
////                                                    color: Colors.grey,
////                                                    child: ListTile(
////                                                      title: Text(
////                                                        'heading',
////                                                        style: TextStyle(
////                                                            fontSize: 16,
////                                                            color: Colors
////                                                                .black),
////                                                      ),
//////                                                      subtitle: Text(
//////                                                        'subHeading',
//////                                                        style: TextStyle(
//////                                                            fontSize: 14, color: Colors.white),
//////                                                      ),
////                                                    ),
////                                                  ),
////                                                ],
////                                              ),
////                                            ),
////                                          ),
////                                        ),       GestureDetector(
////                                          onTap: () {
////                                            Navigator.pushNamed(
////                                                context, '/AdDetail');
////                                          },
////                                          child: Container(
////                                            width: 160.0,
////                                            child: Card(
////                                              child: Wrap(
////                                                children: <Widget>[
////                                                  Container(
////                                                    height: 140,
////                                                    width: double.infinity,
////                                                    child: Image.asset(
////                                                      'assets/index.jpg',
////
////                                                      fit: BoxFit.cover,
////                                                    ),
////                                                  ),
////                                                  Container(
////                                                    color: Colors.grey,
////                                                    child: ListTile(
////                                                      title: Text(
////                                                        'heading',
////                                                        style: TextStyle(
////                                                            fontSize: 16,
////                                                            color: Colors
////                                                                .black),
////                                                      ),
//////                                                      subtitle: Text(
//////                                                        'subHeading',
//////                                                        style: TextStyle(
//////                                                            fontSize: 14, color: Colors.white),
//////                                                      ),
////                                                    ),
////                                                  ),
////                                                ],
////                                              ),
////                                            ),
////                                          ),
////                                        ),
////                                      ],
////                                    ),
////                                  ),
//                                  //   _showReviewForm(),
////                                Container(
////                                  margin: EdgeInsets.only(top: 30),
////                                  child: Row(
////                                    mainAxisAlignment: MainAxisAlignment.center,
////                                    children: <Widget>[
////                                      Container(
////                                        color: Colors.grey[500],
////                                        width: MediaQuery
////                                            .of(context)
////                                            .size
////                                            .width,
////                                        height: 25,
////                                        child: Center(
////                                          child: Text(
////                                            'User Reviews',
////                                            style: TextStyle(
////                                                fontSize: 18,
////                                                fontWeight: FontWeight.bold,
////                                                color: Colors.black),
////                                          ),
////                                        ),
////                                      )
////                                    ],
////                                  ),
////                                ),
//                                  //  _showInformationForm(),
////                                GestureDetector(
////                                  onTap: () => showComments(
////                                    context,
////                                    postId: snapshot.data.documents.elementAt(index)['uid'],
////                                    //ownerId: ownerId,
////                                    //     mediaUrl: snapshot.data.documents.elementAt(index)['image'],
////                                  ),
////                                  child: Icon(
////                                    Icons.chat,
////                                    size: 28.0,
////                                    color: Colors.blue[900],
////                                  ),
////                                ),
//
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        //color: Colors.grey[500],
                                        color: Colors.indigo[300],
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: 34,
                                        child: Center(
                                          child: Text(
                                            'Personal Information',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize:20.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 17,
                                ),
//                                  //    _showPersonalInformation(context),
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
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['displayName'] !=null?           ListTile(
                                                  leading: Icon(Icons.email, color: Color(0xff00AFFF),),
                                                  title: Text("Name",style: TextStyle(fontSize: 18,color: Colors.black,fontFamily: "Poppins",fontWeight: FontWeight.w400),),
                                                  subtitle: Container(
                                                    margin:EdgeInsets.only(top:7),
                                                    child: Text(snapshot.data.documents
                                                        .elementAt(
                                                        index)[
                                                    'displayName'],style: TextStyle(fontSize: 15,color: Colors.black54)),
                                                  ),
                                                ):Container(),
                                                Divider(),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['age'] !=null?ListTile(
                                                  leading: Icon(Icons.person, color: Color(0xff00AFFF),),
                                                  title: Text("Age",style: TextStyle(fontSize: 18,color: Colors.black,fontFamily: "Poppins",fontWeight: FontWeight.w400)),
                                                  subtitle: Container(
                                                    margin:EdgeInsets.only(top:7),
                                                    child: Text(
                                                        snapshot.data.documents
                                                            .elementAt(
                                                            index)['age'],style: TextStyle(fontSize: 15,color: Colors.black54)),
                                                  ),
                                                ):Container(),
                                                Divider(),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['phoneNumber'] !=null?ListTile(
                                                  leading: Icon(Icons.phone, color: Color(0xff00AFFF),),
                                                  title: Text("Phone Number",style: TextStyle(fontSize: 18,color: Colors.black,fontFamily: "Poppins",fontWeight: FontWeight.w400)),
                                                  subtitle: Container(
                                                    margin:EdgeInsets.only(top:7),
                                                    child: Text(snapshot.data.documents
                                                        .elementAt(
                                                        index)[
                                                    'phoneNumber'],style: TextStyle(fontSize: 15,color: Colors.black54)),
                                                  ),
                                                ):Container(),
                                                Divider(),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['city'] !=null?ListTile(
                                                  leading: Icon(Icons.person, color: Color(0xff00AFFF),),
                                                  title: Text("City",style: TextStyle(fontSize: 18,color: Colors.black,fontFamily: "Poppins",fontWeight: FontWeight.w400)),
                                                  subtitle: Container(
                                                    margin:EdgeInsets.only(top:7),
                                                    child: Text(
                                                        snapshot.data.documents
                                                            .elementAt(
                                                            index)['city'],style: TextStyle(fontSize: 15,color: Colors.black54,fontFamily: "Poppins",fontWeight: FontWeight.w400)),
                                                  ),
                                                ):Container(),
                                                Divider(),
                                                snapshot.data.documents
                                                    .elementAt(
                                                    index)['address'] !=null?ListTile(
                                                  leading: Icon(Icons.person, color: Color(0xff00AFFF),),
                                                  title: Text("Address",style: TextStyle(fontSize: 18,color: Colors.black)),
                                                  subtitle: Container(
                                                    margin:EdgeInsets.only(top:7),
                                                    child: Text(
                                                        snapshot.data.documents
                                                            .elementAt(
                                                            index)['address'],style: TextStyle(fontSize: 15,color: Colors.black54)),
                                                  ),
                                                ):Container(),
                                                isAgent? ListTile(
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
                                                        stream: Firestore
                                                            .instance
                                                            .collection
                                                          ("Rating").where
                                                          ("agentId",
                                                            isEqualTo: user
                                                                .uid)
                                                            .snapshots(),
                                                        builder: (BuildContext context, snapshot1) {
                                                          //print(data
                                                            //  .toString() +
                                                         // " it is agent id");
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
                                                ):Container(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                ),
                                //   _editProfileButton(),
//                                  snapshot.data.documents.elementAt(index)['User Type']=="Agent" ?
//                                  Container(
//                                    child: Center(
//                                      child: FlatButton(
//                                        onPressed: () {
//                                          print("Agent sign up called");
//                                          Navigator.pushNamed(context, '/AgentSignup');
//                                        },
//                                        child: Container(
//                                          height: 50,
//                                          width: 100,
//                                          decoration: BoxDecoration(
//                                              color: Colors.grey[800],
//                                              borderRadius: BorderRadius.circular(10)),
//                                          child: Center(
//                                            child: Text(
//                                              "Edit Profile",
//                                              style:
//                                              TextStyle(color: Colors.white,
//                                                  fontWeight: FontWeight.bold),
//                                            ),
//                                          ),
//                                        ),
//                                      ),
//                                    ),
//                                  )
//                                      :
                                Container(
                                    child: Center(
                                      child: FlatButton(
                                        onPressed: () {
                                          print("Edit profile called");
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(isAgent: widget.isAgent)));
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Color(0xff1E88E5),
                                              borderRadius: BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              "Edit Profile",

                                              style: TextStyle(fontFamily: "Poppins",fontWeight: FontWeight.w600,fontSize: 15,color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ),
//                                    :Container(
//                      margin: EdgeInsets.only(top: 60),
//                      child: Center(
//                      child: FlatButton(
//                      onPressed: () {
//                      Navigator.pushNamed(context, '/AgentSignup');
//                      },
//                      child: Container(
//                      height: 50,
//                      width: 180,
//                      decoration: BoxDecoration(
//                      color: Colors.grey[800],
//                      borderRadius: BorderRadius.circular(10)),
//                      child: Center(
//                      child: Text(
//                      "Complete Your Profile",
//                      style:
//                      TextStyle(color: Colors.white,
//                      fontWeight: FontWeight.bold),
//                      ),
//                      ),
//                      ),
//                      ),
//                      ),
//                      ),
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
          )   : Center(child: Text("Error"))),
    );

  }

//  Widget _buildCoverImage(Size screenSize) {
//    return Container(
//      color: Colors.black38,
//      height: screenSize.height / 7.5,
//    );
//  }
//
//  Widget _editProfileButton() {
//    return Container(
//      child: Center(
//        child: FlatButton(
//          onPressed: () {
//            Navigator.pushNamed(context, '/AgentSignup');
//          },
//          child: Container(
//            height: 50,
//            width: 100,
//            decoration: BoxDecoration(
//                color: Colors.grey[800],
//                borderRadius: BorderRadius.circular(10)),
//            child: Center(
//              child: Text(
//                "Edit Profile",
//                style:
//                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget _buildBio(BuildContext context) {
//    TextStyle bioTextStyle = TextStyle(
//      fontFamily: 'Spectral',
//      fontWeight: FontWeight.w400,
//      //try changing weight to w500 if not thin
//      fontStyle: FontStyle.italic,
//      color: Colors.black,
//      fontSize: 16.0,
//    );
//    return Container(
//      width: 270,
//      color: Colors.white,
//      child: Text(
//        _bio,
//        textAlign: TextAlign.center,
//        style: bioTextStyle,
//      ),
//    );
//  }
//
////  Widget _buildProfileImage() {
////    return Center(
////      child: Container(
////        width: 140.0,
////        height: 140.0,
////        decoration: BoxDecoration(
////          image: DecorationImage(
////            image: AssetImage('assets/1.jpg'),
////            fit: BoxFit.cover,
////          ),
////          borderRadius: BorderRadius.circular(70.0),
////          border: Border.all(
////            color: Colors.black26,
////            width: 6.0,
////          ),
////        ),
////      ),
////    );
////  }
//
////  Widget _buildFullName() {
////    TextStyle _nameTextStyle = TextStyle(
////      fontFamily: 'Roboto',
////      color: Colors.black,
////      fontSize: 28.0,
////      fontWeight: FontWeight.w700,
////    );
////
////    return Text(
////      _fullName,
////      style: _nameTextStyle,
////    );
////  }
//
////  Widget _buildStatus(BuildContext context) {
////    return Container(
////      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
////      decoration: BoxDecoration(
////        color: Theme.of(context).scaffoldBackgroundColor,
////        borderRadius: BorderRadius.circular(4.0),
////      ),
////      child: Text(
////        _status,
////        style: TextStyle(
////          fontFamily: 'Spectral',
////          color: Colors.black,
////          fontSize: 20.0,
////          fontWeight: FontWeight.w300,
////        ),
////      ),
////    );
////  }
//
//  Widget _buildpropertyStatus(BuildContext context) {
//    return Container(
//      color: Colors.grey[500],
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
//            child: Text(
//              _listings,
//              style: TextStyle(
//                fontFamily: 'Spectral',
//                color: Colors.black,
//                fontSize: 18.0,
//                fontWeight: FontWeight.bold,
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//  Widget _buildReviews(BuildContext context) {
//    return Container(
//      color: Colors.red,
//      child: Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            Row(
//              children: <Widget>[
//                Text(
//                  _status,
//                  style: TextStyle(
//                    fontFamily: 'Spectral',
//                    color: Colors.black,
//                    fontSize: 13.0,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ],
//            ),
//            Row(
//              children: <Widget>[],
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget _buildPropertyList() {
//    return Container(
//      margin: EdgeInsets.only(top: 15),
//      height: 200,
//      child: ListView(
//        scrollDirection: Axis.horizontal,
//        children: <Widget>[
//          GestureDetector(
//            onTap: () {
//              Navigator.pushNamed(context, '/AdDetail');
//            },
//            child: Container(
//              width: 160.0,
//              child: Card(
//                child: Wrap(
//                  children: <Widget>[
//                    Container(
//                      height: 120,
//                      child: Image.asset(
//                        'assets/1.jpg',
//                        fit: BoxFit.cover,
//                      ),
//                    ),
//                    Container(
//                      color: Colors.grey,
//                      child: ListTile(
//                        title: Text(
//                          'heading',
//                          style: TextStyle(fontSize: 16, color: Colors.black),
//                        ),
//                        subtitle: Text(
//                          'subHeading',
//                          style: TextStyle(fontSize: 14, color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
//          GestureDetector(
//            onTap: () {
//              Navigator.pushNamed(context, '/AdDetail');
//            },
//            child: Container(
//              width: 160.0,
//              child: Card(
//                child: Wrap(
//                  children: <Widget>[
//                    Container(
//                      height: 120,
//                      child: Image.asset(
//                        'assets/1.jpg',
//                        fit: BoxFit.cover,
//                      ),
//                    ),
//                    Container(
//                      color: Colors.grey,
//                      child: ListTile(
//                        title: Text(
//                          'heading',
//                          style: TextStyle(fontSize: 16, color: Colors.black),
//                        ),
//                        subtitle: Text(
//                          'subHeading',
//                          style: TextStyle(fontSize: 14, color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
//          GestureDetector(
//            onTap: () {
//              Navigator.pushNamed(context, '/AdDetail');
//            },
//            child: Container(
//              width: 160.0,
//              child: Card(
//                child: Wrap(
//                  children: <Widget>[
//                    Container(
//                      height: 120,
//                      child: Image.asset(
//                        'assets/1.jpg',
//                        fit: BoxFit.cover,
//                      ),
//                    ),
//                    Container(
//                      color: Colors.grey,
//                      child: ListTile(
//                        title: Text(
//                          'heading',
//                          style: TextStyle(fontSize: 16, color: Colors.black),
//                        ),
//                        subtitle: Text(
//                          'subHeading',
//                          style: TextStyle(fontSize: 14, color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//  Widget _showInformationForm() {
//    return Container(
//      margin: EdgeInsets.only(top: 30),
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Container(
//            color: Colors.grey[500],
//            width: MediaQuery.of(context).size.width,
//            height: 25,
//            child: Center(
//              child: Text(
//                'Personal Information',
//                style: TextStyle(
//                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
//                    color: Colors.black),
//              ),
//            ),
//          )
//        ],
//      ),
//    );
//  }
//
//  Widget _showPersonalInformation(BuildContext context) {
//    return Container(
//      margin: EdgeInsets.only(left: 14, right: 14, bottom: 10),
//      padding: EdgeInsets.all(10),
//      decoration: BoxDecoration(
//        borderRadius: new BorderRadius.only(
//          bottomLeft: const Radius.circular(10.0),
//          bottomRight: const Radius.circular(10.0),
//        ),
//      ),
//      child: Column(
//        children: <Widget>[
//          Container(
//            height: 50,
//            color: Colors.grey[400],
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                      width: 70,
//                      child: Text(
//                        'Name: ',
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      )),
//                  SizedBox(
//                    width: 50,
//                  ),
//                  Text('Ali Qureshi'),
//                ],
//              ),
//            ),
//          ),
//          Container(
//            height: 50,
//            color: Colors.grey[200],
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                      width: 70,
//                      child: Text(
//                        'Age: ',
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      )),
//                  SizedBox(
//                    width: 50,
//                  ),
//                  Text('35'),
//                ],
//              ),
//            ),
//          ),
//          Container(
//            height: 70,
//            color: Colors.grey[400],
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                      width: 70,
//                      child: Text(
//                        'Address: ',
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      )),
//                  SizedBox(
//                    width: 50,
//                  ),
//                  Flexible(child: Text('DHA Defence, Islamabad')),
//                ],
//              ),
//            ),
//          ),
//          Container(
//            height: 50,
//            color: Colors.grey[200],
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                      width: 70,
//                      child: Text(
//                        'Cell No: ',
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      )),
//                  SizedBox(
//                    width: 50,
//                  ),
//                  Text('+92 333 3424242'),
//                ],
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
  Widget _showContact(BuildContext context) {
    return Container();
  }
//
//  Widget _showReviewForm() {
//    return Container(
//      margin: EdgeInsets.only(top: 30),
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Container(
//            color: Colors.grey[500],
//            width: MediaQuery.of(context).size.width,
//            height: 25,
//            child: Center(
//              child: Text(
//                'User Reviews',
//                style: TextStyle(
//                    fontSize: 18,
//                    fontWeight: FontWeight.bold,
//                    color: Colors.black),
//              ),
//            ),
//          )
//        ],
//      ),
//    );
//  }
//}
}
//showComments(BuildContext context,
//    {String postId}) {
//  Navigator.push(context, MaterialPageRoute(builder: (context) {
//    return Comments(
//      postId: postId,
//      //postOwnerId: ownerId,
//      //   image: mediaUrl,
//    );
//  }));
//}
