import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:signup/AppLogic/validation.dart';

import 'package:signup/activity_feed.dart';
import 'package:signup/header.dart';
import 'package:signup/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'helper/constants.dart';
import 'helper/helperfunctions.dart';

class Comments extends StatefulWidget {
  final String userId;
  final String AgentId;

  Comments({
    this.userId,
    this.AgentId
  });

  final DateTime timestamp = DateTime.now();

  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getuserName() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
  }

  FirebaseUser user;
  String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    print(widget.userId.toString());
    myFocusNode = FocusNode();
    initUser();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  var items = ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐'];
  TextEditingController name = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  String userid;

  initUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      userid = user.uid;
      getuserName();
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    setState(() {});
  }

  TextEditingController commentController = TextEditingController();
  final TextEditingController _controller = new TextEditingController();
 final String userId;

 final String agentId;
  //final String postMediaUrl;

 CommentsState({
    this.userId,
   this.agentId
  });

  buildComments() {
  //  final commentsRef = Firestore.instance.collection('Rating');
    return StreamBuilder(
        stream:Firestore.instance.collection("Rating").where("agentId", isEqualTo: widget.AgentId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  Future<bool> checkUserRating(String uid) async{
    DocumentSnapshot _docSnapshot =  await Firestore.instance.collection("Rating").document(uid).get();
    if(_docSnapshot.data !=null){
      return true;
    }
    else{
      return false;
    }


  }

  addRating() async{
    print("in add  comment");
    try {
      await Firestore.instance.collection("Rating").document(widget.userId).setData({
        "username": Constants.myName,
        "comment": commentController.text,
        "time": widget.timestamp,
        "avatarUrl": data,
        "userId": widget.userId,
        "agentId":widget.AgentId,
        'rate': _controller.text,
      });
      print("Success rating added");
      print(_controller.text.length.toString());

    }catch(e){
      print(e.toString());
    }

    commentController.clear();
  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Form(
        //key: scaffoldKey,
        key: _key,
        child:
            //  appBar: header(context, titleText: "Comments"),
            Scaffold(
          body: StreamBuilder(
                  stream: Firestore.instance.collection('users').where("uid",isEqualTo: widget.userId).snapshots(),
                  // ignore: missing_return
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data.documents.length.toString());
                      return  ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          padding: const EdgeInsets.only(top: 5.0),
                          itemBuilder: (context, int index) {
                            return Column(
                              children: <Widget>[
                                // ignore: unrelated_type_equality_checks
                                Container(alignment: Alignment.center,
                                height: 410, child: buildComments()),
                              //  Divider(),
                                snapshot.data.documents[index].data["UserType"] == "user"
                                    ? Container(
                                        height: 200,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(left: 16, right: 110),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      IntrinsicWidth(
                                                        child: TextFormField(
                                                          focusNode: myFocusNode,
                                                          maxLines: 1,
                                                          controller: _controller,
                                                          keyboardType: TextInputType.text,
                                                          validator: validateStars,
                                                          readOnly: true,
                                                          autofocus: false,
                                                          decoration: InputDecoration(
                                                         hintText: "Give Stars",
                                                          ),
                                                        ),
                                                      ),
                                                      //TextField(decoration: InputDecoration( hintText: "Give Stars"),controller: _controller,)),

                                                      PopupMenuButton<String>(
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        onSelected: (String value) {
                                                          _controller.text = value;
                                                        },
                                                        itemBuilder: (BuildContext context) {
                                                          return items.map<PopupMenuItem<String>>((String value) {
                                                            return new PopupMenuItem(child: new Text(value), value: value);
                                                          }).toList();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ListTile(
                                                  title: TextFormField(
                                                    focusNode: myFocusNode,
                                                    validator: ValidateComment,
                                                    controller: commentController,
                                                    decoration: InputDecoration(labelText: "Write a comment..."),
                                                  ),
                                                  trailing: OutlineButton(
                                                    onPressed: () async{
                                                      FocusScope.of(context).requestFocus(new FocusNode());
                                                      if (_key.currentState.validate()) {
                                                        _key.currentState.save();
                                                     //   bool check = await checkUserRating(widget.userId);
                                                     //    if(check ==true){
                                                     //      print("you cannot rate again");
                                                     //    }
                                                     //    else{
                                                        addRating();
                                                      //}

                                                      } else {
                                                        setState(() {
                                                          _validate =true;
                                                        });
                                                      }
                                                      // _controller.clear();
                                                      // name.clear();
                                                      // commentController.clear();
                                                    },

                                                    // addComment,
                                                    borderSide: BorderSide.none,
                                                    child: Text("Post"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ) :SizedBox(),
                              ],
                            );
                          });
                    }
                    return Container();
                  }),
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String rating;
  final Timestamp timestamp;

  //Timestamp accountCreated;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.rating,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
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
