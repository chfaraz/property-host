import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:signup/GetUserDetail.dart';
import 'package:signup/helper/constants.dart';
import 'package:signup/helper/helperfunctions.dart';
import 'package:signup/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/models/user.dart';
import 'package:signup/services/database.dart';
//import 'package:universal_html/html.dart';
//import 'package:signup/widgets/home.dart';

import './otp_input.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  OTPScreen({Key key, @required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static const _timerDuration = 60;
  StreamController _timerStream = new StreamController<int>();
  int timerCounter;
  Timer _resendCodeTimer;
  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =   UnderlineDecoration(enteredColor: Colors.black, hintText: '333333');


  bool isCodeSent = false;
  String _verificationId;
  OurUser Ouruser = new OurUser();

  int _resendToken;


  @override
  void initState() {
    activeCounter();

    super.initState();
    _onVerifyCode();

  }
  dispose(){
    _timerStream.close();
    _resendCodeTimer.cancel();

    super.dispose();
  }
  activeCounter(){
    _resendCodeTimer =
    new Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0)
        _timerStream.sink.add(_timerDuration - timer.tick);
      else {
        _timerStream.sink.add(0);
        _resendCodeTimer.cancel();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    print("isValid - $isCodeSent");
    print("mobile ${widget.mobileNumber}");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          child: Container(
            padding: EdgeInsets.only(left: 16.0, bottom: 16, top: 4),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Verify Details",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "OTP sent to ${widget.mobileNumber}",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          preferredSize: Size.fromHeight(100),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PinInputTextField(
                pinLength: 6,
                decoration: _pinDecoration,
                controller: _pinEditingController,
                autoFocus: true,
                textInputAction: TextInputAction.done,
                onSubmit: (pin) {
                  if (pin.length == 6) {
                    _onFormSubmitted();
                  } else {
                    showToast("Invalid OTP", Colors.red);
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    child: Text(
                      "ENTER OTP",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_pinEditingController.text.length == 6) {
                        _onFormSubmitted();
                      } else {
                        showToast("Invalid OTP", Colors.red);
                      }
                    },
                    padding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
            sendCodeAgain(),
          ],
        ),
      ),
    );
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential).then((AuthResult value) async {
        if (value.user != null) {
          // Handle loogged in state
          print(value.user.phoneNumber + "in phone verfy complete method");
          bool check  = await OurDatabase().checkUser(value.user.uid);
          if(check==true){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RoleCheck(),
                ),
                    (Route<dynamic> route) => false);

          }
          else {
            Ouruser.uid = value.user.uid;
            Ouruser.phoneNumber = widget.mobileNumber;
            Ouruser.block = false;
            String retString = await OurDatabase().createUser(Ouruser);
            if (retString == 'Success') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserDetail(
                          mobileNumber: widget.mobileNumber,

                        ),
                  ),
                      (Route<dynamic> route) => false);
            } else {
              showToast("Account not created", Colors.blueGrey);
            }
          }
        }
        else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((error) {
        showToast("Try again in sometime", Colors.red);
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      // showToast(authException.message +" on verifcation failed", Colors.red);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
      //  showToast("Message sent", Colors.green);
      _verificationId = verificationId;
      print(_verificationId);
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    // TODO: Change country code

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: widget.mobileNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        forceResendingToken: _resendToken,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {

    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    _firebaseAuth.signInWithCredential(_authCredential).then((AuthResult value) async {
      print(value.user.phoneNumber +"it is in signIn on submit method");
      if (value.user != null) {
        HelperFunctions.saveUserPhoneNoSharedPreference(widget.mobileNumber);
        print("it is inside if and user is not null");

        // Handle loogged in state

        bool check  = await OurDatabase().checkUser(value.user.uid);
        print(check);
        if(check ==true){

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RoleCheck(),
              ),
                  (Route<dynamic> route) => false);

        }
        else {
          Ouruser.uid = value.user.uid;
          Ouruser.phoneNumber = widget.mobileNumber;
          Ouruser.block = false;
          String retString = await OurDatabase().createUser(Ouruser);
          if (retString == 'Success') {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserDetail(
                        mobileNumber: widget.mobileNumber,

                      ),
                ),
                    (Route<dynamic> route) => false);
          } else {
            showToast("Account not created", Colors.blueGrey);
          }
        }  // else of check if condition
      } else {
        showToast("Error validating OTP, try again", Colors.red);
      }
    }).catchError((error) {
      showToast("Error validating OTP, try again",Colors.red);
    });

  }
  Widget sendCodeAgain(){
    return StreamBuilder(
      stream: _timerStream.stream,
      builder: (BuildContext ctx,
          AsyncSnapshot snapshot) {
        return Container(

          width: MediaQuery.of(context).size.width/1.80,
          child: RaisedButton(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  9.0),
//                                                side: BorderSide(
//                                                    color: Colors.pink[500],
//                                                    width: 1.5
              //      )
            ),
            textColor: Theme.of(context)
                .accentColor,

            child: snapshot.data == 0 ?

            Center(
              child: Text('Resend Code',style: TextStyle(fontFamily: "Poppins"
                ,
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),),
            )
                :
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(' Resend Code : ${snapshot.hasData
                    ? snapshot.data.toString() : 60} s ',style:
                TextStyle(fontFamily: "Poppins"
                  ,fontWeight: FontWeight.w700,fontSize: 15,     color:
                  Colors.white,),)
              ],),
//
            onPressed: snapshot.data == 0 ? () {
              // your sending code method
              _onVerifyCode();

              _timerStream.sink.add(30);
              activeCounter();
            } : null,
          ),
        );
      },
    );
  }
}
