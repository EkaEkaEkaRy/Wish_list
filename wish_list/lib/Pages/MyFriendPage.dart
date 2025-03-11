import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wish_list/Database/SupabaseList.dart';
import 'package:wish_list/Pages/components/MessageWithURL.dart';
import 'package:wish_list/auth/auth_service.dart';

class FriendWishListPage extends StatefulWidget {
  const FriendWishListPage(
      {super.key,
      required this.user_id,
      required this.user_name,
      required this.user_image});
  final String user_id;
  final String user_name;
  final String user_image;
  @override
  _FriendWishListPageState createState() => _FriendWishListPageState();
}

class _FriendWishListPageState extends State<FriendWishListPage> {
  final userId = AuthService().getCurrentUserId();
  bool checkBoxHide = false;
  late PostgrestList selest_list_wishes;
  late PostgrestList wishes;
  bool isWishesInitialized = true;

  @override
  void initState() {
    super.initState();
    SupabaseListServer()
        .selectFriendsList(userId, widget.user_id)
        .then((value) => {
              selest_list_wishes = value,
              wishes = value,
              isWishesInitialized = false,
              setState(() {})
            });
  }

  void _checkboxChange(id, value) async {
    if (value) {
      await SupabaseListServer().CheckboxFalse(userId!, id);
      setState(() {
        selest_list_wishes[selest_list_wishes
            .indexWhere((item) => item['id'] == id)]['checkbox_exists'] = false;
        selest_list_wishes[selest_list_wishes
            .indexWhere((item) => item['id'] == id)]['count'] -= 1;
        wishes = selest_list_wishes;
      });
    } else {
      await SupabaseListServer().CheckboxTrue(userId!, id);
      setState(() {
        selest_list_wishes[selest_list_wishes
            .indexWhere((item) => item['id'] == id)]['checkbox_exists'] = true;
        wishes[wishes.indexWhere((item) => item['id'] == id)]
            ['checkbox_exists'] = true;
        wishes[selest_list_wishes.indexWhere((item) => item['id'] == id)]
            ['count'] += 1;
        if (checkBoxHide) {
          wishes = wishes.where((item) => item['id'] != id).toList();
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.11,
              height: MediaQuery.of(context).size.width * 0.11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    width: 1.0),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.user_image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(
              widget.user_name,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 0, 197, 191),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 220, 235, 235),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: checkBoxHide,
                          onChanged: (value) {
                            checkBoxHide = !checkBoxHide;
                            setState(() {
                              wishes = checkBoxHide
                                  ? selest_list_wishes
                                      .where((note) =>
                                          note['checkbox_exists'] == false)
                                      .toList()
                                  : selest_list_wishes;
                            });
                          },
                          activeColor: const Color.fromARGB(255, 252, 2, 105),
                          checkColor: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        const Text(
                          'скрыть помеченные',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isWishesInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : wishes.length == 0
                        ? const Center(child: Text('Нет желаний'))
                        : ListView.builder(
                            itemCount: wishes.length,
                            itemBuilder: (context, index) {
                              final note = wishes[index];
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 239, 218, 227),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Checkbox(
                                                value: wishes[wishes.indexWhere(
                                                            (item) =>
                                                                item['id'] ==
                                                                note['id'])]
                                                        ['checkbox_exists']
                                                    ? true
                                                    : false,
                                                onChanged: (value) {
                                                  _checkboxChange(
                                                      note['id'],
                                                      wishes[wishes.indexWhere(
                                                              (item) =>
                                                                  item['id'] ==
                                                                  note['id'])]
                                                          ['checkbox_exists']);
                                                },
                                                activeColor:
                                                    const Color.fromARGB(
                                                        255, 252, 2, 105),
                                                checkColor:
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.55,
                                                        child: MessageWidget(
                                                            message: note[
                                                                'message']),
                                                      ),
                                                      if (note['image'] != null)
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _showImage(
                                                                  note['image'],
                                                                  context),
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
                                                                  0.55,
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Image
                                                                    .network(note[
                                                                        'image']),
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
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Копировать',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ];
                                                    },
                                                    onSelected: (String value) {
                                                      if (value == 'Copy') {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: wishes[
                                                                        index][
                                                                    'message']));
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          note['count'] != 0
                                              ? Text(
                                                  "Отмечено раз: ${note['count']}")
                                              : SizedBox()
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
    );
  }
}
