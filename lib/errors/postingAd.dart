import 'package:flutter/material.dart';

class PostingAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/13_Ad_Posting.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.42,
            right: MediaQuery.of(context).size.width * 0.42,
            child: Container(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 55.0,
                width: 50.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
