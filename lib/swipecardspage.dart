import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/controller/controller.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class SwipeCardsPage extends StatelessWidget {
  SwipeCardsPage();

  final int _num = 5;

  final ListPostController _pageController = ListPostController();

  final CardController _controller = CardController();

  @override
  Widget build(BuildContext context) {
    if (_pageController.listPost.length == 0) {
      _pageController.loadNewPosts(_num);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              height: 32.0,
              image: AssetImage("assets/images/logo.png"),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_pageController.listPost.length > 0) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: TinderSwapCard(
                swipeUp: true,
                swipeDown: true,
                orientation: AmassOrientation.BOTTOM,
                totalNum: _pageController.listPost.length,
                stackNum: 5,
                swipeEdge: 6.0,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.width * 0.9,
                minWidth: MediaQuery.of(context).size.width * 0.8,
                minHeight: MediaQuery.of(context).size.width * 0.8,
                cardBuilder: _buildPostView,
                cardController: _controller,
                swipeCompleteCallback:
                    (CardSwipeOrientation orientation, int index) {
                  if (orientation != CardSwipeOrientation.RECOVER) {
                    _pageController.listPost.removeAt(index);
                  }
                  if (_pageController.listPost.length == 2) {
                    _pageController.loadNewPosts(_num);
                  }
                },
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  Widget _buildPostView(BuildContext context, int index) {
    return Card(
      elevation: 5.0,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              Get.to(ImageViewPage(_pageController.listPost[index].img));
            },
            child: FadeInImage.assetNetwork(
              image: _pageController.listPost[index].img,
              placeholder: "assets/images/white.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Container(
                color: Colors.grey.withOpacity(0.5),
                padding: EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Wrap(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Services().launchUrl("https://www.instagram.com/" +
                                _pageController.listPost[index].name);
                          },
                          child: Text(
                            _pageController.listPost[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )),
                    InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                                  actions: <Widget>[
                                    CupertinoActionSheetAction(
                                      child: Text("Lưu hình ảnh"),
                                      onPressed: () {
                                        Services().saveImage(_pageController
                                            .listPost[index].img);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    CupertinoActionSheetAction(
                                      child: Text("Chia sẻ liên kết"),
                                      onPressed: () {
                                        Share.share(_pageController
                                            .listPost[index].img);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                  cancelButton: CupertinoActionSheetAction(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ));
                      },
                      child: Icon(Icons.more_vert),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
