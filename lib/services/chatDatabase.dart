import 'package:cloud_firestore/cloud_firestore.dart';

class chatdatabase {


  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  removeChat({String chatRoomId,String userId}) async{


  await  Firestore.instance.collection("chatRoom").document(chatRoomId).collection(userId).getDocuments().then((snapshot) {
      snapshot.documents.forEach((element) {
        Firestore.instance.collection("chatRoom").document(chatRoomId).collection(userId).document(element.documentID).delete();
        print(element.documentID.toString());
      });
    });

    // await Firestore.instance.collection("chatRoom").document(chatRoomId).delete();

  }




  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('displayName', isEqualTo: searchField)
        .getDocuments();
  }


  Future<bool> addChatRoom(chatRoom, chatRoomId) {

    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  Future<bool> updateChatRoomName(List<String> chatRoomName,List<String> chatID) async{

    for(int i =0 ; i<chatID.length; i++){

      await Firestore.instance
          .collection("chatRoom")
          .document(chatID[i])
          .updateData({
        'chatRoomName':chatRoomName[i]
      }).catchError((e) {
        print(e);
      });

    }

  }


  getChats(String chatRoomId,String sendUserId) async{
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection(sendUserId)
        .orderBy('time')
        .snapshots();
  }

  checkChatRoomIdInDataBase() async{
    return await Firestore.instance.collection("chatRoom").getDocuments();

  }

  Future<void> addMessage (String chatRoomId, chatMessageData,senderUserId,receiverUserId) async{
    print(senderUserId + "+" + receiverUserId);

   await Firestore.instance.collection("chatRoom")
        .document(chatRoomId)
        .collection(senderUserId)
        .add(chatMessageData).catchError((e){
      print(e.toString());
    });
  await  Firestore.instance.collection("chatRoom")
        .document(chatRoomId)
        .collection(receiverUserId)
        .add(chatMessageData).catchError((e){
      print(e.toString());
    });
  }

  getUserChats(String uid) async {
    return await Firestore.instance.collection("chatRoom").where('users',arrayContains: uid).snapshots();
  }

  getusersForBlock(String uid) async {
    return await Firestore.instance.collection("chatRoom").document(uid).snapshots();
  }

}
