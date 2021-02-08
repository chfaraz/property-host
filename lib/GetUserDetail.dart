import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signup/helper/helperfunctions.dart';
import 'package:signup/home.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/models/user.dart';
import 'package:signup/services/database.dart';
import 'package:signup/states/currentUser.dart';
import 'package:signup/widgets/otp_screen.dart';

//import 'package:property_host_system/http_exception.dart';
import './AppLogic/validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
class UserDetail extends StatefulWidget  {

  final String  mobileNumber;

  const UserDetail({Key key, this.mobileNumber}) : super(key: key);
  @override
  _UserDetail createState() => _UserDetail(this.mobileNumber);
}

class _UserDetail extends State<UserDetail> with WidgetsBindingObserver{
 final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  var _isLoading = false;
  String mobileNumber="";
  OurUser Ouruser= new OurUser();
  OurUser checkUser = new OurUser();
  FirebaseUser user;
  _UserDetail(this.mobileNumber);

  @override
  void initState(){
    super.initState();
    print(widget.mobileNumber);
    initUser();
  WidgetsBinding.instance.addObserver(this);
    //getCurrentUser();
  }
 @override
 void dispose() {
   // TODO: implement dispose
   super.dispose();
  WidgetsBinding.instance.removeObserver(this);
 }


 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
   if (state == AppLifecycleState.resumed) {
     print("app is resumed back");
   }
 }

  initUser() async{
    user = await _auth.currentUser();
    checkUser=   await OurDatabase().getUserInfo(user.uid);
    if (user != null) {
      print("${user.uid} + ${checkUser.uid}");
    } else {
      print("user.uid");
      // User is not available. Do something else
    }
    setState(() {});
  }
 Future<bool> _onBackPressed() {
   return showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text('Please Complete the profile before going back'),
           content: Text('Are you sure to Go back?'),
           actions: <Widget>[
             FlatButton(
               child: Text('NO'),
               onPressed: () {
                 Navigator.of(context).pop(false);
               },
             ),
             FlatButton(
               child: Text('YES'),
               onPressed: () {
                 Navigator. pushReplacement(
                   context,
                   MaterialPageRoute(
                     builder: (context) => OTPScreen(mobileNumber: widget.mobileNumber,),
                   ),
                 );
               },
             ),
           ],
         );
       });
 }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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

  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _Address = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _role = TextEditingController();
  String _FName, Address, _phoneNumber, _email, _password,_confirmPassword;


//    catch (error) {
//      // const errorMessage =
//      //   'Could not authenticate you. Please try again later.';
//      //_showErrorDialog(errorMessage);
//      _showErrorDialog(Errors.show(error.code));
//    }
//      if (_returnString == "success") {
//        Navigator.pop(context);
//      } else {
//        Scaffold.of(context).showSnackBar(
//          SnackBar(
//            content: Text(_returnString),
//            duration: Duration(seconds: 2),
//          ),
//        );
//      }

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Text(
            'Property Host',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _key,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              child: TextFormField(
                controller: _firstName,
                keyboardType: TextInputType.text,
                validator: validateName,
                maxLength: 14,
                onSaved: (String val){
                  _FName = val;
                  print(_FName);
                },

                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.grey[800],
                    ),
                    labelText: 'Enter Full Name'),
              ),

            ),
         /*   TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              validator:validateMobile,
              onSaved: (String val){
                _phoneNumber = val;
                print(_phoneNumber);
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.grey[800],
                  ),
                  labelText: 'Phone No'),
            ),
             TextFormField(
              controller: _Address,
              keyboardType: TextInputType.emailAddress,
              validator:validateName,
              onSaved: (String val){
                Address = val;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.grey[800],
                ),
                labelText: 'Address',
              ),
            ),*/
          /*  TextFormField(
              controller: _emailAddress,
              keyboardType: TextInputType.emailAddress,
              validator:validateEmail,
              onSaved: (String val){
                _email = val;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.grey[800],
                ),
                labelText: 'Email',
              ),
            ),*/
          /*  TextFormField(
              controller: _passwordTextController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey[800],
                ),
                labelText: 'Password',
              ),
              obscureText: true,
              // ignore: missing_return
              validator: (String value) {
                if (value.isEmpty || value.length < 6) {
                  return 'Password invalid';
                }
              },
              onSaved: (String value) {
                _password = value;
              },
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey[800],
                ),
                labelText: 'Confirm Password',
              ),
              obscureText: true,
              // ignore: missing_return
              validator: (String value) {
                if (_passwordTextController.text != value) {
                  return 'Passwords do not match.';
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }
//  Widget _buildLoginBtn() {
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Padding(
//          padding: EdgeInsets.only(top: 2),
//          child: FlatButton(
//            onPressed: () {
//              Navigator.pushNamed(context, '/LoginScreen');
//            },
//            child: RichText(
//              text: TextSpan(children: [
//                TextSpan(
//                  text: 'Switch back to? ',
//                  style: TextStyle(
//                    color: Colors.white,
//                    fontSize: MediaQuery
//                        .of(context)
//                        .size
//                        .height / 40,
//                    fontWeight: FontWeight.w400,
//                  ),
//                ),
//                TextSpan(
//                  text: 'Login In',
//                  style: TextStyle(
//                    color: Colors.grey[300],
//                    fontSize: MediaQuery
//                        .of(context)
//                        .size
//                        .height / 35,
//                    fontWeight: FontWeight.bold,
//                  ),
//                )
//              ]),
//            ),
//          ),
//        ),
//      ],
//    );
//  }

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

  Widget _buildSignUpButton() {
    return Builder(
      builder: (BuildContext context) {
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
              margin: EdgeInsets.only(top: 40),
              child: RaisedButton(
                //elevation: 5.0,
                color: Color(0xff2196F3),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),

                onPressed: () async{
                  _sendToServer();

                  await HelperFunctions.saveUserNameSharedPreference(_FName);
                  await HelperFunctions.saveUserIdSharedPreference(user.uid);
                  Ouruser.displayName = _FName;
                  Ouruser.uid = user.uid;
                  Ouruser.phoneNumber = widget.mobileNumber;
                  Ouruser.block = false;
                         String retString =  await  OurDatabase().updateUser(Ouruser);
                         if(retString =='Success'){
                           Navigator.pushAndRemoveUntil(
                             context,
                             MaterialPageRoute(
                                 builder: (context) => RoleCheck()),
                                 (route) => false,
                           );
                           }
                         },

//              catch(e)
//              {
//                print(e);
//              }

//              if (_key.currentState.validate()) {
//                // No any error in validation
//                _key.currentState.save();
//                print("Name $FName");
//                print("Mobile $phoneNumber");
//                print("Email $LName");
//              } else {
//                // validation error
//                setState(() {
//                  _validate = true;
//                });
//              }


                child: Text(
                  "Continue",
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
  },
    );
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
              margin: EdgeInsets.only(bottom: 20),
              //padding: EdgeInsets.only(bottom: 0),
              height: MediaQuery.of(context).size.height/2,

              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSignUpForm(),
                  _buildSignUpButton(),
                ],
              ),
            ),
          ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomPadding: false,
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xff1E364C),

          body:SingleChildScrollView(
            child: Stack(
              children: <Widget>[
            Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff1E364C),
              ),
            ),
          ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogo(),
                    _buildContainer(),
                 //   _buildLoginBtn(),
                  ],

              )
              ],
            ),
          ),
        ),
      ),

    );
  }
}
