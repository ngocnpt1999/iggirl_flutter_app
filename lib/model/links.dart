import 'package:http/http.dart';
import 'dart:convert';

class Link {
  String uri;

  Link.fromJson(Map value) {
    this.uri = "https://www.instagram.com/p/" + value["link"].toString();
  }
}

class Database {
  static final Database _singleton = Database._internal();

  factory Database() => _singleton;

  Database._internal();

  List<Link> parseLinks(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map>();

    return parsed.map<Link>((json) => Link.fromJson(json)).toList();
  }

  Future<List<Link>> fetchLinks(Client client) async {
    final response = await client
        .get('https://fir-946df.firebaseio.com/shortlinks/links.json');

    return parseLinks(response.body);
  }
}
