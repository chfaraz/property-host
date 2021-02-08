import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup/MainScreenUsers.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/signup.dart';
import 'package:signup/errors/accountBlock.dart';

import 'helper/helperfunctions.dart';

class RoleCheck extends StatefulWidget {
  @override
  _RoleCheckState createState() => _RoleCheckState();
}

class _RoleCheckState extends State<RoleCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    initUser();
  }

  String userid;
  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

//
//  initUser() async {
//    user = await _auth.currentUser();
//    if (user != null) {
//      userid = user.uid;
//   //   print(widget.isAgent);
//    } else {
//      print("user.uid");
//      // User is not available. Do something else
//    }
//    setState(() {
//
//    });
//  }
  @override
  Widget build(BuildContext context) {
    return user != null
        ? Scaffold(
//        appBar: AppBar(title: Text('Home ${user.email}'),),

            body: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
                // ignore: missing_return
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError)
                    return Center(
                      child: Text("Something went wrong  please come back later"),
                    );

                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Center(child: Text("Please check your internet"));
                      break;
                    case ConnectionState.waiting:
                      return Center(
                        child: Text("Loading Main Screen"),
                      );
                      break;
                    default:
                      HelperFunctions.saveUserLoggedInSharedPreference(true);
                      HelperFunctions.saveUserNameSharedPreference(snapshot.data["displayName"]);
                      HelperFunctions.saveUserPhoneNoSharedPreference(snapshot.data["phoneNumber"]);
                      HelperFunctions.saveUserPhoneNoSharedPreference(snapshot.data["uid"]);
                      return _checkRole(snapshot.data);
                      break;
                  }
                }))
        : SignUpPage();
  }

  _checkRole(DocumentSnapshot snapshot) {
    if (snapshot.data['Block'] == false) {
      if (snapshot.data['UserType'] == 'Agent') {
        return MainScreen(
          isAgent: true,
        );
      } else {
        return MainScreen(
          isAgent: false,
        );
      }
    } else {
      print("You account is temporary blocked");
      return AccountBlock();
    }
  }
}
