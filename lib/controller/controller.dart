import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/listgirlpage.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:iggirl_flutter_app/pageviewpage.dart';
import 'package:iggirl_flutter_app/swipecardspage.dart';

class NavigationTabController extends GetxController {
  NavigationTabController();

  var selectedWidget = 0.obs;

  List<Widget> widgets = <Widget>[
    PageViewPage(),
    ListGirlPage(),
    SwipeCardsPage(),
  ];

  void changeTab(int value) {
    selectedWidget.value = value;
  }
}

class ListPostController extends GetxController {
  ListPostController();

  int _counter = 0;

  bool _isBusy = false;

  var listPost = List<Post>().obs;

  void loadNewPosts(int number) {
    if (_isBusy == true) {
      return;
    }

    _isBusy = true;
    Database().fetchData(_counter, number).whenComplete(() async {
      List<Post> newPosts = await Database().getNewPosts();
      listPost.addAll(newPosts);
      _isBusy = false;
      _counter += number;
      print("Counter: $_counter");
    });
  }
}
