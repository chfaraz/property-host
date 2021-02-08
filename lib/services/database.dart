import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import 'package:signup/models/user.dart';

class OurDatabase{
  String data = "https://thumbs.dreamstime.com/b/user-profile-avatar-icon-134114292.jpg";
  final Firestore _firestore = Firestore.instance;
  Future<String> createUser(OurUser user) async{
    String retVal ='error';
    try{
      await _firestore.collection('users').document(user.uid).setData({
        'displayName' : user.displayName,
        'phoneNumber' : user.phoneNumber,
        'uid':user.uid,
        'Block':user.block,
        'avatarUrl':data,
        'UserType' : "user",
        'accountCreated' : Timestamp.now(),

      });
      print("success new user added in firebase!");
      retVal='Success';
    }
    catch(e)
    {
      print(e);
    }
    return retVal;
  }

  Future<String> updateUser(OurUser user) async{
    //var addUserData = Map<String,dynamic>();
    String retVal ='error';
    try{
      await _firestore.collection('users').document(user.uid).updateData({
        'displayName' : user.displayName,
        'phoneNumber' : user.phoneNumber,
        'uid':user.uid,
        'Block':user.block,
        'avatarUrl':data,
        'UserType' : "user",
        'accountCreated' : Timestamp.now(),

      });
      print("success new user updated in firebase!");
      retVal='Success';
    }
    catch(e)
    {
      print(e);
    }
    return retVal;
  }

  Future<bool> checkUser(String uid) async{
    DocumentSnapshot _docSnapshot =  await _firestore.collection("users").document(uid).get();
    if(_docSnapshot.data !=null){
      return true;
    }
    else{
      return false;
    }


  }

  Future<OurUser> getUserInfo(String uid) async{
    OurUser retVal = OurUser();
    try{
      //DocumentSnapshot _docSnapshot = await _firestore.collection("users").document(uid).get();
      DocumentSnapshot _docSnapshot = await _firestore.collection("users").document(uid).get();
      retVal.uid = uid;
      //retVal.firstName= _docSnapshot.data('firstName');
      retVal.displayName = _docSnapshot.data["displayName"];
      //retVal.lastName = _docSnapshot.data["lastName"];
      retVal.email= _docSnapshot.data['email'];
      retVal.phoneNumber= _docSnapshot.data['phoneNumber'];
      retVal.accountCreated = _docSnapshot.data["accountCreated"];
      retVal.UserType = _docSnapshot.data["UserType"];
      //retVal.isAdmin = _docSnapshot.data["isAdmin"];
    }
    catch(e)
    {
      print(e);
    }
    return retVal;
  }


}