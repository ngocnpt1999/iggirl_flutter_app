import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iggirl_flutter_app/controller/state_management.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF212121),
        accentColor: Colors.white,
        accentIconTheme: IconThemeData(color: Colors.black),
        dividerColor: Colors.black12,
      ),
      themeMode: ThemeMode.system,
      home: MyHomePage(title: 'IGGirl'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final HomeController _pageController = HomeController();

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
                label: "ListView",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.layers),
                label: "TinderView",
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
