import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iggirl_flutter_app/control/imageAliveView.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class ListGirlPage extends StatefulWidget {
  ListGirlPage();

  @override
  ListGirlPageState createState() => ListGirlPageState();
}

class ListGirlPageState extends State<ListGirlPage>
    with AutomaticKeepAliveClientMixin<ListGirlPage> {
  ListGirlPageState();

  int _counter = 0;

  int _num = 5;

  bool _isBusy = true;

  List<Post> _listPost = new List();

  ScrollController _scrollController = new ScrollController();

  Future _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_isBusy == false) {
          await _loadNewPosts(_num);
        }
      }
    });
    _future = Database().init().whenComplete(() async {
      await _loadNewPosts(_num);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return CustomScrollView(
              controller: _scrollController,
              cacheExtent: 1000.0,
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
                    childCount: _listPost.length,
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildPostView(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(
                left: 10.0, top: 15.0, bottom: 7.0, right: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(_listPost[index].avatar)))),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Wrap(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Services().launchUrl(
                                  "https://www.instagram.com/" +
                                      _listPost[index].name);
                            },
                            child: Text(
                              _listPost[index].name,
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
                                    Services().saveImage(_listPost[index].img);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: Text("Chia sẻ liên kết"),
                                  onPressed: () {
                                    Share.share(_listPost[index].img);
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ImageViewPage(_listPost[index].img)));
          },
          child: ImageAliveView(_listPost[index].img),
        ),
      ],
    );
  }

  Future<void> _loadNewPosts(int number) async {
    _isBusy = true;
    List<Post> newPosts = await Database().getNewPosts(number);
    setState(() {
      _listPost.addAll(newPosts);
    });
    _counter += number;
    print("Counter: $_counter");
    _isBusy = false;
  }
}
