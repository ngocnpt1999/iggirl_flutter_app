import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/controller/controller.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class PageViewPage extends StatelessWidget {
  PageViewPage();

  final int _num = 5;

  final ListPostController _pageController = ListPostController();

  final PageController _controller = PageController();

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
          return PageView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemBuilder: _buildPostView,
            itemCount: _pageController.listPost.length,
            onPageChanged: (value) {
              if (value == _pageController.listPost.length - 2) {
                _pageController.loadNewPosts(_num);
              }
            },
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
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 5.0,
          child: Wrap(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: InkWell(
                      onTap: () {
                        Get.to(
                            ImageViewPage(_pageController.listPost[index].img));
                      },
                      child: FadeInImage.assetNetwork(
                        image: _pageController.listPost[index].img,
                        placeholder: "assets/images/white.png",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        color: Colors.grey.withOpacity(0.5),
                        padding: EdgeInsets.only(
                            left: 12.0, top: 8.0, bottom: 8.0, right: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: 30.0,
                                height: 30.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(_pageController
                                            .listPost[index].avatar)))),
                            Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Wrap(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          Services().launchUrl(
                                              "https://www.instagram.com/" +
                                                  _pageController
                                                      .listPost[index].name);
                                        },
                                        child: Text(
                                          _pageController.listPost[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            InkWell(
                              onTap: () {
                                showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) => CupertinoActionSheet(
                                          actions: <Widget>[
                                            CupertinoActionSheetAction(
                                              child: Text("Lưu hình ảnh"),
                                              onPressed: () {
                                                Services().saveImage(
                                                    _pageController
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
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ));
                              },
                              child: Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
