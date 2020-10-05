import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/controller/controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(title: 'IGGirl'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final NavigationTabController _pageController = NavigationTabController();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: _pageController.widgets[_pageController.selectedWidget.value],
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.filter),
                label: "PageView",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: "List",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.layers),
                label: "Swipe",
              ),
            ],
            currentIndex: _pageController.selectedWidget.value,
            onTap: (value) {
              _pageController.changeTab(value);
            },
          ),
        ));
  }
}
