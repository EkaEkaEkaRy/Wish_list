import 'package:flutter/material.dart';
import 'package:wish_list/Pages/FriendsPage.dart';
import 'package:wish_list/Pages/MyWishListPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 1;
  static List<Widget> widgetOptions = <Widget>[];

  void onTab(int i) {
    setState(() {
      selectedIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    widgetOptions = [FriendsPage(), MyWishListPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 220, 235, 235),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Мои друзья'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Мой виш лист'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 197, 191),
        unselectedItemColor: const Color.fromARGB(255, 180, 180, 180),
        onTap: onTab,
      ),
    );
  }
}
