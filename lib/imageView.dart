import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String _img;

  ImageView(this._img);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: this._img,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
