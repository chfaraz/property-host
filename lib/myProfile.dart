import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/constants.dart';

class MyProfile extends StatefulWidget {
  final bool isAgent;

  const MyProfile({Key key, this.isAgent}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState(this.isAgent);
}

class _MyProfileState extends State<MyProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAgent = true;
  String searchTxt;
  String data;
  String Two;

  _MyProfileState(this.isAgent);

  //bool isAdmin = false;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  TextEditingController addController = TextEditingController();
  FirebaseUser user;

  ScrollController _scrollController = ScrollController();
  Firestore firestore = Firestore.instance;
  List<DocumentSnapshot> agents = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot lastDocument;
  StreamController<List<DocumentSnapshot>> _controller = StreamController<List<DocumentSnapshot>>.broadcast();

  Stream<List<DocumentSnapshot>> get _streamController => _controller.stream;

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getChats();
        print("in add scroll listnr");
      }
    });
    setState(() {});
  }

  String validateSearchPhoneNumber(String value){
    String pattern = r'(^((\+92))\d{3}\d{7}$)';
    RegExp regExp = new RegExp(pattern);

    if(regExp.hasMatch(value)){
      return 'Success';
    }
    return null;
  }

  getChats() async {
    if (isLoading) {
      print(isLoading.toString());
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    String validateNumber;

    if (lastDocument == null) {
      print("First if lastdocument is null");
      if (searchTxt != null && searchTxt != '') {
        validateNumber = validateSearchPhoneNumber(searchTxt);
        if(validateNumber=='Success'){
          print("mobile number entered");
          querySnapshot = await firestore
              .collection('users')
              .where('UserType', isEqualTo: 'Agent')
              .where('phoneNumber', isEqualTo: searchTxt)
              .getDocuments();
        }
        else{
          querySnapshot = await firestore
              .collection('users')
              .where('UserType', isEqualTo: 'Agent')
              .where('searchIndex', arrayContains: searchTxt)
              .orderBy('displayName', descending: false)
              .limit(documentLimit)
              .getDocuments();

        }
        print("search text is  not null");
      }

    } else {
      print("First else lastdocument is not null");
      if (searchTxt != null && searchTxt != '') {
        querySnapshot = await firestore
            .collection('users')
            .where('UserType', isEqualTo: 'Agent')
            .where('searchIndex', arrayContains: searchTxt)
            .orderBy('displayName', descending: false)
            .startAfterDocument(lastDocument)
            .limit(documentLimit)
            .getDocuments();

        print("in else lastdocumetn  search text is not null");
      }
    }
    print("out of else");

  if (querySnapshot.documents.isEmpty) {
    print('No More agents');
    setLoading(false);
    return;
  }

  print(querySnapshot.documents.length.toString() + "before the lastdocumetn line ");

  lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
  agents.addAll(querySnapshot.documents);
  _controller.sink.add(agents);

  setLoading(false);

  }

  void setLoading([bool value = false]) => setState(() {
        isLoading = value;
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("List of Agents"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
            ),
          ),
          centerTitle: true,
        ),
        body: user != null
            ? Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(kDefaultPadding),
                          padding: EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding / 4, // 5 top and bottom
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: addController,
                            onChanged: (val) {
                              setState(() {
                                searchTxt = val.toUpperCase();
                              });
                            },
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                              //letterSpacing: 2.0,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    // addController.clear();
                                    if(searchTxt !=null && searchTxt !=''){
                                    print(searchTxt);
                                    lastDocument = null;
                                    agents.clear();
                                    print(lastDocument.toString() + "here is clear");
                                    print(searchTxt);
                                    getChats();
                                  }}),
                            /*  icon: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    addController.clear();
                                    searchTxt = '';
                                    lastDocument = null;
                                    agents.clear();
                                    print(lastDocument.toString() + "here is clear");
                                    print(searchTxt);
                                  }),*/
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              // icon: Icon(Icons.clear),
                              //icon: SvgPicture.asset("assets/icons/search.svg"),
                              labelText: 'City or Number with +92 code',
                              hintStyle: TextStyle(color: Colors.grey[700],fontSize: 15),
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<DocumentSnapshot>>(
                              stream: _streamController,
                              // ignore: missing_return
                              builder: (BuildContext context, snapshot) {
                                // ignore: missing_return

                                if (snapshot.hasError) {
                                  return Text('We got an error ${snapshot.hasError}');
                                }
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return SizedBox(
                                      child: Center(
                                        child: Text('Search agent by typing above'),
                                      ),
                                    );
                                  case ConnectionState.none:
                                    return SizedBox(
                                      child: Text('Oops,No data'),
                                    );
                                  case ConnectionState.done:
                                    return SizedBox(
                                      child: Text('We are done'),
                                    );
                                  default:
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        controller: _scrollController,
                                        //  reverse: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                              child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                  child: GestureDetector(
                                                    onTap: () => {data = snapshot.data.elementAt(index)['uid'], Navigator.of(context).pushNamed('/myProfileFinal', arguments: data)},
                                                    child: Card(

                                                      elevation: 5,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(0.0),
                                                      ),
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                          top: 12.5,
                                                        ),
                                                        decoration: BoxDecoration(color: Colors.white),
                                                        width: MediaQuery.of(context).size.width,
                                                        padding: EdgeInsets
                                                            .symmetric(horizontal: 7, vertical: 5),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                snapshot.data.elementAt(index)['image'] != null
                                                                    ? Container(
                                                                  margin: EdgeInsets.only(top: 3),
                                                                  decoration: new BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    border: new Border.all(
                                                                      color: Color(0xff0286D0),
                                                                      width: 1.0,
                                                                    ),
                                                                  ),
                                                                  width: 70.0,
                                                                  height: 70.0,
                                                                  //color: Colors.green,

                                                                  child: CircleAvatar(
                                                                    //backgroundColor: Colors.green,
                                                                    //foregroundColor: Colors.green,
                                                                    //backgroundImage: AssetImage('assets/1.jpg'),
                                                                    //backgroundImage: NetworkImage(snapshot.data['image']),
                                                                    backgroundImage: NetworkImage(snapshot.data.elementAt(index)['image']),
//                                          Image.network(snapshot.data.documents
//                                              .elementAt(index)['image']),
//                                          //Image.network(snapshot.data['url'],),
                                                                    //Image.network(snapshot.data['url'],),
                                                                  ),
                                                                )
                                                                    : Container(
                                                                  width: 70.0,
                                                                  height: 70.0,
                                                                  //color: Colors.green,
                                                                  margin: EdgeInsets.only(
                                                                    right: 12.5,
                                                                  ),
                                                                  child: CircleAvatar(
                                                                    //backgroundColor: Colors.green,
                                                                    //foregroundColor: Colors.green,
                                                                    //backgroundImage: AssetImage('assets/1.jpg'),
                                                                    //backgroundImage: NetworkImage(snapshot.data['image']),
                                                                    backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg"),
                                                                    //Image.network(snapshot.data['url'],),
                                                                  ),
                                                                ),

                                                                Container(
                                                                  margin: EdgeInsets.only(
                                                                    top: 5.5,
                                                                  ),
                                                                  child: Column(
                                                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                                                    //mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 8,),
                                                                        child: Text(
                                                                          snapshot.data.elementAt(index)['displayName'],
                                                                          //   snapshot.data.documents.elementAt(index)['displayName'],

                                                                          style: TextStyle(
                                                                            fontFamily: 'Poppins',
                                                                            color: Colors.black,
                                                                            fontSize: 12.0,
                                                                            fontWeight: FontWeight.w700,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
//                                                                    margin: EdgeInsets.only(top: 7),
                                                                        child: StreamBuilder(
                                                                            stream: Firestore.instance
                                                                                .collection("Rating")
                                                                                .where("agentId", isEqualTo: snapshot.data.elementAt(index)['uid'])
                                                                                .snapshots(),
                                                                            builder: (BuildContext context, snapshot1) {
                                                                              //faraz
                                                                              if (snapshot1.data == null) return CircularProgressIndicator();
                                                                              //faraz
                                                                              if (snapshot1.hasData != null) {
                                                                                double allRatingSum = 0.0;
                                                                                String stars = "";
                                                                                int averageOfRating = 0;
                                                                                Two =snapshot1.data.documents.length.toString();
                                                                                if (snapshot1.data.documents.length > 0) {
                                                                                  for (int i = 0; i < snapshot1.data.documents.length; i++) {
                                                                                    allRatingSum += snapshot1.data.documents[i]['rate'].length;
                                                                                    print(snapshot1.data.documents[i]['rate'].length.toString());
                                                                                    print(snapshot1.data.documents[i]['rate'].length);

                                                                                    //print("Length${snapshot1.data.documents.length}");
                                                                                  }

                                                                                  averageOfRating = (allRatingSum / snapshot1.data.documents.length).round();
                                                                                  print("avergae + $averageOfRating");

                                                                                  for (int j = 0; j < averageOfRating; j++) {
                                                                                    stars += "⭐";

                                                                                  }
                                                                                  //print(stars.length.toString());
                                                                                  return Container(
                                                                                    margin: EdgeInsets.only(
                                                                                      left: 4,
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                                                                                      child: Row(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [

                                                                                          Text("Rating:", style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                                                                          Container(
                                                                                            margin: EdgeInsets.only(
                                                                                              top: 1.5,
                                                                                            ),
                                                                                            child: Text(stars, style: TextStyle(fontSize: 10, color: Colors.black54)),
                                                                                          ),

                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                } else {
                                                                                  return SizedBox();
                                                                                }
                                                                              } else {
                                                                                return Container();
                                                                              }
                                                                            }),
                                                                      ),

                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Container(
//                                                                  margin:
//                                                            EdgeInsets.only(top: 5),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(2.0),
                                                                    child: FlatButton(
                                                                      color: Color(0xff00AFFF),
                                                                      onPressed: () {
//                                          Navigator.pushNamed(context, '/myProfileFinal');
                                                                        data = snapshot.data.elementAt(index)['uid'];
                                                                        Navigator.of(context).pushNamed('/myProfileFinal', arguments: data);
                                                                        //Navigator.of(context).pushNamed(CurrentUser(),arguments: data);
                                                                        print(data);
                                                                      },
                                                                      child: Text('Visit Profile',
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 12,
                                                                          )),
                                                                      shape: RoundedRectangleBorder(
                                                                          side: BorderSide(
                                                                            //        color: Colors.grey[500],
                                                                              color: Color(0xff00AFFF),
                                                                              width: 1.5,
                                                                              style: BorderStyle.solid),
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                    ),
//                        SmoothStarRating(
//                            allowHalfRating: false,
//                            onRated: (v) {
//                            },
//                            starCount: 5,
//                            rating: rating,
//                            size: 20,
//                            isReadOnly:true,
//                            //     fullRatedIconData: Icons.blur_off,
//                            //     halfRatedIconData: Icons.blur_on,
//                            color: Colors.yellow,
//                            borderColor: Colors.orange,
//                            spacing:0.0
//                        ),
                                                                  ),
                                                                ),
                                                                Container(
//                                                                    margin: EdgeInsets.only(top: 7),
                                                                  child: StreamBuilder(
                                                                      stream: Firestore.instance
                                                                          .collection("Rating")
                                                                          .where("agentId", isEqualTo: snapshot.data.elementAt(index)['uid'])
                                                                          .snapshots(),
                                                                      builder: (BuildContext context, snapshot1) {
                                                                        //faraz
                                                                        if (snapshot1.data == null) return CircularProgressIndicator();
                                                                        //faraz
                                                                        if (snapshot1.hasData != null) {
                                                                          double allRatingSum = 0.0;
                                                                          String stars = "";
                                                                          int averageOfRating = 0;
                                                                          Two =snapshot1.data.documents.length.toString();
                                                                          if (snapshot1.data.documents.length > 0) {
                                                                            for (int i = 0; i < snapshot1.data.documents.length; i++) {
                                                                              allRatingSum += snapshot1.data.documents[i]['rate'].length;
                                                                              print(snapshot1.data.documents[i]['rate'].length.toString());
                                                                              print(snapshot1.data.documents[i]['rate'].length);

                                                                              //print("Length${snapshot1.data.documents.length}");
                                                                            }

                                                                            averageOfRating = (allRatingSum / snapshot1.data.documents.length).round();
                                                                            print("avergae + $averageOfRating");

                                                                            for (int j = 0; j < averageOfRating; j++) {
                                                                              stars += "⭐";

                                                                            }
                                                                            //print(stars.length.toString());
                                                                            return Container(
                                                                              margin: EdgeInsets.only(
                                                                                left: 4,
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                                                                                child: Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [

                                                                                    Container(
                                                                                        margin: EdgeInsets.only(
                                                                                          top: 2.3,
                                                                                        ),
                                                                                        child: Text("People Rated: ", style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold))),

                                                                                    Text(Two, style: TextStyle(fontSize: 12, color: Colors.black54,fontFamily: "Poppins",fontWeight: FontWeight.w700 )),


//                                                                        Padding(
//                                                                          padding: const EdgeInsets.all(8.0),
//                                                                          child: Container(
//                                                                            decoration: BoxDecoration(
//                                                                              border: Border.all(color: Colors.grey),
//                                                                            ),
//                                                                            child: Text
//                                                                              (stars.length.toString(), style: TextStyle(fontSize: 15, color: Colors.black54)),
//                                                                          ),
//                                                                        ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return SizedBox();
                                                                          }
                                                                        } else {
                                                                          return Container();
                                                                        }
                                                                      }),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ));
                                        },
                                      );
                                    }
                                }
                              }),
                        ),
                        isLoading
                            ? Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5),
                          color: Colors.blue,
                          child: Text(
                            'Loading',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              )
            : Center(child: Text("Error")),
      ),
    );
  }
}
