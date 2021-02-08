

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ImageScreen extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String Imageurl;
  ImageScreen(this.Imageurl);

  @override
  _MyImageScreen createState() => _MyImageScreen(Imageurl);
}

class _MyImageScreen extends State<ImageScreen> {
  final String url;
  _MyImageScreen(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ImageScreen'),
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
        ),
        body: Image.network(url, width: double.infinity,
          loadingBuilder: (
              BuildContext context,
              Widget
              child,
              ImageChunkEvent
              loadingProgress) {
            if (loadingProgress ==
                null)
              return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress
                    .expectedTotalBytes !=
                    null
                    ? loadingProgress
                    .cumulativeBytesLoaded /
                    loadingProgress
                        .expectedTotalBytes
                    : null,
              ),
            );
          },
          fit: BoxFit
              .cover,
        ),
    );
  }
}

