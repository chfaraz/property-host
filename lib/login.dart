import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signup/home.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/states/currentUser.dart';
import 'package:signup/widgets/otp_screen.dart';

import './AppLogic/validation.dart';

enum LoginType{
  email,
  google,
  PhoneNo,
}
class LoginPage extends StatefulWidget {
  final AuthResult authResult;
  LoginPage({Key key, @required this.authResult}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthResult authResult;
  String password, _email;
  var _isLoading = false;
  final formKeyEmail = GlobalKey<FormState>();
  final formKeyPasw = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  void _loginUser({@required LoginType type, String email, String password, BuildContext context,}) async {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    _sendToServer();
    try {
      String _returnString;
      switch (type) {
        case LoginType.email:
          _returnString = await _currentUser.loginUserWithEmail(email, password, context);
          break;
        case LoginType.google:
        //  _returnString = await _currentUser.loginUserWithGoogle();
          break;
        case LoginType.PhoneNo:
          _returnString ="" ;
          break;
        default:
      }
      if (_returnString == 'Success') {
        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(
          builder: (context) => RoleCheck(),
        ),
              (route) => false,);
      }
//      if(_returnString == 'Success') {
//
//
//        Navigator.of(context).push(
//          MaterialPageRoute(builder: (context) => MainScreen(),),);
//      }
      else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(_returnString),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    catch (e) {
      print(e);
    }
  }

  Widget _googleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        _loginUser(type: LoginType.google, context: context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           // Image(image: AssetImage("assets/google_logo.png"), height: 25.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Number',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'Property Host',
              style: TextStyle(
                fontSize: MediaQuery
                    .of(context)
                    .size
                    .height / 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      );
    }
    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
      );
    }

    Widget _buildLoginRows() {
      return Form(
        key: _key,
        autovalidate: _validate,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
//            TextFormField(
//              keyboardType: TextInputType.phone,
//              maxLength: 11,
//              validator:validateMobile,
//              onSaved: (String val){
//                phoneNumber = val;
//              },
//              controller: phoneController,
//              decoration: InputDecoration(
//                  prefixIcon: Icon(
//                    Icons.phone,
//                    color: Colors.grey[800],
//                  ),
//                  labelText: 'Phone No'),
//            ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text,
                validator: validateEmail,
                onSaved: (String val) {
                  _email = val;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey[800],
                  ),
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                validator: validatePassword,
                onSaved: (String val) {
                  password = val;
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey[800],
                  ),
                  labelText: 'Password',
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildForgetPasswordButton() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, '/ForgetPassword');
            },
            child: Text("Forgot Password"),
          ),
        ],
      );
    }

    Widget _buildLoginButton() {
      return Builder(
        builder: (BuildContext context){
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 1.4 * (MediaQuery
                    .of(context)
                    .size
                    .height / 25),
                width: 5 * (MediaQuery
                    .of(context)
                    .size
                    .width / 10),
                margin: EdgeInsets.only(bottom: 20),
                child: RaisedButton(
                  elevation: 5.0,
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    _loginUser(
                        type: LoginType.email, email: emailController.text, password: passwordController.text, context: context);
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height / 40,
                    ),
                  ),
                ),
              )
            ],
          );
        }

      );
    }

    _sendToServer() {
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

    Widget _buildContainer() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.7,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height / 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  //_buildEmailRow(),
                  _buildLoginRows(),
                  _buildForgetPasswordButton(),
                  _buildLoginButton(),
                  _googleButton(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildSignUpBtn() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Signup');
              },
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Dont have an account? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height / 40,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .height / 35,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ]),
              ),
            ),
          ),
        ],
      );
    }

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomPadding: false,
          backgroundColor: Color(0xfff2f3f7),
          body: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 1.0,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildLogo(),
                  _buildContainer(),
                  _buildSignUpBtn(),
                ],
              ),
            ],
          ),
        ),
      );

    }

  }

