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
      width: MediaQuery.of(context).size.width,
      child: FadeInImage.assetNetwork(
        image: _image,
        placeholder: "assets/images/white.png",
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
