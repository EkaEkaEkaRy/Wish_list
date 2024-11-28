import 'package:flutter/material.dart';
import 'package:test_wish_list/Database/DBserviceMyList.dart';
import 'package:test_wish_list/Pages/AddNodePage.dart';
import 'package:test_wish_list/Pages/components/MessageWithURL.dart';
import 'package:test_wish_list/Database/SupabaseService.dart';
import 'dart:io';

class MyWishListPage extends StatefulWidget {
  @override
  _MyWishListPageState createState() => _MyWishListPageState();
}

class _MyWishListPageState extends State<MyWishListPage> {
  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    return await DatabaseHelper.instance.fetchWishListItems();
  }

  void _deleteNote(int id, String? image) async {
    await DatabaseHelper.instance.deleteWishListItem(id, image);
    setState(() {});
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
                child: Image.file(File(image),
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

  void _exportData() {
    saveDateFromMyList(context);
    setState(() {});
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
          _deleteNote(i, image);
        });
      }
    });
  }

  void _exportDataAccess(BuildContext context) {
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
                'Экспортировать виш лист?',
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
          _exportData();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All I want for Christmas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 197, 191), // #FC0269
      ),
      body: Container(
        color: const Color.fromARGB(255, 220, 235, 235),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => {_exportDataAccess(context)},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 0, 197, 191), // #FC0269
                ),
                child: const Text(
                  'Экспорт данных',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchNotes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Ошибка загрузки заметок'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Нет заметок'));
                    }

                    final notes = snapshot.data!;

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 255, 255, 255), // #FFD7E8
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 239, 218, 227),
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          child: MessageWidget(
                                              message: note['item']),
                                        ),
                                        if (note['image'] != null)
                                          GestureDetector(
                                            onTap: () => {
                                              _showImage(
                                                  note['image'], context),
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Container(
                                                height: 100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.65,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Image.file(
                                                    File(note['image']),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color:
                                              Color.fromARGB(255, 252, 2, 105)),
                                      onPressed: () => _remItem(
                                          note['id'], note['image'], context),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      },
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNotePage()),
          );
          setState(() {});
        },
        backgroundColor: const Color.fromARGB(255, 0, 197, 191), // #00C5BF
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
