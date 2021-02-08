import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/services/PostAdCreation.dart';
import 'package:signup/services/makeBid.dart';

import 'Arguments.dart';
import 'ImageCarousel.dart';

class ViewOffers extends StatefulWidget {
  @override
  _ViewOffers createState() => _ViewOffers();
}

class _ViewOffers extends State<ViewOffers> {
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> userPostIds;
  Stream userPosts;

  @override
  void initState() {
    super.initState();
    getUserAds();

  }
  getUserAds() async {
    await initUser();
    PostAddFirebase().getAllUserAds(user.uid).then((snapshots) {
      setState(() {
        userPosts = snapshots;
        print("we got the data + ${userPosts.toString()} this is id");
      });
    });


  }

  initUser() async {
    user = await _auth.currentUser();
    if (user != null) {
      print(user.uid);

    //  await getActivityFeed();
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    // setState(() {});
  }

 /* getUserPostBids() async {
    List<QuerySnapshot> snapshot = [];
    int offersCounter = 0;
    List<ActivityNotificationItem> notificationItems = [];
    print("this is getUserPostBids");

    for (int i = 0; i < userPostIds.length; i++) {
      print(i.toString());
      snapshot.add(await Firestore.instance.collection('BidList').where('PostID', isEqualTo: userPostIds[i]).getDocuments());
    }

    if (snapshot.length > 0) {
      for (int i = 0; i < snapshot.length; i++) {
        print("this is for offers loop");
        snapshot[i].documents.forEach((doc) {
          if (doc.data.isNotEmpty) {
            print('Activity Bid Item: ${doc.data}');
            notificationItems.add(ActivityNotificationItem.fromDocument(doc));
            offersCounter++;
          }

        });
      }
      if (offersCounter > 0) {
        print(" it is before returning");
        return notificationItems;
      } else {
        Navigator.pop(context);
        Navigator.of(context).pushNamed('/offersNotFound');
      }
    }
  }*/

/*  getActivityFeed() async {
    QuerySnapshot snapshot = await Firestore.instance.collection('PostAdd').where('uid', isEqualTo: user.uid).getDocuments();

    userPostIds = [];
    snapshot.documents.forEach((doc) {
      userPostIds.add(doc.documentID);
      print('Activity Post Item: ${doc.documentID}');
      print(userPostIds.length.toString());
    });
    print("snapshot foreach finished");

    if(userPostIds.length <= 0){
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/offersNotFound');

    }
  }*/

  // ignore: non_constant_identifier_names
  Widget OffersRoomsList() {
    return StreamBuilder(
        stream: userPosts,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return StreamBuilder(
                        stream: Firestore.instance.collection("BidList").where('PostID', isEqualTo: snapshot.data.documents[index]['PostID']).snapshots(),
                        builder: (context, snapshot1) {
                          print("inside the stream builder of Offers query");
                          return snapshot1.hasData ? ListView.builder(
                              itemCount: snapshot1.data.documents.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index1) {
                                return ActivityNotificationItem(
                                  username: snapshot1.data.documents[index1]['Name'].toString(),
                                  bid: snapshot1.data.documents[index1]['Bid'].toString(),
                                  number: snapshot1.data.documents[index1]['Number'].toString(),
                                  PostId: snapshot1.data.documents[index1]['PostID'].toString(),
                                  bidId: snapshot1.data.documents[index1]['BidID'].toString(),
                                );
                              })
                              : Container(width: 0.0, height: 0.0);
                        });
                  });
            }
          } else{
            return Center(child: CircularProgressIndicator());
          }


        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
            ),
          ),
          title: Text('Offers List'),
          centerTitle: true,
        ),
        body:OffersRoomsList(),
        /* Container(
            child: FutureBuilder(
          future: getUserPostBids(),
          builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(child:CircularProgressIndicator());


            }

          return ListView(children: snapshot.data);


          },
        ))*/
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;
String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";
AdPost adPost = new AdPost();

class ActivityNotificationItem extends StatelessWidget {
  final String username;
  final String bid;
  final String bidId;
  final String number;
  final String PostId;

  ActivityNotificationItem({this.username, this.bid, this.number, this.PostId, this.bidId});

  // factory ActivityNotificationItem.fromDocument(DocumentSnapshot doc) {
  //   return ActivityNotificationItem(
  //     username: doc['Name'].toString(),
  //     bid: doc['Bid'].toString(),
  //     number: doc['Number'].toString(),
  //     PostId: doc['PostID'].toString(),
  //     bidId: doc['BidID'].toString(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          color: Colors.white54,
          child: Dismissible(
            key: Key(bidId),
            child: ListTile(
              title: Text(
                username.toString(),
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
                    number.toString(),
                    style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black),
                  ),
                ],
              ),
              trailing: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      'Offer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bid.toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              onTap: () {
                adPost.postId = PostId;
                Navigator.of(context).pushNamed(ImageCarousel.routeName, arguments: ScreenArguments(adPost));
              },
            ),
            background: slideLeftBackground(),
          //  secondaryBackground: slideRightBackground(),
            // ignore: missing_return
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                final bool res = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text("Are you sure you want to delete This Offer?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              // TODO: Delete the item from DB etc..
                              await PostBidFirebase().removeOffer(bidId);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
                return res;
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget slideLeftBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}

Widget slideRightBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}
