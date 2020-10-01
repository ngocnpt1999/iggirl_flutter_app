import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class PageViewPage extends StatefulWidget {
  @override
  PageViewPageState createState() => PageViewPageState();
}

class PageViewPageState extends State<PageViewPage> {
  PageViewPageState();

  int _counter = 0;

  int _num = 5;

  bool _isBusy = true;

  List<Post> _listPost = new List();

  PageController _pageController = new PageController();

  Future _future;

  @override
  void initState() {
    super.initState();
    _future = Database().fetchData(_counter, _num).whenComplete(() {
      _loadNewPosts(_num);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return PageView.builder(
              controller: _pageController,
              itemBuilder: _buildPostView,
              itemCount: _listPost.length,
              onPageChanged: (value) {
                if (value == _listPost.length - 2 && _isBusy == false) {
                  _loadNewPosts(_num);
                }
              },
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
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 5.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                                  image: new NetworkImage(
                                      _listPost[index].avatar)))),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                          Services()
                                              .saveImage(_listPost[index].img);
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
                      builder: (context) =>
                          ImageViewPage(_listPost[index].img)));
                },
                child: FadeInImage.assetNetwork(
                  image: _listPost[index].img,
                  placeholder: "assets/images/white.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadNewPosts(int number) {
    _isBusy = true;
    Database().fetchData(_counter, _num).whenComplete(() async {
      List<Post> newPosts = await Database().getNewPosts();
      setState(() {
        _listPost.addAll(newPosts);
      });
      _isBusy = false;
      _counter += number;
      print("Counter: $_counter");
    });
  }
}
