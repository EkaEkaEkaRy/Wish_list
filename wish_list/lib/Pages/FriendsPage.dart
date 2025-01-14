import 'package:flutter/material.dart';
import 'package:wish_list/Database/SupabaseUser.dart';
import 'package:wish_list/Pages/MyFriendPage.dart';
import 'package:wish_list/auth/auth_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final userId = AuthService().getCurrentUserId();
  final TextEditingController _controller = TextEditingController();

  void _performSearch(BuildContext context) async {
    String query = _controller.text;
    final user_info =
        await SupabaseUserService().addFriend(context, userId, query);
    if (user_info != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FriendWishListPage(
                user_id: user_info['id'],
                user_name: user_info['name'],
                user_image: user_info['image'])),
      );
      _controller.text = '';
    }
    setState(() {});
  }

  void _navToFriendsPage(String id, String name, String image) async {
    SupabaseUserService().updateLastVisit(userId!, id);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendWishListPage(
              user_id: id, user_name: name, user_image: image)),
    );
    setState(() {});
  }

  Future<bool?> _confirmDelete(int index) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
              child: Center(
                child: Text(
                  'Удалить из списка друзей?',
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14.0)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'So tell me what you want',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 197, 191),
      ),
      body: Container(
        color: Color.fromARGB(255, 220, 235, 235),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: const Color.fromARGB(255, 0, 197, 191),
                        width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Введите код пользователя",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _performSearch(context),
                        icon: Icon(Icons.add,
                            color: const Color.fromARGB(255, 252, 2, 105)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: SupabaseUserService().selectFriends(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Ошибка загрузки пользователей'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Нет друзей'));
                    }
                    final notes = snapshot.data!;

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Dismissible(
                            key: Key(note['users_info']['name']),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _confirmDelete(index);
                            },
                            onDismissed: (direction) {
                              setState(() {
                                SupabaseUserService().deleteFriend(note['id']);
                              });
                            },
                            background: Container(
                              color: const Color.fromARGB(255, 252, 2, 105),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () => _navToFriendsPage(
                                  note['friend_id'],
                                  note['users_info']['name'],
                                  note['users_info']['image']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 239, 218, 227),
                                    width: 2.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 239, 218, 227),
                                              width: 2.0),
                                        ),
                                        child: ClipOval(
                                            child: Image.network(
                                                note['users_info']['image'],
                                                fit: BoxFit.cover)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15.0),
                                        child: Text(
                                          note['users_info']['name'],
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
