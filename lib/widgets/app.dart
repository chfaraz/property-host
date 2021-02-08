import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:signup/signup.dart';

//import 'package:signup/widgets/auth.dart';
//import 'package:signup/widgets/home.dart';
//import 'package:signup/widgets/phone_auth.dart';
import 'package:signup/main_screen.dart';
class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    FirebaseUser _user = await _firebaseAuth.currentUser();
    setState(() {
      user = _user;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: user != null
            ? MainScreen(

          isAgent: false,
              )
            : MainScreen(
          isAgent: false,
        ));
  }
}
