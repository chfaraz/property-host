import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signup/Arguments.dart';
import 'package:signup/ImageCarousel.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/states/currentUser.dart';

class ViewAdds extends StatefulWidget {
  final bool isAdmin;

  const ViewAdds({Key key, this.isAdmin}) : super(key: key);
  @override
  _ViewAddsState createState() => _ViewAddsState(this.isAdmin);
}

class _ViewAddsState extends State<ViewAdds> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAdmin = true;
  AdPost adPost = new AdPost();

  String data;
  _ViewAddsState(this.isAdmin);

  //bool isAdmin = false;

  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    print(user.email);
    setState(() {

    });
  }

//  Stream<DocumentSnapshot> provideDocumentFieldStream() {
//    return Firestore.instance
//        .collection('users').document("6ztvDsMZl4TiYeTjXcYLlNy0YhX2")
//        .snapshots();
//  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Color(0xff453658),
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp
              ),
            ),
          ),
          title: Text("Your Ads"),
          centerTitle: true,
        ),
        body: user!= null ? ListView(
          padding: EdgeInsets.only(left: 20.0),
          // Padding: EdgeInsets.only(left: 20.0),
          children: [
            SizedBox(height: 15.0),
            Text('Categories',
                style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15.0),
            TabBar
              (
                controller: _tabController,
                indicatorColor: Colors.transparent,
                labelColor: Color(0xFFC88D67),
                isScrollable: true,
                labelPadding: EdgeInsets.only(right: 45.0),
                unselectedLabelColor: Color(0xFFCDCDCD),
                tabs: [
                  Tab(
                    child: Text('Plots',
                        style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 21.0,
                        )),
                  ),
                  Tab(
                    child: Text('Houses',
                        style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 21.0,
                        )),
                  ),
                  Tab(
                    child: Text('Commercial',
                        style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 21.0,
                        )),
                  )
                ]),
            Container(
              height: MediaQuery.of(context).size.height/1.5,
              width: double.infinity,
              child: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
//          decoration: BoxDecoration(
//              gradient: LinearGradient(
//                  colors: [
//                    const Color(0xff213A50),
//                    const Color(0xff071930)
//                  ],
//                  begin: FractionalOffset.topRight,
//                  end: FractionalOffset.bottomLeft)),
                      decoration: BoxDecoration(
                        //        border: Border.all(color: Colors.blueAccent,width:0.1,)
                        //borderRadius: BorderRadius.circular(75.0),
                      ),
                      child: StreamBuilder(
                        stream: Firestore.instance.collection('PostAdd').where("uid", isEqualTo: user.uid).where("PropertyType",isEqualTo: 'Plots').snapshots(),

                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {

                            return Container(

                              decoration: BoxDecoration(
                                //        border: Border.all(color: Colors.blueAccent,width: 100.0,)

                              ),
                              padding: EdgeInsets.all(12),
                              child:
                              GridView.builder(
                                shrinkWrap: true,

                                //physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
//                                childAspectRatio: 1.0,
//                                //Padding: EdgeInsets.only(left: 16, right: 16),
//                                crossAxisCount: 2,
//                                crossAxisSpacing: 18,
//                                mainAxisSpacing: 18,
                                  crossAxisCount: 2,
                                  // primary: false,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 15.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: snapshot.data.documents.length,

                                // ignore: missing_return
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(

                                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
                                    child: Card(
                                      color: Colors.transparent,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: GridTile(
                                          child: GestureDetector(
                                            onTap: () {
                                              adPost.postId =snapshot.data.documents[index].documentID.toString();
                                              adPost.userId=snapshot.data.documents[index].data['uid'].toString();
                                              adPost.price = int.parse(snapshot.data.documents[index].data['Price'].toString());

                                              Navigator.of(context).pushNamed(
                                                  ImageCarousel.routeName,
                                                  arguments: ScreenArguments(adPost)
                                              );
                                            },
                                            child: Image.network(

                                              snapshot.data.documents[index].data['ImageUrls'][0],
                                              //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                              loadingBuilder: (BuildContext context, Widget child,
                                                  ImageChunkEvent loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                              fit: BoxFit.cover,
                                            ),
//                              Image.network(
//                                snapshot.data.documents[index].data['Image Urls'][0],
//                                fit: BoxFit.cover,
//                              ),
                                          ),
                                          footer: Container(
                                            decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(15.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      spreadRadius: 3.0,
                                                      blurRadius: 5.0)
                                                ],
                                                gradient: LinearGradient(
                                                    colors: [Colors.white30, Colors.white],
                                                    begin: FractionalOffset.centerRight,
                                                    end: FractionalOffset.centerLeft)),
                                            child: GridTileBar(
                                              // backgroundColor: Colors.black87,

//                          leading: IconButton(
//                            icon: Icon(Icons.favorite),
//                            color: Theme.of(context).accentColor,
//                            onPressed: () {},
//                          ),
                                              title: Text(
                                                snapshot.data.documents[index].data['Title'].toString().toUpperCase(),
                                                textAlign: TextAlign.center,style: TextStyle(  fontSize: 13,
                                                  color: Colors.black54,fontFamily: 'Overpass'),
                                                //style: TextStyle(fontStyle: F),
                                              ),
//                          trailing: IconButton(
//                            icon: Icon(
//                              Icons.shopping_cart,
//                            ),
//                            onPressed: () {},
//                            color: Theme.of(context).accentColor,
//                          ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return Center(child:CircularProgressIndicator());
//              return Center(
//                child: Text('Loading...'),
//              );
                          }
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
//          decoration: BoxDecoration(
//              gradient: LinearGradient(
//                  colors: [
//                    const Color(0xff213A50),
//                    const Color(0xff071930)
//                  ],
//                  begin: FractionalOffset.topRight,
//                  end: FractionalOffset.bottomLeft)),
                      decoration: BoxDecoration(
                        //        border: Border.all(color: Colors.blueAccent,width:0.1,)
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: StreamBuilder(
                        stream: Firestore.instance.collection('PostAdd').where("uid", isEqualTo: user.uid).where("PropertyType",isEqualTo: 'Homes').snapshots(),

                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {

                            return Container(

                              decoration: BoxDecoration(
                                //        border: Border.all(color: Colors.blueAccent,width: 100.0,)

                              ),
                              padding: EdgeInsets.all(12),
                              child:
                              GridView.builder(
                                shrinkWrap: true,

                                //physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
//                                childAspectRatio: 1.0,
//                                //Padding: EdgeInsets.only(left: 16, right: 16),
//                                crossAxisCount: 2,
//                                crossAxisSpacing: 18,
//                                mainAxisSpacing: 18,
                                  crossAxisCount: 2,
                                  // primary: false,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 15.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: snapshot.data.documents.length,

                                // ignore: missing_return
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(

                                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
                                    child: Card(
                                      color: Colors.transparent,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: GridTile(
                                          child: GestureDetector(
                                            onTap: () {
                                              adPost.postId = snapshot.data.documents[index].documentID.toString();
                                              adPost.userId = snapshot.data.documents[index].data['uid'].toString();
                                              adPost.price = int.parse(snapshot.data.documents[index].data['Price'].toString());
                                              Navigator.pop(context);
                                              Navigator.of(context).pushNamed(
                                                  ImageCarousel.routeName,
                                                  arguments: ScreenArguments(adPost)
                                              );
                                            },
                                            child: Image.network(

                                              snapshot.data.documents[index].data['ImageUrls'][0],
                                              //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                              loadingBuilder: (BuildContext context, Widget child,
                                                  ImageChunkEvent loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                              fit: BoxFit.cover,
                                            ),
//                              Image.network(
//                                snapshot.data.documents[index].data['Image Urls'][0],
//                                fit: BoxFit.cover,
//                              ),
                                          ),
                                          footer: Container(
                                            decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(15.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      spreadRadius: 3.0,
                                                      blurRadius: 5.0)
                                                ],
                                                gradient: LinearGradient(
                                                    colors: [Colors.white30, Colors.white],
                                                    begin: FractionalOffset.centerRight,
                                                    end: FractionalOffset.centerLeft)),
                                            child: GridTileBar(
                                              // backgroundColor: Colors.black87,

//                          leading: IconButton(
//                            icon: Icon(Icons.favorite),
//                            color: Theme.of(context).accentColor,
//                            onPressed: () {},
//                          ),
                                              title: Text(
                                                snapshot.data.documents[index].data['Title'].toString().toUpperCase(),
                                                textAlign: TextAlign.center,style: TextStyle(  fontSize: 13,
                                                  color: Colors.black54,fontFamily: 'Overpass'),
                                                //style: TextStyle(fontStyle: F),
                                              ),
//                          trailing: IconButton(
//                            icon: Icon(
//                              Icons.shopping_cart,
//                            ),
//                            onPressed: () {},
//                            color: Theme.of(context).accentColor,
//                          ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return Center(child:CircularProgressIndicator());
//              return Center(
//                child: Text('Loading...'),
//              );
                          }
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
//          decoration: BoxDecoration(
//              gradient: LinearGradient(
//                  colors: [
//                    const Color(0xff213A50),
//                    const Color(0xff071930)
//                  ],
//                  begin: FractionalOffset.topRight,
//                  end: FractionalOffset.bottomLeft)),
                      decoration: BoxDecoration(
                        //        border: Border.all(color: Colors.blueAccent,width:0.1,)
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: StreamBuilder(
                        stream: Firestore.instance.collection('PostAdd').where("uid", isEqualTo: user.uid).where("PropertyType",isEqualTo: 'Commercial').snapshots(),

                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {

                            return Container(

                              decoration: BoxDecoration(
                                //        border: Border.all(color: Colors.blueAccent,width: 100.0,)

                              ),
                              padding: EdgeInsets.all(12),
                              child:
                              GridView.builder(
                                shrinkWrap: true,

                                //physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
//                                childAspectRatio: 1.0,
//                                //Padding: EdgeInsets.only(left: 16, right: 16),
//                                crossAxisCount: 2,
//                                crossAxisSpacing: 18,
//                                mainAxisSpacing: 18,
                                  crossAxisCount: 2,
                                  // primary: false,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 15.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: snapshot.data.documents.length,

                                // ignore: missing_return
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(

                                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
                                    child: Card(
                                      color: Colors.transparent,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: GridTile(
                                          child: GestureDetector(
                                            onTap: () {
                                              adPost.postId = snapshot.data.documents[index].documentID.toString();
                                              adPost.userId = snapshot.data.documents[index].data['uid'].toString();
                                              adPost.price = int.parse(snapshot.data.documents[index].data['Price'].toString());

                                              Navigator.of(context).pushNamed(
                                                  ImageCarousel.routeName,
                                                  arguments: ScreenArguments(adPost)
                                              );
                                            },
                                            child: Image.network(

                                              snapshot.data.documents[index].data['ImageUrls'][0],
                                              //'https://previews.123rf.com/images/blueringmedia/blueringmedia1701/blueringmedia170100692/69125003-colorful-kite-flying-in-blue-sky-illustration.jpg',
                                              loadingBuilder: (BuildContext context, Widget child,
                                                  ImageChunkEvent loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                              fit: BoxFit.cover,
                                            ),
//                              Image.network(
//                                snapshot.data.documents[index].data['Image Urls'][0],
//                                fit: BoxFit.cover,
//                              ),
                                          ),
                                          footer: Container(
                                            decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(15.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      spreadRadius: 3.0,
                                                      blurRadius: 5.0)
                                                ],
                                                gradient: LinearGradient(
                                                    colors: [Colors.white30, Colors.white],
                                                    begin: FractionalOffset.centerRight,
                                                    end: FractionalOffset.centerLeft)),
                                            child: GridTileBar(
                                              // backgroundColor: Colors.black87,

//                          leading: IconButton(
//                            icon: Icon(Icons.favorite),
//                            color: Theme.of(context).accentColor,
//                            onPressed: () {},
//                          ),
                                              title: Text(
                                                snapshot.data.documents[index].data['Title'].toString().toUpperCase(),
                                                textAlign: TextAlign.center,style: TextStyle(  fontSize: 13,
                                                  color: Colors.black54,fontFamily: 'Overpass'),
                                                //style: TextStyle(fontStyle: F),
                                              ),
//                          trailing: IconButton(
//                            icon: Icon(
//                              Icons.shopping_cart,
//                            ),
//                            onPressed: () {},
//                            color: Theme.of(context).accentColor,
//                          ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );


                          }

                          else {
                            return Center(child: CircularProgressIndicator());
//
                          }
                        },
                      ),
                    ),
                    //      Text('Data'),
                    //      CookiePage(),
                    //      CookiePage(),
                    //      CookiePage(),
                  ]
              ),
            ),

          ],
        )   : Center(child: Text("Error")),),
    );
  }
}
