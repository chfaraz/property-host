
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostBidFirebase{

  final firestoreInstance = Firestore.instance;

  void CreateBid(String name,int number,double bid,String postId) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
   await firestoreInstance.collection("BidList").add(
        {
          "Name": name,
          "Number": number,
          "Bid": bid,
          "uid":firebaseUser.uid,
          "PostID":postId,
        }).then((value) {
      firestoreInstance.collection("BidList").document(value.documentID).setData(
          {
            "BidID":value.documentID,

          },merge : true).then((_){

        print("success!" + value.documentID);
      });
      print("success new bid added in firebase!");

    });
  }

  removeOffer(String BidId) async {
    await Firestore.instance.collection("BidList").document(BidId).delete();

    print("Post deleted with id" + BidId);
  }


}
