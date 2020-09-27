import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:iggirl_flutter_app/service/services.dart';
import 'package:share/share.dart';

class SwipeCardsPage extends StatefulWidget {
  SwipeCardsPage();

  @override
  SwipeCardsPageState createState() => SwipeCardsPageState();
}

class SwipeCardsPageState extends State<SwipeCardsPage> {
  SwipeCardsPageState();

  int _counter = 0;

  int _num = 5;

  CardController _controller = new CardController();

  List<Post> _listPost = new List();

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
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TinderSwapCard(
                  swipeUp: true,
                  swipeDown: true,
                  orientation: AmassOrientation.BOTTOM,
                  totalNum: _listPost.length,
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
                      setState(() {
                        _listPost.removeAt(index);
                      });
                    }
                    if (_listPost.length == 2) {
                      _loadNewPosts(_num);
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
        },
      ),
    );
  }

  Widget _buildPostView(BuildContext context, int index) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImageViewPage(_listPost[index].img)));
              },
              child: CachedNetworkImage(
                imageUrl: _listPost[index].img,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Padding(
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
                              _listPost[index].name);
                        },
                        child: Text(
                          _listPost[index].name,
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
        ],
      ),
    );
  }

  void _loadNewPosts(int number) {
    Database().fetchData(_counter, _num).whenComplete(() async {
      List<Post> newPosts = await Database().getNewPosts();
      setState(() {
        _listPost.addAll(newPosts);
      });
      _counter += number;
      print("Counter: $_counter");
    });
  }
}
