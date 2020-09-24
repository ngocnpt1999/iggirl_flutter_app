import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iggirl_flutter_app/listgirlpage.dart';
import 'package:iggirl_flutter_app/swipecardspage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IGGirl'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedWidget = 0;
  List<Widget> _widgets = <Widget>[
    ListGirlPage(),
    SwipeCardsPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgets[_selectedWidget],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            title: Text("List"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            title: Text("Swipe"),
          ),
        ],
        currentIndex: _selectedWidget,
        onTap: (value) {
          setState(() {
            _selectedWidget = value;
          });
        },
      ),
    );
  }
}
