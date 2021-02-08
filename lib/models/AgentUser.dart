import 'package:cloud_firestore/cloud_firestore.dart';

class AgentUser {
  String uid;
  String email;
  String age;
  String description;
  Timestamp accountCreated;
  String Name;
  String phoneNumber;
  String UserType;
  List<String> SearchindexList;
  GeoPoint location;
  String image;
  String address;
  String city;
  AgentUser({
        this.uid,
        this.email,
        this.age,
        this.location,
        this.description,
        this.accountCreated,
        this.Name,
        this.phoneNumber,
        this.UserType,
        this.image,
        this.address,
    this.SearchindexList,
  this.city});
}
