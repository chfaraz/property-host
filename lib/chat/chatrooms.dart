import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:signup/helper/constants.dart';
import 'package:signup/helper/helperfunctions.dart';
import 'package:signup/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:signup/services/chatDatabase.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  ////////////////Encrption decription varibles //////////

  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(16);




  ///////////ends here //////////

  @override
  void initState() {
    super.initState();
    String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";
    getUserInfogetChats();
  }

  initUser() async {
    user = await _auth.currentUser();
    if (user != null) {
      print(user.uid);
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    setState(() {});
  }

  Stream chatRooms;
  Stream chats;

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRooms,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (snapshot.connectionState == ConnectionState.waiting)  return Center(child: CircularProgressIndicator());
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                      stream: Firestore.instance
                          .collection("chatRoom")
                          .document(snapshot.data.documents[index].documentID)
                          .collection(user.uid)
                          .orderBy("time", descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot1) {
                        print("inside the stream builder of chat query");
                        return snapshot1.hasData
                            ? ListView.builder(
                                itemCount: snapshot1.data.documents.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index1) {
                                  String msg = decryptedMessage(snapshot1.data.documents[index1]["message"]);
                                  return ChatRoomsTile(
                                    userName: snapshot.data.documents[index].data['chatRoomName'].toString().replaceAll("_", "").replaceAll(Constants.myName, ""),
                                    chatRoomId: snapshot.data.documents[index].documentID,
                                    message: msg,
                                    Time: snapshot1.data.documents[index1]["time"],
                                    userId: user.uid,
                                  );
                                })
                            : Container();
                      });
                });
          }

        /* else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }*/
         else if (snapshot.data == null) {
            return Container(child:Center(child: Text("No messages come back later")));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  String decryptedMessage(message){
    print(message.toString() + " it is message in decrpt");
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt16(message, iv: iv);
    print(decrypted + "decrpyt");

    return decrypted;

  }



  getUserInfogetChats() async {
    await initUser();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myUid = user.uid;
    print(Constants.receiverUid + "receiver id");
    chatdatabase().getUserChats(Constants.myUid).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print("we got the data + ${chatRooms.toString()} this is name  ${Constants.myUid} ${Constants.receiverUid}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          //backgroundColor: Colors.white,
          backgroundColor: Color(0xffFFFFFF),
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text("Inbox"),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue[800], Colors.blue[800]], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(0.5, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
              ),
            ),
          ),
          body: chatRoomsList()),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final String message;
  final int Time;
  final userId;
  final receiverId;

  ChatRoomsTile({this.userName, @required this.chatRoomId, @required this.message, @required this.Time,@required this.userId,@required this.receiverId});

  var isDisable=false;
  @override
  Widget build(BuildContext context) {
    String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";

    String changeText;
    //var date = DateFormat.format(Time.toString());
    //var date = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(Time);
    var formattedDate = DateFormat.yMMMd().format(date);
    //var formattedDate2 = DateFormat.yMMMd().format(date);
    var formattedDate2 = DateFormat.Hm().format(date);



    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                      userName: userName,
                      sendUserId: userId,
                    )));
      },

      /*onLongPress: () {
        Alert(
          context:context,
          style: alertStyle,
          type: AlertType.warning,
          title: "Are You Sure !!",
          desc: "To Delete The Chat?",
          buttons: [

            DialogButton(
              child: Text("Delete",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: isDisable==false  ? (){
                myTapCallback();
                Navigator.pop(context);
              }  : null,
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      },*/

      child: Column(
        children: [
          Dismissible(
            key: Key(chatRoomId),
           child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(data),
                        radius: 25.0,
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
                          userName != null
                              ? Text(
                            userName,
                            style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                          )
                              : Text(
                            "",
                            style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
                          ),
                          message != null
                              ? Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                          )
                              : Text(
                            "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        formattedDate2 != null
                            ? Text(
                          " " + formattedDate2.toString(),
                          style: TextStyle(color: Colors.grey[700]),
                        )
                            : Text(
                          " ",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        formattedDate != null
                            ? Text(
                          " " + formattedDate.toString(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        )
                            : Text(
                          " ",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      background: slideLeftBackground(),
     // secondaryBackground: slideRightBackground(),
      // ignore: missing_return
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Are you sure you want to delete This chat?"),
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
                        await chatdatabase().removeChat(chatRoomId: chatRoomId,userId: userId);
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
      ),
    );


  }

  /*myTapCallback() async{
    print(chatRoomId.toString() + isDisable.toString());
    isDisable = true;
    await chatdatabase().removeChat(chatRoomId: chatRoomId,userId: userId);
    print(isDisable.toString());

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
  );*/

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
