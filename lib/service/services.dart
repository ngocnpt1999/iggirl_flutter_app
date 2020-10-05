import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';

class Services {
  static final Services _singleton = Services._internal();

  factory Services() => _singleton;

  Services._internal();

  void saveImage(String uri) async {
    var storageStatus = await Permission.storage.status;
    var photosStatus = await Permission.photos.status;
    if (!storageStatus.isGranted && Platform.isAndroid) {
      await Permission.storage.request();
    } else if (!photosStatus.isGranted && Platform.isIOS) {
      await Permission.photos.request();
    } else {
      String hdUri = uri.replaceFirst(RegExp("size=m"), "size=l", 10);
      var response = await Dio()
          .get(hdUri, options: Options(responseType: ResponseType.bytes));
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

  void launchUrl(String uri) async {
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      Fluttertoast.showToast(msg: "Could not launch $uri");
    }
  }
}
