import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:transparent_image/transparent_image.dart';

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
        child: FadeInImage.memoryNetwork(
          image: this._img,
          placeholder: kTransparentImage,
          width: Get.width,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
