import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:wish_list/database/supabase/supabase_list.dart';
import 'package:wish_list/auth/auth_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage(
      {super.key, this.wishIndex, this.wishText, this.wishImagePath});
  final int? wishIndex;
  final String? wishText;
  final String? wishImagePath;

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _image;
  String? _imagePath;

  final userId = AuthService().getCurrentUserId();

  @override
  void initState() {
    super.initState();
    if (widget.wishImagePath != null) _imagePath = widget.wishImagePath;
    if (widget.wishText != null) _controller.text = widget.wishText!;
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Используем асинхронный метод readAsBytes
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _image = imageData;
        _imagePath = null;
      });
    }
  }

  void _addNote() async {
    if (_controller.text.isNotEmpty) {
      final isTrue = await SupabaseListServer()
          .existsWishFromWishList(widget.wishIndex, userId, _controller.text);
      if (isTrue) {
        if (widget.wishIndex == null) {
          await SupabaseListServer()
              .insertWishListItem(userId!, _controller.text, _image);
          if (!mounted) return null;
          Navigator.pop(context);

          setState(() {});
        } else {
          if (_imagePath != null) {
            await SupabaseListServer().updateWishListItem(
                widget.wishIndex!, _controller.text, null, null);
          } else {
            await SupabaseListServer().updateWishListItem(widget.wishIndex!,
                _controller.text, widget.wishImagePath, _image);
          }
          if (!mounted) return null;
          Navigator.pop(context);
          setState(() {});
        }
      } else {
        if (!mounted) return null;
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
                : _imagePath != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(_imagePath!, height: 100),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _imagePath = null;
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
