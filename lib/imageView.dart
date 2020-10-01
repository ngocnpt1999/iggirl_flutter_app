import 'package:flutter/material.dart';
import 'package:iggirl_flutter_app/service/services.dart';

class ImageViewPage extends StatefulWidget {
  final String _img;

  ImageViewPage(this._img);

  @override
  ImageViewPageState createState() => ImageViewPageState(this._img);
}

class ImageViewPageState extends State<ImageViewPage> {
  final String _img;

  ImageViewPageState(this._img);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          PopupMenuButton(
              onSelected: (String value) {
                if (value == "save") {
                  Services().saveImage(this._img);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: Text(
                        "Tải xuống",
                        textAlign: TextAlign.start,
                      ),
                      value: "save",
                    )
                  ])
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FadeInImage.assetNetwork(
            image: _img.replaceFirst(RegExp("size=m"), "size=l", 10),
            placeholder: "assets/images/white.png",
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
