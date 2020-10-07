import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/control/imageAliveView.dart';
import 'package:iggirl_flutter_app/controller/controller.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class ListGirlPage extends StatelessWidget {
  ListGirlPage();

  final int _num = 8;

  final ListPostController _pageController = ListPostController();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _pageController.loadNewPosts(_num);
      }
    });
    if (_pageController.listPost.length == 0) {
      _pageController.loadNewPosts(_num);
    }

    return Scaffold(
      body: Obx(() {
        if (_pageController.listPost.length > 0) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
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
                floating: true,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  _buildPostView,
                  childCount: _pageController.listPost.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    height: 40.0,
                    width: 40.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              ),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding:
                EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0, right: 10.0),
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
                            image: new NetworkImage(
                                _pageController.listPost[index].avatar)))),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Wrap(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Services().launchUrl(
                                  "https://www.instagram.com/" +
                                      _pageController.listPost[index].name);
                            },
                            child: Text(
                              _pageController.listPost[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
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
                                        _pageController.listPost[index].img);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: Text("Chia sẻ liên kết"),
                                  onPressed: () {
                                    Share.share(
                                        _pageController.listPost[index].img);
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
            )),
        InkWell(
          onTap: () {
            Get.to(ImageViewPage(_pageController.listPost[index].img));
          },
          child: ImageAliveView(_pageController.listPost[index].img),
        ),
      ],
    );
  }
}
