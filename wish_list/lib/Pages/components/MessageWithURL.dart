import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    bool launched = await launchUrl(uri);
    if (!launched) {
      throw 'Could not launch $url';
    }
  } catch (e) {
    // Обработка ошибки, если URL не удалось открыть
    print('Error: $e');
  }
}

void _copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

void _showPopupMenu(BuildContext context, String link) async {
  final RenderBox textBox = context.findRenderObject() as RenderBox;

  // Получаем позицию текста
  final Offset textPosition = textBox.localToGlobal(Offset.zero);

  // Определяем позицию меню
  final RelativeRect position = RelativeRect.fromLTRB(
    textPosition.dx,
    textPosition.dy - 50.0,
    textPosition.dx,
    textPosition.dy + 50,
  );

  final selectedValue = await showMenu<String>(
    context: context,
    position: position,
    color: const Color.fromARGB(255, 220, 235, 235),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    items: [
      PopupMenuItem<String>(
        value: 'Custom',
        height: 30.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 'Copy');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: const Text(
                  'Копировать',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            Container(
              width: 2,
              height: 30.0,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 'Nav');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Перейти',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  if (selectedValue != null) {
    if (selectedValue == 'Copy') {
      _copyToClipboard(link);
    } else if (selectedValue == 'Nav') {
      _launchURL(link);
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String message;

  MessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    // Регулярное выражение для поиска ссылок
    final RegExp urlRegExp = RegExp(
      r'(?:(?:https?|ftp):\/\/)?(?:www\.)?[\w\-]+(\.[\w\-]+)+([\/\w\-\.?=%&=]*)?(?=[\s\(\),;]|$)',
      caseSensitive: false,
      multiLine: false,
    );

    // Разделяем текст на части
    List<TextSpan> spans = [];
    message.splitMapJoin(urlRegExp, onMatch: (Match match) {
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 16),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _showPopupMenu(context, match.group(0)!);
          },
      ));
      return '';
    }, onNonMatch: (String nonMatch) {
      spans.add(TextSpan(text: nonMatch));
      return '';
    });

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: TextStyle(fontSize: 16, color: Colors.black),
        children: spans,
      ),
      softWrap: true,
    );
  }
}
