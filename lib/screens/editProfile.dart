import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/choseOnMap.dart';
import 'package:signup/helper/constants.dart';
import 'package:signup/helper/helperfunctions.dart';
import 'package:signup/models/AgentUser.dart';
import 'package:signup/models/user.dart';
import 'package:signup/services/agentDatabase.dart';
import 'package:signup/services/chatDatabase.dart';
import 'package:signup/states/currentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class EditProfile extends StatefulWidget {
  final bool isAgent;

  const EditProfile({Key key, this.isAgent}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState(this.isAgent);
}

class _EditProfileState extends State<EditProfile> {
  //File _image;
  bool work = false;
  String _imageUrl;
  File _imageFile;
  final picker = ImagePicker();
  bool isAgent;
  GeoPoint CordFromMap = null;
  OurUser _currentUser = OurUser();
  List<Asset> images = List<Asset>();
  List<String> imageUrls = <String>[];
  String _error = 'No Error Dectected';
  final Firestore _firestore = Firestore.instance;

  FirebaseUser user;
  AgentUser agentuser = AgentUser();


  _EditProfileState(this.isAgent);

  void _fetchUserData() async {
    // do something
    try {
      user = await FirebaseAuth.instance.currentUser();
      String authid =user.uid;
      Firestore.instance.collection('users').document('$authid').get().then((ds) {
        if (ds.exists) {
          setState(() {
            _firstName.text = ds.data['displayName'];
            _phoneController.text = ds.data['phoneNumber'];
            _description.text = ds.data['description'];
            _location.text = ds.data['Address'];
            _age.text = ds.data['age'];
            _imageUrl = ds.data['image'];
            _city.text = ds.data['city'];
          });
        }
      });
    }
    catch(e)
    {
      print("data");
    }
  }

  void dispose() {
    _firstName.dispose();
    super.dispose();
  }

  String retVal;
  String newName;
  String oldName;
  List<String> chatID;
  List<String> chatRoomName;


  @override
  void initState() {
    //print(widget.isAgent.toString());
    super.initState();
    initUser();
    _fetchUserData();

  //  print(user.uid.toString());
  }

  initUser() async {
    Constants.myName =await HelperFunctions.getUserNameSharedPreference();
   /* user = await Fire.currentUser();
    if(user != null) {
      print(user.uid.toString());
    }
    else{
      print("uid is null");
    }*/
  }

