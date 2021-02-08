import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup/MainScreenUsers.dart';
import 'package:signup/agentSignup.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/signup.dart';
import 'package:signup/userProfile.dart';

import 'helper/helperfunctions.dart';

class RoleCheckThree extends StatefulWidget {
  @override
  _RoleCheckThreeState createState() => _RoleCheckThreeState();
}

class _RoleCheckThreeState extends State<RoleCheckThree> {
  //RoleCheck(this.isAdmin);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //bool isAgent = false;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(title: Text('Home ${user.email}'),),

      body: user != null
          ? Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
//                HelperFunctions.saveUserLoggedInSharedPreference(true);
//                HelperFunctions.saveUserNameSharedPreference(
//                    snapshot.data["displayName"]);
//                HelperFunctions.saveUserEmailSharedPreference(
//                    snapshot.data["email"]);
//                HelperFunctions.saveUserPhoneNoSharedPreference(
//                    snapshot.data["phoneNumber"]);

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.hasError}');
                }

                print(user.uid);

                return snapshot.hasData
                    ? _checkRole(snapshot.data)
                    : Text('No Data');
              }))
          : Center(child: Text("Error")),
    );
  }

  _checkRole(DocumentSnapshot snapshot) {
    if (snapshot.data['User Type'] == 'Agent') {
      //isAdmin =true;
      print('agent');
      //MainScreen(isAdmin: true,);
      return AgentSignUp(
        isAgent: true,
      );
      //return MainScreen(isAdmin);

    } else {
      //isAdmin= false;
      print('other');
      //return MainScreen();
      return AgentSignUp(
        isAgent: false,
      );
    }
  }
}
