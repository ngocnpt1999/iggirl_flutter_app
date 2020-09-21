import 'dart:math';
import 'package:http/http.dart';
import 'dart:convert';

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

  Future<List<Link>> init() async {
    Client client = new Client();
    links = await _fetchLinks(client);
    return links;
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
