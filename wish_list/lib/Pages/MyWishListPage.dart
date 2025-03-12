import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wish_list/Database/SupabaseList.dart';
import 'package:wish_list/Database/SupabaseUser.dart';
import 'package:wish_list/Pages/AddNodePage.dart';
import 'package:wish_list/Pages/EditProfile.dart';
import 'package:wish_list/Pages/components/ExportPDF.dart';
import 'package:wish_list/Pages/components/MessageWithURL.dart';
import 'package:flutter/services.dart';
import 'package:wish_list/auth/auth_service.dart';

class MyWishListPage extends StatefulWidget {
  @override
  _MyWishListPageState createState() => _MyWishListPageState();
}

class _MyWishListPageState extends State<MyWishListPage> {
  final authService = AuthService();
  final user_id = AuthService().getCurrentUserId();
  late PostgrestList wishes;
  bool isWishesInitialized = true;

  @override
  void initState() {
    super.initState();
    SupabaseListServer().selectWishList(user_id).then((value) =>
        {wishes = value, isWishesInitialized = false, setState(() {})});
  }

  void _navToEdit(int id, String text, String? image_path) async {
    isWishesInitialized = true;
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddNotePage(
              wish_index: id, wish_text: text, wish_image_path: image_path)),
    );
    setState(() {
      SupabaseListServer().selectWishList(user_id).then((value) =>
          {wishes = value, isWishesInitialized = false, setState(() {})});
    });
  }

  void _showImage(image, BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(image,
                    width: MediaQuery.of(context).size.width * 0.9),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Ок',
                style: TextStyle(color: Colors.black, fontSize: 14.0)),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  void _remItem(int i, String? image, BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: const Padding(
            padding: EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
            child: Center(
              child: Text(
                'Удалить желание?',
                style: TextStyle(fontSize: 16.00, color: Colors.black),
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 252, 2, 105)),
            child: const Text('Ок',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255), fontSize: 14.0)),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          TextButton(
            child: const Text('Отмена',
                style: TextStyle(color: Colors.black, fontSize: 14.0)),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    ).then((bool? isDeleted) {
      if (isDeleted != null && isDeleted) {
        setState(() {
          SupabaseListServer().deleteWishListItem(i, image);
          wishes = wishes.where((item) => item['id'] != i).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I\'ll tell you what I want',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 197, 191), // #FC0269
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      endDrawer: BurgerMenu(
        wishlist: isWishesInitialized ? [] : wishes,
      ),
      body: Container(
        color: const Color.fromARGB(255, 220, 235, 235),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: isWishesInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : wishes.length == 0
                        ? const Center(child: Text('Нет желаний'))
                        : ListView.builder(
                            itemCount: wishes.length + 1,
                            itemBuilder: (context, index) {
                              return index == wishes.length
                                  ? const SizedBox(
                                      height: 50,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 239, 218, 227),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.65,
                                                      child: MessageWidget(
                                                          message: wishes[index]
                                                              ['message']),
                                                    ),
                                                    if (wishes[index]
                                                            ['image'] !=
                                                        null)
                                                      GestureDetector(
                                                        onTap: () => {
                                                          _showImage(
                                                              wishes[index]
                                                                  ['image'],
                                                              context),
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Container(
                                                            height: 100,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.65,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child:
                                                                  Image.network(
                                                                wishes[index]
                                                                    ['image'],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Color.fromARGB(
                                                        255, 252, 2, 105),
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return [
                                                      const PopupMenuItem<
                                                          String>(
                                                        value: 'Copy',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.copy,
                                                              size: 17,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      252,
                                                                      2,
                                                                      105),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Копировать',
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem<
                                                          String>(
                                                        value: 'Edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .edit_document,
                                                              size: 17,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      252,
                                                                      2,
                                                                      105),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Редактировать',
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem<
                                                          String>(
                                                        value: 'Delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.delete,
                                                              size: 17,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      252,
                                                                      2,
                                                                      105),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Удалить',
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ];
                                                  },
                                                  onSelected: (String value) {
                                                    if (value == 'Copy') {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: wishes[
                                                                      index]
                                                                  ['message']));
                                                    } else if (value ==
                                                        'Edit') {
                                                      _navToEdit(
                                                          wishes[index]['id'],
                                                          wishes[index]
                                                              ['message'],
                                                          wishes[index]
                                                              ['image']);
                                                    } else if (value ==
                                                        'Delete') {
                                                      _remItem(
                                                          wishes[index]['id'],
                                                          wishes[index]
                                                              ['image'],
                                                          context);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          isWishesInitialized = true;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNotePage()),
          );
          setState(() {
            SupabaseListServer().selectWishList(user_id).then((value) =>
                {wishes = value, isWishesInitialized = false, setState(() {})});
          });
        },
        backgroundColor: const Color.fromARGB(255, 0, 197, 191), // #00C5BF
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class BurgerMenu extends StatefulWidget {
  const BurgerMenu({super.key, required this.wishlist});
  final wishlist;
  @override
  State<BurgerMenu> createState() => _BurgerMenuState();
}

class _BurgerMenuState extends State<BurgerMenu> {
  final user_id = AuthService().getCurrentUserId();
  late PostgrestList user_info;
  bool isUserInitialized = true;

  @override
  void initState() {
    super.initState();
    SupabaseUserService().getUser(user_id).then((value) =>
        {user_info = value, isUserInitialized = false, setState(() {})});
  }

  void _navToEditProfile(String name, String? image_path) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(name: name, image: image_path)),
    );
    setState(() {});
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0))),
      child: Container(
        color: Color.fromARGB(255, 220, 235, 235),
        child: Column(children: [
          Container(
            color: const Color.fromARGB(255, 0, 197, 191),
            height: MediaQuery.of(context).size.height * 0.35,
            child: isUserInitialized
                ? const Center(child: CircularProgressIndicator())
                : user_info.length != 1
                    ? const Center(child: Text('Ошибка загрузки профиля'))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0, top: 20.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 2.0),
                              ),
                              child: ClipOval(
                                  child: Image.network(user_info[0]['image'],
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(user_info[0]['name'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GestureDetector(
                              onTap: () =>
                                  _copyToClipboard(user_info[0]['user_id']),
                              child: Row(
                                children: [
                                  Text(user_info[0]['user_id'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.0)),
                                  const SizedBox(width: 5.0),
                                  Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 18.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
          GestureDetector(
            onTap: () => isUserInitialized == false && user_info.length == 1
                ? _navToEditProfile(user_info[0]['name'], user_info[0]['image'])
                : {},
            child: SizedBox(
                height: 50.0,
                child: Center(
                    child: const Text('Редактировать профиль',
                        style: TextStyle(fontSize: 14.0)))),
          ),
          Container(height: 1, color: Colors.white),
          GestureDetector(
            onTap: () => generatePdf(widget.wishlist),
            child: SizedBox(
                height: 50.0,
                child: Center(
                    child: const Text('Экспортировать вишлист',
                        style: TextStyle(fontSize: 14.0)))),
          ),
          Container(height: 1, color: Colors.white),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: const Icon(Icons.exit_to_app, color: Colors.black),
                onTap: () {
                  AuthService().signOut();
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
