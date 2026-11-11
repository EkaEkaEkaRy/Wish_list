import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Future<Uint8List?> loadImage(String? imagePath) async {
  try {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('Ошибка загрузки изображения: $e');
  }
  return null;
}
