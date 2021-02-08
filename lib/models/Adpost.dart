import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_range_picker/time_range_picker.dart';

class AdPost {
  String postId;
  String userId;
  String title;
      String desc;
  int price;
      String City;
  String AvailDays;
      String Fromtime;
      String endtime;
  String unitArea;
      GeoPoint location;
      String Address;
  String purpose;
  String propertyType;
      String propertyDeatil;
  String buildyear;
      String Rooms;
      String time;
  String ParkingSpace;
      String Floors;
      String bathrooms;
  String Kitchens;
  String Flooring;
      bool Elevators;
  bool MaintenanceStaff;
      bool Security;
  bool WasteDisposal;
  bool possesion;
      bool ParkingSpaces;
  bool corners;
      bool disputed;
  bool balloted;
      bool suiGas;
  bool waterSupply;
      bool sewarge;
  String propertySize;
  String width;
  String length;
      List ImageUrls;
      String priceFrom;
      String priceTo;


      AdPost({
        this.postId,
        this.userId,
        this.title,
        this.desc,
        this.price,
        this.City,
        this.AvailDays,
        this.Fromtime,
        this.endtime,
        this.unitArea,
        this.location,
        this.Address,
        this.purpose,
        this.propertyType,
        this.propertyDeatil,
        this.buildyear,
        this.Rooms,
        this.ParkingSpace,
        this.Floors,
        this.bathrooms,
        this.Kitchens,
        this.Flooring,
        this.Elevators,
        this.MaintenanceStaff,
        this.Security,
        this.WasteDisposal,
        this.possesion,
        this.ParkingSpaces,
        this.corners,
        this.disputed,
        this.balloted,
        this.suiGas,
        this.waterSupply,
        this.sewarge,
        this.propertySize,
        this.ImageUrls,
        this.priceFrom,
        this.priceTo,
        this.width,
        this.length,
        this.time
      });


}
