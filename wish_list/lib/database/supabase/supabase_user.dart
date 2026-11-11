import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wish_list/Supabase_init.dart';

String generateUniqueString() {
  String milliseconds = DateTime.now().millisecondsSinceEpoch.toString();
  String alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  StringBuffer result = StringBuffer();

  for (int i = 0; i < milliseconds.length; i++) {
    if (milliseconds[i] == '0') {
      result.write('A');
      continue;
    }

    if (i + 1 < milliseconds.length) {
      String pair = milliseconds[i] + milliseconds[i + 1];
      int index = int.parse(pair);
      if (index < alphabets.length) {
        result.write(alphabets[index]);
        i++;
      } else {
        result.write(alphabets[int.parse(milliseconds[i])]);
        result.write(milliseconds[i + 1]);
        i++;
      }
    } else {
      result.write(milliseconds[i]);
    }
  }

  return result.toString();
}

void addUser(String mail, String name) async {
  try {
    final userExists = await Supabase.instance.client
        .from('users_info')
        .select('*')
        .eq('mail', mail)
        .count();
    if (userExists.count == 0) {
      String userId = generateUniqueString();
      await Supabase.instance.client.from('users_info').insert(
          {'id': userId, 'mail': mail, 'name': name, 'user_id': userId});
    }
  } catch (e) {
    debugPrint("Error: ${e.hashCode}");
  }
}

void updateUserID(String mail, String uid) async {
  try {
    final userId = await Supabase.instance.client
        .from('users_info')
        .select('id')
        .eq('mail', mail);
    if (userId.first['id'] != uid) {
      await Supabase.instance.client
          .from('users_info')
          .update({'id': uid}).eq('mail', mail);
    }
  } catch (e) {
    debugPrint("Error: ${e.hashCode}");
  }
}

class SupabaseUserService {
  Future<PostgrestList> selectFriends(userId) async {
    return await Supabase.instance.client
        .from('friends')
        .select('*, users_info (name, image)')
        .eq('user_id', userId)
        .order('visited_at', ascending: false);
  }

  Future<PostgrestList> getUser(userId) async {
    return await Supabase.instance.client
        .from('users_info')
        .select('*')
        .eq('id', userId);
  }

  Future<void> deleteFriend(id) async {
    await Supabase.instance.client.from('friends').delete().eq('id', id);
  }

  Future<PostgrestMap?> addFriend(BuildContext context, userId, userCod) async {
    final userInfo = await Supabase.instance.client
        .from('users_info')
        .select('id, name, image')
        .eq('user_id', userCod);

    if (userInfo.isNotEmpty) {
      if (userId != userInfo[0]['id']) {
        final friends = await Supabase.instance.client
            .from('friends')
            .select('id')
            .eq('user_id', userId)
            .eq('friend_id', userInfo[0]['id']);
        if (friends.isEmpty) {
          await Supabase.instance.client
              .from('friends')
              .insert({'user_id': userId, 'friend_id': userInfo[0]['id']});
        }
        return userInfo[0];
      } else {
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Невозможно добавить пользователя'),
          backgroundColor: Color.fromARGB(255, 252, 2, 105),
        ));
      }
    } else {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Пользователя не существует'),
        backgroundColor: Color.fromARGB(255, 252, 2, 105),
      ));
    }
    return null;
  }

  Future<void> updateLastVisit(String userId, String friendId) async {
    await Supabase.instance.client
        .from('friends')
        .update({'visited_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', userId)
        .eq('friend_id', friendId);
  }

  Future<void> updateProfile(
      String userId, String name, String? imagePath, Uint8List? image) async {
    if (image != null && imagePath != null) {
      String bucketName = 'users';
      String filePath = imagePath.replaceFirst(
          '$url/storage/v1/object/public/$bucketName/', '');
      if (filePath != 'user_default.png') {
        await Supabase.instance.client.storage
            .from('images')
            .remove([filePath]);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      await Supabase.instance.client.storage
          .from('users')
          .uploadBinary(fileName, image);

      final publicUrl =
          Supabase.instance.client.storage.from('users').getPublicUrl(fileName);

      await Supabase.instance.client.from('users_info').update({
        'name': name,
        'image': publicUrl,
      }).eq('id', userId);
    } else {
      await Supabase.instance.client.from('users_info').update({
        'name': name,
      }).eq('id', userId);
    }
  }
}
