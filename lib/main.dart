import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:iggirl_flutter_app/imageView.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';

void main() {
  Database().init();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IGGirl'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool _isBusy = true;

  List<Post> _listPost = new List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_isBusy == false) {
          _loadNewPosts(5);
        }
      }
    });
    _loadNewPosts(5);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: _listPost.length,
          itemBuilder: buildPostView),
    );
  }

  Widget buildPostView(BuildContext context, int index) {
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
                    child: Text(
                      _listPost[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                builder: (context) => ImageView(_listPost[index].img)));
          },
          child: CachedNetworkImage(
            imageUrl: _listPost[index].img,
            placeholder: (context, url) => Image(
              image: AssetImage("assets/images/white.png"),
              fit: BoxFit.fitWidth,
            ),
            fit: BoxFit.fitWidth,
          ),
        ),
      ],
    );
  }

  void _loadNewPosts(int number) async {
    _isBusy = true;
    Client client = new Client();
    List<Link> news = Database().links.skip(_counter).take(number).toList();
    try {
      for (int i = 0; i < news.length; i++) {
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
      }
    } catch (ex) {
      print(ex);
      throw (ex);
    } finally {
      _counter += number;
      print("Counter: $_counter");
      _isBusy = false;
    }
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
}
