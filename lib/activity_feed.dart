import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signup/header.dart';
import 'package:signup/progress.dart';
import 'dart:developer';
import 'package:timeago/timeago.dart' as timeago;
import 'package:signup/states/currentUser.dart';

class ActivityFeed extends StatefulWidget {
  static const routeName = '/activityFeed';
//  final String data;
//
//  ActivityFeed({Key key, this.data});

  //const ActivityFeed({Key key, this.data}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  //final String data;
  //String postId;
  final activityFeedRef = Firestore.instance.collection('Rating');

 // _ActivityFeedState({this.data});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  FirebaseUser user;

  @override
  void initState() {

    super.initState();
//print(user.uid);
    initUser();
  }
  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }
 // _ActivityFeedState({this.postId});
  getActivityFeed() async {
    //final data = ModalRoute.of(context).settings.arguments as String;
    QuerySnapshot snapshot = await Firestore.instance.collection('Rating')
        .where('agentId', isEqualTo: user.uid).getDocuments();
//    snapshot.documents.forEach((doc) {
//      print('Activity Feed Item: ${doc.data}');
//    });
//    return snapshot.documents;
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
//       print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    //final dataOne = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(flexibleSpace: Container(
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
        title: Text('My Feed'),centerTitle: true,),
      body: user != null ? Container(
          child: FutureBuilder(
            future: getActivityFeed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              // print('imp2${user.uid}');
              return ListView(
                  children: snapshot.data);
            },
          )) :
      Center(child: CircularProgressIndicator()),

    );
  }}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String rating;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.rating,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      rating: doc['rate'],
      timestamp: doc['time'],
      avatarUrl: doc['avatarUrl'],

    );
  }

  @override
  Widget build(BuildContext context) {
    Timestamp stamp = Timestamp.now();
    DateTime dates = stamp.toDate();
    //DateTime date = DateTime.fromMillisecondsSinceEpoch(dates);
    var formattedDate = DateFormat.yMMMd().format(dates);
    var formattedDate2 = DateFormat.yMMMd().format(dates);
//    var formattedDate2 = DateFormat.Hm().format(date);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
            child: Row(
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(avatarUrl.toString()),
                    radius: 23.0,
                  ),
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: Color(0xff00AFFF),
                      width: 2.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        username,
                        style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        comment,
                        maxLines: 3,
                        //overflow:TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 80),
                        child: Text(
                          rating,
                          style: TextStyle(fontSize: 12),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 80),
                      child: Text(
                        " " + formattedDate2.toString(),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),

//                  Text(
//                    " " + formattedDate.toString(),
//                    style: TextStyle( fontSize: 9,
//                      fontWeight: FontWeight.w700,
//                      color: Colors.black,),
//                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 30),
          child: Divider(
            height: 0.0,
            color: Colors.black38,
            indent: 33.0,
            endIndent: 10.0,
          ),
        ),
      ],
    );
  }
}
