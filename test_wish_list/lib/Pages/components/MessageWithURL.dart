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
  // Показать уведомление о копировании
  print('Скопировано в буфер обмена: $text');
}

class MessageWidget extends StatelessWidget {
  final String message;

  MessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    // Регулярное выражение для поиска ссылок
    final RegExp urlRegExp = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
      multiLine: false,
    );

    // Разделяем текст на части
    List<TextSpan> spans = [];
    message.splitMapJoin(urlRegExp, onMatch: (Match match) {
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 16),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _copyToClipboard(
                match.group(0)!); // Копирование ссылки в буфер обмена
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
