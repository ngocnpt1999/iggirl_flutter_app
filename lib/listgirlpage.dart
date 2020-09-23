import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:iggirl_flutter_app/control/imageAliveView.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_isBusy == false) {
          _loadNewPosts(_num);
        }
      }
    });
    _future = Database().init().whenComplete(() {
      _loadNewPosts(_num);
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
                              _launchUrl("https://www.instagram.com/" +
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
                                    _saveImage(_listPost[index].img);
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

  void _loadNewPosts(int number) async {
    _isBusy = true;
    Client client = new Client();
    List<Link> news = Database().links.skip(_counter).take(number).toList();

    for (int i = 0; i < news.length; i++) {
      try {
        var response = await client
            .get("https://api.instagram.com/oembed/?url=" + news[i].uri);
        if (response.statusCode == 200) {
          var value = json.decode(response.body);
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              _listPost.add(new Post(
                  value["author_name"].toString(),
                  "https://f0.pngfuel.com/png/863/426/instagram-logo-png-clip-art.png",
                  news[i].uri + "/media/?size=l"));
            });
          });
        }
      } catch (ex) {
        print(ex);
        continue;
      }
    }
    _counter += number;
    print("Counter: $_counter");
    _isBusy = false;
  }

  void _saveImage(String uri) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else {
      var response = await Dio()
          .get(uri, options: Options(responseType: ResponseType.bytes));
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
    Navigator.of(context).pop();
  }

  void _launchUrl(String uri) async {
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      Fluttertoast.showToast(msg: "Could not launch $uri");
    }
  }
}
