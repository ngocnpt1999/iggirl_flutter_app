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

  List<String> _links;

  Future<List<String>> init() async {
    _links = await _fetchData();
    return _links;
  }

  Future<List<Post>> getNewPosts(int number) async {
    List<String> links = new List();
    for (int i = 0; i < number; i++) {
      links.add(_links[0]);
      _links.removeAt(0);
    }
    Client client = new Client();
    List<Post> newPosts = new List();
    for (int i = 0; i < links.length; i++) {
      try {
        var response = await client
            .get("https://api.instagram.com/oembed/?url=" + links[i]);
        if (response.statusCode == 200) {
          var value = json.decode(response.body);
          newPosts.add(new Post(
              value["author_name"].toString(),
              "https://f0.pngfuel.com/png/863/426/instagram-logo-png-clip-art.png",
              links[i] + "/media/?size=l"));
        }
      } catch (ex) {
        print(ex);
        continue;
      }
    }
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

  Future<List<String>> _fetchData() async {
    final db = await FirebaseDatabase.instance
        .reference()
        .child("shortlinks/links")
        .once();
    List<dynamic> values = db.value;
    List<String> newLinks = new List();
    values.forEach((element) {
      Map map = Map.from(element);
      newLinks.add("https://www.instagram.com/p/" + map["link"].toString());
    });
    return _shuffleData(newLinks);
  }
}
