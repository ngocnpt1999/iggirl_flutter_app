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

  List<String> _links = List();

  Future<List<Post>> getNewPosts() async {
    Client client = new Client();
    List<Post> newPosts = new List();
    for (int i = 0; i < _links.length; i++) {
      try {
        var response = await client
            .get("https://api.instagram.com/oembed/?url=" + _links[i]);
        if (response.statusCode == 200) {
          var value = json.decode(response.body);
          newPosts.add(new Post(
              value["author_name"].toString(),
              "https://f0.pngfuel.com/png/863/426/instagram-logo-png-clip-art.png",
              _links[i] + "/media/?size=m"));
        }
      } catch (ex) {
        print(ex);
        continue;
      }
    }
    _links.clear();
    return newPosts;
  }

  List<String> _shuffleData(List<String> items) {
    var random = new Random();
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
    if (_links.length > 0) {
      return _links;
    }

    final db = await FirebaseDatabase.instance
        .reference()
        .child("shortlinks/links")
        .orderByKey()
        .startAt(start.toString())
        .limitToFirst(count)
        .once();
    print(db.value);
    if (db.value is Map) {
      Map values = db.value;
      List<String> newLinks = new List();
      values.forEach((key, value) {
        if (value != null) {
          newLinks
              .add("https://www.instagram.com/p/" + value["link"].toString());
        }
      });
      return _links = _shuffleData(newLinks);
    } else {
      List<dynamic> values = db.value;
      List<String> newLinks = new List();
      values.forEach((element) {
        if (element != null) {
          Map map = Map.from(element);
          newLinks.add("https://www.instagram.com/p/" + map["link"].toString());
        }
      });
      return _links = _shuffleData(newLinks);
    }
  }
}
