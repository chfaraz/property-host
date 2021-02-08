import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:signup/services/chatDatabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String sendUserId;

  Chat({this.chatRoomId,this.userName,this.sendUserId,});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  Stream<QuerySnapshot> chats;
  Stream<DocumentSnapshot> getUserChat;
   Map user1,user2;
   String blocktextButton = "Block";
   bool userBlockedByReceiver = false;
  bool youBlockUser = false;
   String recieverId="";


   ////////////////Encrption decription varibles //////////

  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(16);




  ///////////ends here //////////

  TextEditingController messageEditingController = new TextEditingController();



  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        //print(snapshot.data.documents.length);
        return snapshot.hasData ?  Expanded(

          child: ListView.builder(
              reverse: true,
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                final reversedIndex = snapshot.data.documents.length - 1 - index;
              final msgs =  decryptedMessage(snapshot.data.documents[reversedIndex].data["message"]);
              print(msgs +" decrpted in message tile");
                return MessageTile(
                  message:msgs,
                  sendByMe: widget.sendUserId == snapshot.data.documents[reversedIndex].data["sendBy"],
                  chatRoomId:widget.chatRoomId,
                  messageId: snapshot.data.documents[reversedIndex].data["messageId"].toString(),
                );
              }),
        ) : Container();
      },
    );
  }

  String decryptedMessage(message){
    print(message.toString() + " it is message in decrpt");
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt16(message, iv: iv);
    print(decrypted + "decrpyt");

    return decrypted;

  }

 String encryptMessage(message){
   final encrypter = encrypt.Encrypter(encrypt.AES(key));
   final encrypted = encrypter.encrypt(message, iv: iv);
  // final decrypted = encrypter.decrypt16(encrypted.base16, iv: iv);
   print(encrypted.base16);

  return encrypted.base16;


}



  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
    final msg =   encryptMessage(messageEditingController.text);
      Map<String, dynamic> chatMessageMap = {
        "sendBy": widget.sendUserId,
        "message": msg,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      chatdatabase().addMessage(widget.chatRoomId, chatMessageMap,widget.sendUserId,recieverId);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState(){

    getChat();
   getUserInfogetChats();
   encryptMessage("message");
    super.initState();
  }



  getChat() async{

    print(widget.chatRoomId + " it is in getchat before going to database");
    await chatdatabase().getChats(widget.chatRoomId,widget.sendUserId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  getUserInfogetChats() async {
    print(widget.chatRoomId + "chatroom id");
    chatdatabase().getusersForBlock(widget.chatRoomId).then((snapshots) {
      setState(() {
        getUserChat = snapshots;
        print("we got the data + ${getUserChat.toString()}");
      });
    });
  }

  var redrawObject;
  @override
  Widget build(BuildContext context) {

    blockUserAlert(BuildContext context) {

      return showDialog(
          context: context,
          builder: (context) {

            return AlertDialog(
              title: Text('Are you Sure you Want to ${blocktextButton} the ${widget.userName}?'),
              content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        Container(

                        ),
                      ],
                    ),
                  ),
              ),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  child: Text(blocktextButton),
                  onPressed: () async {
                 //   print(recieverId_ToBlock['id'].toString());
                    if(blocktextButton =="Block"){
                      print(blocktextButton + user1.toString() + user2.toString());
                    if(user1!=null){
                    await  Firestore.instance.collection("chatRoom").document(widget.chatRoomId).updateData({
                        'user1.Block':true
                      });
                    setState(() {
                      blocktextButton = "Unblock";
                    });
                      print("sucess user blocked");

                    }
                    else if(user2 !=null){
                    await  Firestore.instance.collection("chatRoom").document(widget.chatRoomId).updateData({
                        'user2.Block':true
                      });

                    setState(() {
                      blocktextButton = "Unblock";
                    });

                      print("sucess user blocked");

                    }

                    } else{
                      print("this unblock else" + user1.toString() + user2.toString());

                      if(user1!=null){
                        print("user1 is not null");
                          await  Firestore.instance.collection("chatRoom").document(widget.chatRoomId).updateData({
                            'user1.Block':false
                          });
                          setState(() {
                            blocktextButton = "Block";
                            youBlockUser = false;
                          });
                          print("sucess user unblocked");
                      }
                      else if(user2!=null){
                        print("user2 is not null");
                          await  Firestore.instance.collection("chatRoom").document(widget.chatRoomId).updateData({
                            'user2.Block':false
                          });

                          setState(() {
                            blocktextButton = "Block";
                            youBlockUser = false;
                          });

                          print("sucess user unblocked");
                      }


                    }

                Navigator.pop(context);

                    },
                ),
                MaterialButton(
                  elevation: 5.0,
                  child: Text('Cancel'),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.userName),
          centerTitle: true,
          //backgroundColor: Color(0xffBF7DBF),
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
          actions: <Widget> [


            Container(
              height: 50,
              width: 40,
              child: StreamBuilder(
                  stream: getUserChat,
                  // ignore: missing_return
                  builder:
                  // ignore: missing_return
                      (BuildContext context,  snapshot) {

                              return  PopupMenuButton(
                                itemBuilder: (content) =>
                                [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(blocktextButton),
                                  )
                                ],
                                onSelected: (int menu) {
                                  if (menu == 1) {
                                    blockUserAlert(context);
                                  }
                                },
                              );
                  }

              ),
            ),

          ],
        ),
        //appBar: appBarMain(context),
        body: Container(
          color: Color(0xffEFECEF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: <Widget>[
              chatMessages(),
              StreamBuilder(
                  stream: getUserChat,
                  // ignore: missing_return
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData && snapshot.data !=null) {
                      print("snapshot has the data ");

                     if(snapshot.data['user1']['id'] == widget.sendUserId){
                       recieverId = snapshot.data['user2']['id'];
                       print(recieverId +" recievr id");
                       user2 = snapshot.data['user2'];



                       if(snapshot.data['user1']['Block']==true){
                         userBlockedByReceiver = true;
                         print("Your are blocked by the reciever");
                       }

                       if(snapshot.data['user2']['Block']==true){

                          print("You have blocked this earlier");
                           youBlockUser = true;
                           blocktextButton = "Unblock";

                       }

                     } else{
                          if(snapshot.data['user2']['id'] ==widget.sendUserId){
                            recieverId = snapshot.data['user1']['id'];
                            print(recieverId +" recievr id");
                            user1 = snapshot.data['user1'];

                            if(snapshot.data['user2']['Block']==true){
                                      userBlockedByReceiver = true;
                                      print("You are blocked by reciever");

                          }

                            if(snapshot.data['user1']['Block']==true){

                              print("You have blocked this earlier");
                              youBlockUser = true;
                              blocktextButton = "Unblock";

                            }

                     }

                     }

                      return blocktextButton == "Unblock" || userBlockedByReceiver==true || youBlockUser ==true ?  Container(child: Center(child: Text("Blocked")),
                        ) : Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        color: Color(0x54FFFFFF),
                        child: Row(
                          children: [
                            Container(
                              child: Expanded(
                                child: TextField(
                                  controller: messageEditingController,
                                  decoration: InputDecoration(labelText: 'Send a message...'),
                                ),
                              ),
                            ),
                            IconButton(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              icon: Icon(
                                Icons.send,
                              ),
                              onPressed: addMessage,
                            )
                          ],
                        ),
                      );

                    }
                    return Container();
                  }),


            ],
          ),
        ),
      ),
    );
  }

}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String chatRoomId;
  final String messageId;

  MessageTile({@required this.message, @required this.sendByMe,@required this.chatRoomId,@required this.messageId});

  @override
  Widget build(BuildContext context) {
    debugPrint(sendByMe.toString());

    return Container(
        padding: EdgeInsets.only(
            top: 6,
            bottom: 6,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15)
              ) :
              BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15)),
              color: sendByMe ? Color(0xffFFFEFF): Color(0xffFE5253),

          ),

          child: Column(children: <Widget>[
            GestureDetector(
              onTap: () {
                print("On message tap" + messageId);
                //   _moreMessageOptions(context);
              },
              child: Text(message,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                       color: sendByMe ? Colors.black : Colors.white,

                      //   backgroundColor:Colors.black,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
            )
          ]),
        ));
  }


  Future<void> _moreMessageOptions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(
              'Click Delete message to permanently delete the message'),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete Message'),
//              onPressed: () {
//                chatdatabase().removeChat(chatRoomId: chatRoomId, messageId: messageId);
//                Navigator.of(context).pop();
//              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

