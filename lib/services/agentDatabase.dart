import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signup/models/AgentUser.dart';
import 'package:signup/models/user.dart';

class AgentDatabase{
  final Firestore _firestore = Firestore.instance;

  convertToIndex(String City) async {
    List<String> splitList = City.split(' ');
    List<String> indexList = [];
    print("in convert fun" + City.toString() + splitList.length.toString());

    for(int i=0; i< splitList.length; i++)
    {
      for(int j=0; j<= splitList[i].length + i; j++)
      {
        print("in  j ");
        indexList.add(splitList[i].substring(0, j).toUpperCase());
      }
    }
    print(indexList.toString());
    return indexList;
  }

  // ignore: non_constant_identifier_names
  Future<void> ApplyForAgent(AgentUser user) async {
    String retVal = 'error';
    try {

      user.SearchindexList = await convertToIndex(user.city);
      print(user.SearchindexList.toString());
      await _firestore.collection('agentRequest').document(user.uid).setData({
        'displayName': user.Name,
        'Address': user.address,
        'description': user.description,
        'phoneNumber': user.phoneNumber,
        'city':user.city,
        'uid': user.uid,
        'age':user.age,
        'UserType': "user",
        'Location':user.location,
        'searchIndex':user.SearchindexList

        //    'accountCreated' : Timestamp.now(),
      });
      retVal='Success';
      print("success");
    }
    catch (e) {
      print(e.toString() +"Error");
    }
   // return retVal;
  }
  Future<void> ReportAgent(AgentUser agentuser,OurUser user) async {
    String retVal = 'error';
    QuerySnapshot documentSnapshot;
    try {

         documentSnapshot =    await _firestore.collection('feedBack').where('uid',isEqualTo: user.uid).where('agentId',isEqualTo: agentuser.uid).getDocuments();
      if(documentSnapshot.documents.length >0){
        print("document found");
        await _firestore.collection('feedBack').document(documentSnapshot.documents.first.documentID).setData({
          'agentName': agentuser.Name,
          'agentPhoneNumber': agentuser.phoneNumber,
          'agentId':agentuser.uid,
          'userName': user.displayName,
          'userPhoneNumber': user.phoneNumber,
          'feedback': user.feedback,
          "feedbackId":documentSnapshot.documents.first.documentID,
          'uid':user.uid,
          'UserType':user.UserType
        });
        print("success");

      } else{
        await _firestore.collection('feedBack').add({
          'agentName': agentuser.Name,
          'agentPhoneNumber': agentuser.phoneNumber,
          'agentId':agentuser.uid,
          'userName': user.displayName,
          'userPhoneNumber': user.phoneNumber,
          'feedback': user.feedback,
          'uid':user.uid,
          'UserType':user.UserType
        }).then((value) {
          _firestore.collection("feedBack").document(value.documentID).setData(
              {
                "feedbackId":value.documentID,

              },merge : true).then((_){

            print("success!" + value.documentID);
          });


        });
        retVal='Success';
        print("success new feedback added in firebase!");
      }

    }
    catch (e) {
      print(e.toString() +"Error");
    }
    // return retVal;
  }


  Future updateAgentProfile(AgentUser agentUser)async{
    String retVal = 'error';
    try {
    agentUser.SearchindexList = await convertToIndex(agentUser.city);
    print(agentUser.SearchindexList.toString());

    await _firestore.collection("users").document(agentUser.uid).updateData({
      "displayName": agentUser.Name,
      "age": agentUser.age,
      'phoneNumber': agentUser.phoneNumber,
      "address": agentUser.address,
      "description":agentUser.description,
      "city":agentUser.city,
      'Location':agentUser.location,
      'image': agentUser.image,



    });
    retVal='Success';
    print("success updated");
    }
    catch (e) {
      print(e.toString() +"Error");
    }
    // return retVal;
  }


  Future<AgentUser> getUserInfo(String uid) async{
    AgentUser retVal = AgentUser();
    try {
      DocumentSnapshot _docSnapshot =
      await _firestore.collection("agentRequest").document(uid).get();
      retVal.uid = uid;
      retVal.Name = _docSnapshot.data["firstName"];
    //  retVal.email = _docSnapshot.data['email'];
      retVal.phoneNumber = _docSnapshot.data['phoneNumber'];
      retVal.accountCreated = _docSnapshot.data["accountCreated"];
      retVal.UserType = _docSnapshot.data["UserType"];
    } catch (e) {
      print(e);
    }
    return retVal;
  }


}