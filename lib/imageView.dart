import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

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
                  _saveImage(this._img);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: Text("Tải xuống"),
                      value: "save",
                    )
                  ])
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: this._img,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  void _saveImage(String uri) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      var response = await Dio()
          .get(uri, options: Options(responseType: ResponseType.bytes));
      var result;
      ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
              quality: 100, name: randomString(15))
          .then((value) => result = value)
          .whenComplete(() {
        if (["", null, false, 0].contains(result)) {
          Fluttertoast.showToast(
            msg: "Lưu thất bại",
          );
        } else {
          Fluttertoast.showToast(
            msg: "Lưu thành công",
          );
        }
      });
    }
  }
}
