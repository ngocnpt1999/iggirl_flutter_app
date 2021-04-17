import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/listgirlpage.dart';
import 'package:iggirl_flutter_app/model/database.dart';
import 'package:iggirl_flutter_app/pageviewpage.dart';
import 'package:iggirl_flutter_app/swipecardspage.dart';

class HomeController extends GetxController {
  HomeController() {
    _controller = Get.put(ListPostController());
    widgets = <Widget>[
      PageViewPage(),
      ListGirlPage(),
      SwipeCardsPage(),
    ];
  }

  ListPostController _controller; //don't remove this line

  var selectedWidget = 0.obs;

  List<Widget> widgets;

  void changeTab(int value) {
    selectedWidget.value = value;
  }
}

class ListPostController extends GetxController {
  ListPostController();

  int _start = 0;

  bool _isBusy = false;

  var listPost = <Post>[].obs;

  void loadNewPosts(int num) {
    if (_isBusy == true) {
      return;
    }
    //
    _isBusy = true;
    Database().fetchData(_start, num).then((links) async {
      List<Post> newPosts = await Database().getNewPosts(links);
      listPost.addAll(newPosts);
      _isBusy = false;
      _start += num;
      print("Counter: $_start");
    });
  }
}
