import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseListServer {
  Future<bool> existsWishFromWishList(int? id, userId, item) async {
    final supabase_wishes = await Supabase.instance.client
        .from('wishes')
        .select('id')
        .eq('user_id', userId)
        .eq('message', item)
        .count();

    if (supabase_wishes.count == 0) {
      return true;
    } else {
      if (id != null) {
        final find_wish = await Supabase.instance.client
            .from('wishes')
            .select()
            .eq('id', id)
            .eq('message', item)
            .count();
        if (find_wish.count == 1) return true;
      }
    }
    return false;
  }

  Future<PostgrestList> selectWishList(userId) {
    return Supabase.instance.client
        .from('wishes')
        .select('*')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
  }

  Future<void> insertWishListItem(
      String user_id, String item, Uint8List? image) async {
    if (image != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(fileName, image);

      final publicUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('wishes').insert({
        'user_id': user_id,
        'message': item,
        'image': publicUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String()
      });
    } else {
      await Supabase.instance.client.from('wishes').insert({
        'user_id': user_id,
        'message': item,
        'updated_at': DateTime.now().toUtc().toIso8601String()
      });
    }
  }

  Future<void> deleteWishListItem(int id, String? image) async {
    if (image != null) {
      String bucketName = 'images';
      String filePath = image.replaceFirst(
          'https://zrzodthyrvvusvrkybzs.supabase.co/storage/v1/object/public/$bucketName/',
          '');

      await Supabase.instance.client.storage.from('images').remove([filePath]);
    }
    await Supabase.instance.client.from('wishes').delete().eq('id', id);
  }

  Future<void> updateWishListItem(
      int id, String item, String? image_path, Uint8List? image) async {
    if (image_path != null) {
      String bucketName = 'images';
      String filePath = image_path.replaceFirst(
          'https://zrzodthyrvvusvrkybzs.supabase.co/storage/v1/object/public/$bucketName/',
          '');

      await Supabase.instance.client.storage.from('images').remove([filePath]);
    }
    if (image != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(fileName, image);

      final publicUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('wishes').update({
        'message': item,
        'image': publicUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String()
      }).eq('id', id);
    } else {
      await Supabase.instance.client.from('wishes').update({
        'message': item,
        'image': null,
        'updated_at': DateTime.now().toUtc().toIso8601String()
      }).eq('id', id);
    }
  }

  Future<PostgrestList> selectFriendsList(userId, friendId) async {
    final data = await Supabase.instance.client
        .from('wishes')
        .select('*, check_box!left(*)')
        .eq('user_id', friendId)
        .eq('check_box.user_id', userId)
        .order('updated_at', ascending: false);
    final wishesWithCheckboxStatus = data.map((wish) {
      return {
        ...wish,
        'checkbox_exists': wish['check_box'].toString().length > 5,
      };
    }).toList();
    return wishesWithCheckboxStatus;
  }

  Future<void> CheckboxTrue(String user_id, int id) async {
    await Supabase.instance.client
        .from('check_box')
        .insert({'wish_id': id, 'user_id': user_id});
  }

  Future<void> CheckboxFalse(String user_id, int id) async {
    await Supabase.instance.client
        .from('check_box')
        .delete()
        .eq('wish_id', id)
        .eq('user_id', user_id);
  }
}
