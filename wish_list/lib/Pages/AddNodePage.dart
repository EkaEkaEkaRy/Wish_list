import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:wish_list/Database/SupabaseList.dart';
import 'package:wish_list/auth/auth_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage(
      {super.key, this.wish_index, this.wish_text, this.wish_image_path});
  final int? wish_index;
  final String? wish_text;
  final String? wish_image_path;

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _image;
  String? _image_path;

  final userId = AuthService().getCurrentUserId();

  @override
  void initState() {
    super.initState();
    if (widget.wish_image_path != null) _image_path = widget.wish_image_path;
    if (widget.wish_text != null) _controller.text = widget.wish_text!;
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Используем асинхронный метод readAsBytes
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _image = imageData;
        _image_path = null;
      });
    }
  }

  void _addNote() async {
    if (_controller.text.isNotEmpty) {
      final isTrue = await SupabaseListServer()
          .existsWishFromWishList(widget.wish_index, userId, _controller.text);
      if (isTrue) {
        if (widget.wish_index == null) {
          await SupabaseListServer()
              .insertWishListItem(userId!, _controller.text, _image);
          Navigator.pop(context);

          setState(() {});
        } else {
          if (_image_path != null) {
            await SupabaseListServer().updateWishListItem(
                widget.wish_index!, _controller.text, null, null);
          } else {
            await SupabaseListServer().updateWishListItem(widget.wish_index!,
                _controller.text, widget.wish_image_path, _image);
          }
          Navigator.pop(context);
          setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Такое желание уже существует'),
          backgroundColor: Color.fromARGB(255, 252, 2, 105),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Добавить Желание',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 197, 191),
      ),
      body: Container(
        color: const Color.fromARGB(255, 220, 235, 235),
        child: Center(
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: TextField(
                minLines: 1,
                maxLines: 10,
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Введите что-то...',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 239, 218, 227),
                      fontSize: 15.0),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFFC0269),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 239, 218, 227),
                      width: 1.0,
                    ),
                  ),
                ),
                cursorHeight: 20,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 197, 191),
              ),
              child: const Text(
                'Выбрать изображение',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
            const SizedBox(height: 10),
            _image != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.memory(_image!, height: 100),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          icon: Icon(Icons.cancel_outlined))
                    ],
                  )
                : _image_path != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(_image_path!, height: 100),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _image_path = null;
                                });
                              },
                              icon: Icon(Icons.cancel_outlined))
                        ],
                      )
                    : const SizedBox(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 197, 191),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
