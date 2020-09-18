import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:iggirl_flutter_app/model/links.dart';

import 'model/post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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

  List<Link> _listLink;

  List<Post> _listPost = new List();

  @override
  void initState() {
    super.initState();
    loadPosts(5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _listPost.length, itemBuilder: buildPostView),
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
                                  child: Text("Save Image"),
                                  onPressed: () {},
                                ),
                                CupertinoActionSheetAction(
                                  child: Text("Share Image"),
                                  onPressed: () {},
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
          onTap: () {},
          child: Image(
            image: NetworkImage(_listPost[index].img),
            fit: BoxFit.fitWidth,
          ),
        ),
      ],
    );
  }

  loadPosts(int number) async {
    Client client = new Client();
    if (_listLink == null) {
      _listLink = await Database().fetchLinks(client);
    }
    List<Link> postLinks = _listLink.skip(_counter).take(number).toList();
    try {
      postLinks.forEach((element) async {
        var response = await client
            .get("https://api.instagram.com/oembed/?url=" + element.uri);
        var value = json.decode(response.body);
        setState(() {
          _listPost.add(new Post(
              value["author_name"].toString(),
              "https://i.pinimg.com/originals/a2/5f/4f/a25f4f58938bbe61357ebca42d23866f.png",
              element.uri + "/media/?size=l"));
        });
      });
    } catch (ex) {
      throw (ex);
    } finally {
      _counter += number;
    }
  }
}
