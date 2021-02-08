import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:signup/models/Adpost.dart';

class PostAddFirebase {
  final firestoreInstance = Firestore.instance;
  BuildContext context;
  void createPostAddHomes(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "ImageUrls": adPost.ImageUrls,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PostTime": Timestamp.now(),
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "MainFeatures": {
        "Buildyear": adPost.buildyear,
        "Parkingspace": adPost.ParkingSpace,
        "Rooms": adPost.Rooms,
        "Bathrooms": adPost.bathrooms,
        "kitchens": adPost.Kitchens,
        "Floors": adPost.Floors,
      },
      //   "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  void createPostAddHomesPentHouse(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "ImageUrls": adPost.ImageUrls,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PostTime": Timestamp.now(),
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  void createPostAddResidentialPlots(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PostTime": Timestamp.now(),
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      "MainFeatures": {
        "Possession": adPost.possesion,
        "Parkfacing": adPost.ParkingSpace,
        "Disputed": adPost.disputed,
        "Balloted": adPost.balloted,
        "Corner": adPost.corners,
        "suigas": adPost.suiGas,
        "watersupply": adPost.waterSupply,
        "Sewarege": adPost.sewarge,
      },
      //    "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  void createPostPlots(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    print(adPost.toString());
    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PostTime": Timestamp.now(),
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      //    "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  void createPostAddCommerical(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PostTime": Timestamp.now(),
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,

      "MainFeatures": {
        "Buildyear": adPost.buildyear,
        "Parkingspace": adPost.ParkingSpace,
        "Rooms": adPost.Rooms,
        "Floors": adPost.Floors,
        "Elevators": adPost.Elevators,
        "MaintenanceStaff": adPost.MaintenanceStaff,
        "SecurityStaff": adPost.Security,
        "Wastedisposal": adPost.WasteDisposal
      },
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  void createPostAddWareHouse(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").add({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PostTime": Timestamp.now(),
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    }).then((value) {
      firestoreInstance.collection("PostAdd").document(value.documentID).setData({
        "PostID": value.documentID,
      }, merge: true).then((_) {
        print("success!" + value.documentID);
      });
      print("success new post added in firebase!");
    });
  }

  // ---------------------------------------------------------- update functions-------------------------------------//

  void updatePostAddWareHouse(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
    print("success  post updated in firebase!");
  }

  void updatePostAddHomes(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "ImageUrls": adPost.ImageUrls,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "MainFeatures": {
        "Buildyear": adPost.buildyear,
        "Parkingspace": adPost.ParkingSpace,
        "Rooms": adPost.Rooms,
        "Bathrooms": adPost.bathrooms,
        "kitchens": adPost.Kitchens,
        "Floors": adPost.Floors,
      },
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
    print("success  post updated in firebase!");
  }

  void updatePostAddHomesPentHouse(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "ImageUrls": adPost.ImageUrls,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      //   "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
    print("success new updated in firebase!");
  }

  void updatePostAddResidentialPlots(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      "MainFeatures": {
        "Possession": adPost.possesion,
        "Parkfacing": adPost.ParkingSpace,
        "Disputed": adPost.disputed,
        "Balloted": adPost.balloted,
        "Corner": adPost.corners,
        "suigas": adPost.suiGas,
        "watersupply": adPost.waterSupply,
        "Sewarege": adPost.sewarge,
      },
      //    "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
    print("success new post updated in firebase!");
  }

  void updatePostPlots(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,

      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,
      "MainFeatures": {
        "Possession": adPost.possesion,
        "Parkfacing": adPost.ParkingSpace,
        "Disputed": adPost.disputed,
        "Balloted": adPost.balloted,
        "Corner": adPost.corners,
        "suigas": adPost.suiGas,
        "watersupply": adPost.waterSupply,
        "Sewarege": adPost.sewarge,
      },
      //   "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
  }

