import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageAliveView extends StatefulWidget {
  final String _image;

  ImageAliveView(this._image);

  @override
  ImageAliveViewState createState() => ImageAliveViewState(this._image);
}

class ImageAliveViewState extends State<ImageAliveView>
    with AutomaticKeepAliveClientMixin<ImageAliveView> {
  final String _image;

  ImageAliveViewState(this._image);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
        child: CachedNetworkImage(
      imageUrl: this._image,
      placeholder: (context, url) => Image(
        image: AssetImage("assets/images/white.png"),
        fit: BoxFit.fitWidth,
      ),
      fit: BoxFit.fitWidth,
    ));
  }
}
