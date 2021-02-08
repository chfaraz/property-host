import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AppLogic/validation.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();

}

class _ForgetPasswordState extends State<ForgetPassword> {
  String email='';
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  final _auth = FirebaseAuth.instance;
  _sendToServer(){
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();


    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text('Property Host'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/LoginScreen');
            },
          )
        ],
        backgroundColor: Colors.grey[800],
        elevation: 10.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 50, 50, 0),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //Text('We will email you a link'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        "Forget Password",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _key,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(50, 100, 50, 50),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          //   controller: passwordController,
                          keyboardType: TextInputType.emailAddress,
                          validator:validateEmail,
                          onSaved: (String val){
                             email = val;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[800],
                            ),
                            labelText: 'Email',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                RaisedButton(
                  elevation: 5.0,
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.grey[600], width: 2.0)),
//                  onPressed: () {
    onPressed: () async {
    try {
    _sendToServer();
    final user = await _auth.sendPasswordResetEmail(
    email: email,);

    Navigator.pushNamed(context, '/LoginScreen');

    }
    catch (e) {
    print(e);
    }

//                  _sendToServer();
//                  try{
//                    FirebaseAuth.instance.sendPasswordResetEmail(email: email,).then((value) => print("Check your Mail"));
//                      Navigator.pushNamed(context, '/LoginScreen');
//                  }
//                  catch(e)
//                  {
//                    print(e);
//                  }
                  },
                  child: Text(
                    'Receive Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  color: Colors.grey[800],
                )
              ],
            ),
          ),
        ),
      ),
    );


  }

}
