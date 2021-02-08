import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signup/root/root.dart';
import 'package:signup/states/currentUser.dart';

class MainScreenUsers extends StatelessWidget {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//  signOut() async {
//    await _firebaseAuth.signOut();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Property Host'),
        centerTitle: true,
        actions: <Widget>[
          Row(
            children: [
              Text('SignOut'),
              IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () async {
                    //signOut();
                    // Navigator.pushNamed(context, '/LoginScreen');
                    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
                    String _returnString = await _currentUser.signOut();
//                  CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
//                  String _returnString = await _currentUser.signOut();
                    if (_returnString == 'Success') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => OurRoot()),
                        (route) => false,
                      );
                      //Navigator.pushNamed(context, '/LoginScreen');
//                  }
//                  //Navigator.pushNamed(context, '/LoginScreen');
                    }
                  }),
            ],
          ),
        ],
        backgroundColor: Colors.grey[800],
        elevation: 0.0,
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[500],
        ),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 90.0,
                child: DrawerHeader(
                  child: Center(
                      child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.grey[200], fontSize: 25.0),
                  )),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                  ),
                ),
              ),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Post an Ad',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/PostAdd');
                  },
                ),
              ),
              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'My Profile',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/MyProfile');
                  },
                ),
              ),
              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Agent',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/AgentsList');
                  },
                ),
              ),
              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Your Ads',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/AdsList');
                  },
                ),
              ),
              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Live Notification',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/LiveNotification');
                  },
                ),
              ),
              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Advertise',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/Advertise');
                  },
                ),
              ),
              SizedBox(height: 1.0),
//              Container(
//                color: Colors.grey[800],
//                child: ListTile(
//                  title: Text(
//                    'Sign up as Agent',
//                    style: TextStyle(color: Colors.grey[200]),
//                  ),
//                  onTap: () {
//                    Navigator.pushNamed(context, '/AgentSignup');
//                  },
//                ),
//              ),
//              SizedBox(height: 1.0),
              Container(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 1.90,
                width: 360.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Find Your Dream Home With Property Host',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[350],
                          fontWeight: FontWeight.w900,
                          fontSize: 30.0,
                        ),
                      ),
                      SizedBox(height: 60.0),
                      TextField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                          letterSpacing: 2.0,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[700], width: 3.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[100], width: 2.0),
                          ),
                          hintText: 'Enter Address, City or Zip Code',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0), side: BorderSide(color: Colors.pink[500], width: 2.0)),
                          onPressed: () {
                            Navigator.pushNamed(context, '/SearchResult');
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          label: Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
