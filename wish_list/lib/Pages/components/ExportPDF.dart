import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui';

Future<void> generatePdf(List<Map<String, dynamic>> items) async {
  // Загрузите шрифт из assets
  final ByteData fontData =
      await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final Uint8List fontBytes = fontData.buffer.asUint8List();

  // Создайте TrueType шрифт
  final PdfFont font = PdfTrueTypeFont(fontBytes, 12);

  // Создайте PDF-документ
  PdfDocument document = PdfDocument();
  PdfPage page = document.pages.add();
  PdfGraphics graphics = page.graphics;
  Size pageSize = page.getClientSize(); // Получаем размеры страницы
  double yOffset = 0;
  double margin = 20; // Отступы

  for (int i = 0; i < items.length; i++) {
    // Вычисляем высоту элемента (текст + картинка)
    double elementHeight = 20; // Высота текста
    if (items[i]["image"] != null && items[i]["image"].isNotEmpty) {
      elementHeight += 110; // Высота картинки
    }

    // Проверяем, помещается ли элемент на текущей странице
    if (yOffset + elementHeight + margin > pageSize.height) {
      // Создаем новую страницу
      page = document.pages.add();
      graphics = page.graphics;
      pageSize = page.getClientSize();
      yOffset = margin; // Сбрасываем отступ
    }

    // Добавьте название элемента
    graphics.drawString(
      '${i + 1}. ${items[i]["message"]}',
      font,
      bounds: Rect.fromLTWH(0, yOffset, page.getClientSize().width, 20),
    );

    yOffset += 20;

    // Если есть ссылка на изображение, загрузите и добавьте его в PDF
    if (items[i]["image"] != null && items[i]["image"].isNotEmpty) {
      var response = await http.get(Uri.parse(items[i]["image"]));
      if (response.statusCode == 200) {
        PdfBitmap image = PdfBitmap(response.bodyBytes);
        graphics.drawImage(
          image,
          Rect.fromLTWH(0, yOffset, 100, 100), // Размер изображения
        );
        yOffset += 110; // Смещение для следующего элемента
      }
    } else {
      yOffset +=
          20; // Если изображения нет, увеличьте смещение только для текста
    }
  }

  // Сохраните документ в файл или передайте его пользователю
  // Сохраните PDF и преобразуйте в Uint8List
  List<int> bytes = await document.save();
  Uint8List pdfBytes = Uint8List.fromList(bytes); // Ключевая строка!
  document.dispose();

  // Сохранение через FilePicker
  String? outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Сохранить PDF',
    fileName: 'MyWishList.pdf',
    allowedExtensions: ['pdf'],
    bytes: pdfBytes,
  );

  if (outputPath != null) {
    print('Файл сохранён: $outputPath');
  }
}
