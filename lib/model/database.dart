import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:iggirl_flutter_app/main.dart';

class Link {
  String uri;

  Link.fromJson(Map value) {
    this.uri = "https://www.instagram.com/p/" + value["link"].toString();
  }
}

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

  List<Link> links;

  void init() {
    Client client = new Client();
    _fetchLinks(client)
        .then((List<Link> value) => links = value)
        .whenComplete(() {
      runApp(MyApp());
    });
  }

  List<Link> _shuffleLinks(List<Link> items) {
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

  List<Link> _parseLinks(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map>();
    return parsed.map<Link>((json) => Link.fromJson(json)).toList();
  }

  Future<List<Link>> _fetchLinks(Client client) async {
    final response = await client
        .get('https://fir-946df.firebaseio.com/shortlinks/links.json');
    return _shuffleLinks(_parseLinks(response.body));
  }
}
