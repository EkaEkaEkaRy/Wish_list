import 'dart:typed_data';
import 'dart:convert';

// из картинки в текст

Future<Uint8List?> getImageFromDatabase(image) async {
  if (image.isNotEmpty) {
    return image as Uint8List;
  }
  return null; // Возвращаем null, если изображение не найдено
}

String convertBlobToBase64(Uint8List? imageData) {
  if (imageData != null) {
    return base64Encode(imageData);
  }
  return '';
}

Future<String> getImageAsBase64(image) async {
  Uint8List? imageData = await getImageFromDatabase(image);
  return convertBlobToBase64(imageData);
}

// из текста в картинку

Uint8List decodeBase64(String base64String) {
  // Удаляем префикс, если он есть
  String cleanBase64 = base64String.split(',').last;
  return base64.decode(cleanBase64);
}

buildImageFromBase64(String base64String) {
  Uint8List imageBytes = decodeBase64(base64String);
  return imageBytes;
}