  String fName, title, age, location, phoneNumber, email, description;
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _description = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;


  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        //backgroundColor: Color(0xfff2f3f7),
        body: SingleChildScrollView(
        reverse: true,
        child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
          child: Stack(
            children: <Widget>[

              isAgent?  Container(
                height: MediaQuery.of(context).size.height*1.8,
                //color: Color(0xff2470c7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          const Color(0xff213A50),
                          const Color(0xff071930)
                        ],
                        begin: FractionalOffset.topRight,
                        end: FractionalOffset.bottomLeft)),

                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogo(context),
                    _buildContainer(context),
                  ],
                ),
              ):
              Container(
                height: MediaQuery.of(context).size.height,
                //color: Color(0xff2470c7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          const Color(0xff213A50),
                          const Color(0xff071930)
                        ],
                        begin: FractionalOffset.topRight,
                        end: FractionalOffset.bottomLeft)),

                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogo(context),
                    _buildContainer(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'Property Host',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer(BuildContext context) {


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child:  isAgent? Container(
            margin: EdgeInsets.only(bottom: 20),
            //padding: EdgeInsets.only(bottom: 0),
            height: MediaQuery.of(context).size.height *1.55,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _showName(),
              ],
            ),
          ):
          Container(
            //margin: EdgeInsets.only(bottom: 20),
            //padding: EdgeInsets.only(bottom: 0),
            height: MediaQuery.of(context).size.height/1.5,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _showName(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showName() {
    return user==null
        ? Center(child: CircularProgressIndicator()) : Builder(
      builder: (BuildContext context) {
        return Form(
          key: _key,
          autovalidate: _validate,
          child: StreamBuilder(
              stream: Firestore.instance.collection('users').where("uid", isEqualTo:user.uid).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

                if (snapshot.hasData) {
                  return ListView.builder(
                    //shrinkWrap: true,
                      shrinkWrap: true,  physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                _showImage(),
                                //                       SizedBox(height: 16),

                                SizedBox(height: 16),
                                _imageFile == null && _imageUrl == null
                                    ? ButtonTheme(
                                  child: RaisedButton(
                                    onPressed: () => _getLocalImage(),
                                    child: Text(
                                      'Add Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                    : SizedBox(height: 0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    maxLines: 1,
                                   maxLength: 14,
                                    controller: _firstName,
                                    validator: validateName,
                                    keyboardType: TextInputType.text,
                                    onChanged: (String val) {
                                      fName = val;
                                    },
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: 'Enter Full Name'),
                                  ),
                                ),
                                isAgent ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _age,
                                    keyboardType: TextInputType.number,
                                    validator: validateAge,
//                onSaved: (String val) {
//                  Age = val;
//                },
                                    maxLines: 1,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.invert_colors,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: 'Enter Age:'),
                                  ),
                                ):Container(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    validator: validatePhoneNumber,
                                    controller: _phoneController,
//                onSaved: (String val) {
//                  PhoneNumber = val;
//                },
                                    maxLines: 1,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.dialer_sip,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: 'Enter Number:'),
                                  ),
                                ),
                                isAgent? _showonMap(context):Container(),
                                isAgent ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _city,
                                    keyboardType: TextInputType.text,
                                    validator: ValidateCity,
                                    maxLines: 1,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.invert_colors,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: 'Enter City:'),
                                  ),
                                ):Container(),
                                isAgent? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    validator: ValidateLocation,
                                    controller: _location,
                                    maxLines: 1,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.add_location,
                                          color: Color(0xff2470c7),
                                        ),
                                        labelText: 'Enter Your Address:'),
                                  ),
                                ):Container(),


                                Container(
                                  //padding: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                                  //color: Colors.grey[200],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        isAgent ?       TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          validator: ValidateDescp,
                                          controller: _description,
                                          maxLines: 4,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.description,
                                                color: Color(0xff2470c7),
                                              ),
                                              labelText: 'Your Introduction:'),
                                          //textAlign: TextAlign,
                                        ):Container(),
                                        Container(
                                          margin: EdgeInsets.only(left: 10,
                                              ),
                                          width: 165,
                                          child: FlatButton(
                                            color: Color(0xff2196F3),
                                            onPressed: () async {
                                              _validate = true;
                                              if (_sendToServer() ==true) {
                                                if(snapshot.data.documents.elementAt(index)['UserType']=="Agent"){
                                                  print(user.uid.toString() + "agent if");
                                                  if(CordFromMap != null){
                                                    print("error");
                                                    await GetImageReferences();
                                                    agentuser.uid =user.uid;
                                                    agentuser.Name = _firstName.text;
                                                    agentuser.age=_age.text;
                                                    agentuser.phoneNumber=_phoneController.text;
                                                    agentuser.city=_city.text;
                                                    agentuser.address=_location.text;
                                                    agentuser.image=_imageUrl;
                                                    agentuser.description =_description.text;
                                                    agentuser.location = CordFromMap;
                                                    AgentDatabase().updateAgentProfile(agentuser);
                                                    chatdatabase().updateChatRoomName(chatRoomName,chatID);
                                                    Navigator.pop(context);

                                                  }
                                                  else{
                                                    showInSnackBar("Please select location");

                                                  }



                                                }
                                                else if(snapshot.data.documents.elementAt(index)['UserType']=="user"){

                                                  print("user if");
                                                  await GetImageReferences();
                                                  await   _firestore.collection("users").document(
                                                      user.uid).updateData({
                                                    "displayName": _firstName.text,
                                                    'phoneNumber': _phoneController.text,
                                                    'image':_imageUrl,
                                                  });
                                                  chatdatabase().updateChatRoomName(chatRoomName,chatID);
                                                  Navigator.pop(context);
                                                }


                                                _validate = false;
                                                return true;
                                              }

                                            // Navigator.pop(context);
                                            },
                                            child: Text('Update',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                )),
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Color(0xff2470c7),
                                                  width: 1.5,
                                                  style: BorderStyle.solid),
                                            ),
                                          ),
                                        ),
                                         StreamBuilder(
                                      stream: Firestore.instance.collection("chatRoom").where('users', arrayContains: user.uid).snapshots(),
                                      builder: (context, snapshot1) {
                                        print("inside the stream builder of chat query");
                                        return snapshot1.hasData
                                            ? ListView.builder(
                                            itemCount: snapshot1.data.documents.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index1) {
                                              List<String> chatNew ;
                                              String otherUserName;
                                              chatRoomName = [];
                                              chatID = [];
                                              if(_firstName.text.isNotEmpty){

                                              for(int i =0; i <snapshot1.data.documents.length; i++){
                                                print("inside the for loop ${i}");
                                                otherUserName = snapshot1.data.documents[i]['chatRoomName'].toString().replaceAll("_", "").replaceAll(Constants.myName, "");
                                                chatNew = snapshot1.data.documents[i]['chatRoomName'].toString().split("_");
                                                for(int j =0 ; j<chatNew.length; j++){
                                                  print("in nested J loop ${j} + ${i}");
                                                  if(chatNew[j].contains(snapshot.data.documents.elementAt(index)['displayName'])){
                                                    print("chatRoomIds" + snapshot1.data.documents[i].documentID);
                                                      chatNew[j] = _firstName.text;
                                                      newName = getChatRoomId(chatNew[j], otherUserName);
                                                      print(newName + " new chatroomName");
                                                      chatRoomName.add(newName);
                                                      chatID.add(snapshot1.data.documents[i].documentID);


                                                  }

                                                }

                                              }
                                              }
                                              return Container(child:Text(""));
                                            })
                                            : Container();
                                      })
                                      ],

                                      // ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  );
                }
                else {
                  debugPrint('Loading...');
                  return Center(
                    child: Text('Loading...'),
                  );

                }
              }
          ),
        );
      },
    );
  }
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
  Widget _showonMap(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.map,
                color: Colors.white,
                textDirection: TextDirection.ltr,
              ),
              label: FlatButton(
                //color: Color(0xff2470c7),
                onPressed: () {
                  _navigateAndDisplaySelection(context);


                },
                child: Text(
                  'Select Area on Map',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Color(0xff2196F3),
            ),
          ),
        ],
      ),
    );
  }
  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    CordFromMap = await Navigator.push(context, MaterialPageRoute(builder: (context) => ChoseOnMap()),);
    print("${CordFromMap} "+" got result from map screen");
  }


  Future<String> GetImageReferences() async {

    String error = "No error detected";
    List<String> urls = <String>[];
    imageUrls = [];

    try {

        await  postImage(_imageFile).then((downloadUrl) {
        //  urls.add(downloadUrl.toString());
          _imageUrl = downloadUrl.toString();
          print( "i am third line of awaiting uploading image");
          if (_imageUrl.isNotEmpty) {
            print(imageUrls.length.toString() + " images selected");

            return _imageUrl;

          }

        }).catchError((err) {
          print(err);
        });

    } on Exception catch (e) {
      error = e.toString();
      print(error);
    }

    return _imageUrl;

  }


  Future<dynamic> postImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    var _data = await imageFile.readAsBytesSync();
    StorageUploadTask uploadTask = reference.putData(await FlutterImageCompress.compressWithList(
      _data.buffer.asUint8List(),
      minHeight: 500,
      minWidth: 500,
    ));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }


  // ignore: missing_return
  bool _sendToServer() {
 if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      return true;
    } else {
      // validation error
      setState(() {

        _validate = true;
        return false;
      });
    }
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("image placeholder");
    } else if (_imageFile != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 120,
            width: 120,
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: ButtonTheme(
              height: 2,
              minWidth: 10,
              child: RaisedButton(
                padding: EdgeInsets.all(16),
                color: Colors.black54,
                child: Text(
                  'Change Image',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                onPressed: () => _getLocalImage(),
              ),
            ),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');

      return Column(
        //alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          ClipOval(
            child: Image.network(
              _imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          ButtonTheme(
            height: 10,
            minWidth: 10,
            child: NiceButton(
                width: 150,
                elevation: 8.0,
                radius: 52.0,
                text:"Upload Image",
                background: Colors.blueAccent,
                onPressed: () => _getLocalImage()),
          )
        ],
      );
    }
  }

  Future _getLocalImage() async {
    PickedFile pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);
//    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _cropImage(pickedFile.path);
      });
    }
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 500,
      maxHeight: 500,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );
    if (croppedImage != null) {
      _imageFile = croppedImage;
      setState(() {});
    }
  }
}


