import 'dart:io';
import 'dart:typed_data';

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
    print('Ошибка загрузки изображения: $e');
  }
  return null;
}