  void updatePostAddCommerical(AdPost adPost) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance.collection("PostAdd").document(adPost.postId).updateData({
      "Width_Length": adPost.length != null && adPost.width != null ? {"Width": (adPost.width), "Length": (adPost.length)} : null,
      "Title": adPost.title,
      "Description": adPost.desc,
      "Price": adPost.price,
      "Address": {"Street": adPost.Address, "city": adPost.City},
      "Location": adPost.location,
      "AvailableDays": adPost.AvailDays,
      "Purpose": adPost.purpose,
      "PropertyType": adPost.propertyType,
      "PropertySubType": adPost.propertyDeatil,
      "MeetingTime": adPost.Fromtime + " - " + adPost.endtime,
      "PropertySize": adPost.propertySize,
      "ImageUrls": adPost.ImageUrls,

      "MainFeatures": {
        "Buildyear": adPost.buildyear,
        "Parkingspace": adPost.ParkingSpace,
        "Rooms": adPost.Rooms,
        "Floors": adPost.Floors,
        "Flooring": adPost.Flooring,
        "Elevators": adPost.Elevators,
        "MaintenanceStaff": adPost.MaintenanceStaff,
        "SecurityStaff": adPost.Security,
        "Wastedisposal": adPost.WasteDisposal
      },
      //  "email": firebaseUser.email,
      "uid": firebaseUser.uid,
    });
  }

  ////////////////////////delete post
  removePost(String PostId) async {
    await Firestore.instance.collection("PostAdd").document(PostId).delete();

    print("Post deleted with id" + PostId);
  }

  getAllUserAds(String userId)async{
  return  await Firestore.instance.collection("PostAdd").where("uid",isEqualTo: userId).snapshots();

  }
  ////////////////////getAll Ads ////////////////////


  ////////////ends//////////

  CopyAdToOldCollection(String postId) async {
    DocumentSnapshot _ds = await firestoreInstance.collection("PostAdd").document(postId).get();
    Map mapEventData = _ds.data;
    await firestoreInstance.collection("OldAdd").document(postId).setData(mapEventData);
    print("sucess moved to old collection");
  }

  getCordinatesOfAdsRefresh(String sizeType, double x1, double y1, double x2, double y2, AdPost adPost) async {
    var lesserGeopoint = GeoPoint(x1, y1);
    var greaterGeopoint = GeoPoint(x2, y2);
    if (adPost.propertySize == null && adPost.propertyType == "All" && adPost.propertyDeatil == "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("Purpose", isEqualTo: adPost.purpose)
          .snapshots();
    } else if (adPost.propertySize == null && adPost.propertyType != "All" && adPost.propertyDeatil == "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertyType", isEqualTo: adPost.propertyType) //for example houses All. the word will be Home
          .snapshots();
    } else if (adPost.propertySize == null && adPost.propertyType != "All" && adPost.propertyDeatil != "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertyType", isEqualTo: adPost.propertyType)
          .where("PropertySubType", isEqualTo: adPost.propertyDeatil)
          .snapshots();
    } else if (adPost.propertySize != null && adPost.width == null && adPost.propertyType == "All" && adPost.propertyDeatil == "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertySize", isEqualTo: adPost.propertySize)
          .snapshots();
    } else if (adPost.propertySize != null && adPost.propertyType != "All" && adPost.propertyDeatil == "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("PropertySize", isEqualTo: adPost.propertySize)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertyType", isEqualTo: adPost.propertyType)
          .snapshots();
    } else if (adPost.propertySize != null && adPost.width == null && adPost.propertyType != "All" && adPost.propertyDeatil != "") {
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("PropertySize", isEqualTo: adPost.propertySize)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertyType", isEqualTo: adPost.propertyType)
          .where("PropertySubType", isEqualTo: adPost.propertyDeatil)
          .snapshots();
    } else if (adPost.propertySize != null && adPost.width != null && adPost.propertyType != "All" && adPost.propertyDeatil != "") {
      int width = int.parse(adPost.width);
      int length = int.parse(adPost.length);
      List<int> items = [width, length];
      Map<int, String> result = Map.fromIterable(items, key: (v) => v.id, value: (v) => v.name);
      return await firestoreInstance
          .collection("PostAdd")
          .where("Location", isLessThan: lesserGeopoint)
          .where("Location", isGreaterThan: greaterGeopoint)
          .where("Width_Length", isEqualTo: result)
          .where("Purpose", isEqualTo: adPost.purpose)
          .where("PropertyType", isEqualTo: adPost.propertyType)
          .where("PropertySubType", isEqualTo: adPost.propertyDeatil)
          .snapshots();
    }
  }

  ///////////////////////////NearBy placess /////////////////////////

  getCordinatesOfSchoolsRefresh(double x1, double y1, double x2, double y2) async {
    var lesserGeopoint = GeoPoint(x1, y1);
    var greaterGeopoint = GeoPoint(x2, y2);
    return await firestoreInstance.collection("school").where("Location", isLessThan: lesserGeopoint).where("Location", isGreaterThan: greaterGeopoint).snapshots();
  }

  getCordinatesOfHospitalsRefresh(double x1, double y1, double x2, double y2) async {
    var lesserGeopoint = GeoPoint(x1, y1);
    var greaterGeopoint = GeoPoint(x2, y2);
    return await firestoreInstance.collection("hospital").where("Location", isLessThan: lesserGeopoint).where("Location", isGreaterThan: greaterGeopoint).snapshots();
  }

  getCordinatesOfParksRefresh(double x1, double y1, double x2, double y2) async {
    var lesserGeopoint = GeoPoint(x1, y1);
    var greaterGeopoint = GeoPoint(x2, y2);
    return await firestoreInstance.collection("park").where("Location", isLessThan: lesserGeopoint).where("Location", isGreaterThan: greaterGeopoint).snapshots();
  }
}
