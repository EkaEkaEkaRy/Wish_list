import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_wish_list/Database/DBserviceMyList.dart';
import 'dart:typed_data';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _image;

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Используем асинхронный метод readAsBytes
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _image = imageData;
      });
    }
  }

  void _addNote() async {
    if (_controller.text.isNotEmpty) {
      final isTrue =
          await DatabaseHelper.instance.findWishListItem(_controller.text);
      if (isTrue) {
        await DatabaseHelper.instance
            .insertWishListItem(_controller.text, _image);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Такое желание уже существует'),
          backgroundColor: Color.fromARGB(255, 252, 2, 105),
        ));
      }
      setState(() {});
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
                    color:
                        Color.fromARGB(255, 239, 218, 227), // Цвет текста метки
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(
                      255, 255, 255, 255), // Цвет фона поля ввода
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFFC0269), // Цвет границы при фокусе
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 239, 218,
                          227), // Цвет границы при неактивном состоянии
                      width: 1.0,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.black), // Цвет текста
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 0, 197, 191), // #FC0269
              ),
              child: const Text(
                'Выбрать изображение',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            if (_image != null) Image.memory(_image!, height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNote,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 0, 197, 191), // #FC0269
              ),
              child: const Text(
                'Добавить желание',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
