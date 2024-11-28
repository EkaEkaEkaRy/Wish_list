import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_wish_list/Database/DBserviceMyList.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void saveDateFromMyList(BuildContext context) async {
  final supabase_wishes = await Supabase.instance.client
      .from('wishes')
      .select('id, message, image')
      .eq('user_id', 1); // id пользователя

  List<Map<String, dynamic>> wishes =
      await DatabaseHelper.instance.fetchWishListItems();
  for (var i = 0; i < wishes.length; i++) {
    bool ToAdd = true;
    for (var j = 0; j < supabase_wishes.length; j++) {
      if (wishes[i]['item'] == supabase_wishes[j]['message']) ToAdd = false;
    }
    if (ToAdd) {
      if (wishes[i]['image'] != null) {
        File imageFile = File(wishes[i]['image']);
        // Загрузка изображения в Supabase Storage
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.png'; // Уникальное имя файла
        await Supabase.instance.client.storage
            .from('images')
            .upload(fileName, imageFile);

        final publicUrl = Supabase.instance.client.storage
            .from('images')
            .getPublicUrl(fileName);

        // Сохранение ссылки в таблице wish_list
        await Supabase.instance.client.from('wishes').insert({
          'user_id': 1, // id пользователя
          'message': wishes[i]['item'],
          'image': publicUrl
        });
      } else {
        await Supabase.instance.client.from('wishes').insert(
            {'user_id': 1, 'message': wishes[i]['item']}); // id пользователя
      }
    }
  }

  for (var j = 0; j < supabase_wishes.length; j++) {
    bool ToAdd = true;
    for (var i = 0; i < wishes.length; i++) {
      if (wishes[i]['item'] == supabase_wishes[j]['message']) ToAdd = false;
    }
    if (ToAdd) {
      if (supabase_wishes[j]['image'] != null) {
        String bucketName = 'images'; // Название вашего бакета
        String filePath = supabase_wishes[j]['image'].replaceFirst(
            'https://zrzodthyrvvusvrkybzs.supabase.co/storage/v1/object/public/$bucketName/',
            '');

        await Supabase.instance.client.storage
            .from('images')
            .remove([filePath]);
      }
      await Supabase.instance.client
          .from('wishes')
          .delete()
          .eq('id', supabase_wishes[j]['id']);
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Виш лист успешно отправлен'),
    backgroundColor: Color.fromARGB(255, 252, 2, 105),
  ));
}

void importFromSupabase(BuildContext context) async {
  final supabase_wishes = await Supabase.instance.client
      .from('wishes')
      .select('id, message, image')
      .eq('user_id', 2); // id пользователя

  List<Map<String, dynamic>> wishes =
      await DatabaseHelper.instance.fetchFriendWishListItems();

  for (var j = 0; j < supabase_wishes.length; j++) {
    bool ToAdd = true;
    for (var i = 0; i < wishes.length; i++) {
      if (wishes[i]['item'] == supabase_wishes[j]['message']) ToAdd = false;
    }
    if (ToAdd) {
      Uint8List? image_from_supabase;
      if (supabase_wishes[j]['image'] != null) {
        final response = await http.get(Uri.parse(supabase_wishes[j]['image']));
        image_from_supabase = response.bodyBytes;
      }
      await DatabaseHelper.instance.insertFriendWishListItem(
          supabase_wishes[j]['message'], image_from_supabase);
    }
  }

  for (var i = 0; i < wishes.length; i++) {
    bool ToAdd = true;
    for (var j = 0; j < supabase_wishes.length; j++) {
      if (wishes[i]['item'] == supabase_wishes[j]['message']) ToAdd = false;
    }
    if (ToAdd) {
      await DatabaseHelper.instance
          .deleteFriendWishListOneItem(wishes[i]['id'], wishes[i]['image']);
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Виш лист успешно загружен'),
    backgroundColor: Color.fromARGB(255, 252, 2, 105),
  ));
}
