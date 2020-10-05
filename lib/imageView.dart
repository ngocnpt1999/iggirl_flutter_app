import 'package:flutter/material.dart';
import 'package:iggirl_flutter_app/service/services.dart';

class ImageViewPage extends StatelessWidget {
  final String _img;

  ImageViewPage(this._img);

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
