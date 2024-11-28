import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_wish_list/Pages/MyFriendPage.dart';
import 'package:test_wish_list/Pages/MyWishListPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://zrzodthyrvvusvrkybzs.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpyem9kdGh5cnZ2dXN2cmt5YnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIwOTc4NzIsImV4cCI6MjA0NzY3Mzg3Mn0.wu0JSUY_w5K72qKwyVvgVGn1owEuOqxEjzPlZfgNGqM');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  static List<Widget> widgetOptions = <Widget>[];

  void onTab(int i) {
    setState(() {
      selectedIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    widgetOptions = [MyWishListPage(), FriendWishListPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 220, 235, 235),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Мой виш лист'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Мой друг')
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 197, 191),
        unselectedItemColor: const Color.fromARGB(255, 180, 180, 180),
        onTap: onTab,
      ),
    );
  }
}
