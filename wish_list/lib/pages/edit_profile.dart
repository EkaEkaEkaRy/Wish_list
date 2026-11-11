import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wish_list/database/supabase/supabase_user.dart';
import 'package:wish_list/auth/auth_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.name, required this.image});
  final String? name;
  final String? image;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _image;
  String? _imagePath;

  final userId = AuthService().getCurrentUserId();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.image;
    _controller.text = widget.name!;
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _image = imageData;
        _imagePath = null;
      });
    }
  }

  void _addNote() async {
    if (_controller.text.isNotEmpty) {
      if (_imagePath != null) {
        await SupabaseUserService()
            .updateProfile(userId!, _controller.text, null, null);
      } else {
        await SupabaseUserService()
            .updateProfile(userId!, _controller.text, widget.image, _image);
      }
      if (!mounted) return null;
      Navigator.pop(context);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Есть незаполненные поля'),
        backgroundColor: Color.fromARGB(255, 252, 2, 105),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Редактировать профиль',
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
              child: SizedBox(
                height: 45.0,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Имя',
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
                ? Image.memory(_image!, height: 100)
                : Image.network(_imagePath!, height: 100),
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
