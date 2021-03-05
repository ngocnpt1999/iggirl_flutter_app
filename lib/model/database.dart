import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Post {
  final String name;
  final String avatar;
  final String img;

  Post(this.name, this.avatar, this.img);
}

class Database {
  static final Database _singleton = Database._internal();

  factory Database() => _singleton;

  Database._internal();

  String _accessToken = "";

  Client _client = Client();

  Future<List<Post>> getNewPosts(List<String> links) async {
    List<Post> newPosts = [];
    for (int i = 0; i < links.length; i++) {
      var response = await _client.get(
          "https://graph.facebook.com/v9.0/instagram_oembed?url=" +
              links[i] +
              "&access_token=" +
              _accessToken);
      if (response.statusCode == 200) {
        var value = json.decode(response.body);
        newPosts.add(Post(
          value["author_name"].toString(),
          "https://f0.pngfuel.com/png/863/426/instagram-logo-png-clip-art.png",
          value["thumbnail_url"].toString(),
        ));
      } else {
        continue;
      }
    }
    return newPosts;
  }

  List<String> _shuffleData(List<String> items) {
    var random = Random();
    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  Future<List<String>> fetchData(int start, int count) async {
    if (_accessToken.isEmpty) {
      var db = await FirebaseDatabase.instance
          .reference()
          .child("access_token")
          .once();
      print(db.value);
      _accessToken = db.value.toString();
    }
    var db = await FirebaseDatabase.instance
        .reference()
        .child("links")
        .orderByKey()
        .startAt(start.toString())
        .limitToFirst(count)
        .once();
    print(db.value);
    List<String> newLinks = [];
    if (db.value is Map) {
      Map values = db.value;
      values.forEach((key, value) {
        if (value != null) {
          newLinks
              .add("https://www.instagram.com/p/" + value["link"].toString());
        }
      });
      return _shuffleData(newLinks);
    } else {
      List<dynamic> values = db.value;
      values.forEach((element) {
        if (element != null) {
          Map map = Map.from(element);
          newLinks.add("https://www.instagram.com/p/" + map["link"].toString());
        }
      });
      return _shuffleData(newLinks);
    }
  }
}
