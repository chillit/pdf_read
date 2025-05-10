
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pdf_read/nWebView.dart';




class ClickableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Function(String) onWordTap;

  ClickableText({required this.text, required this.style, required this.onWordTap});

  @override
  _ClickableTextState createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  late List<TextSpan> _spans;

  @override
  void initState() {
    super.initState();
    _spans = _getTextSpans();
  }

  List<TextSpan> _getTextSpans() {
    List<TextSpan> spans = [];
    final words = widget.text.split(RegExp(r'[,.\\n\s]+'));
    final separators = widget.text.split(RegExp(r'[^\.,\\n\s]+')); // Разбиваем исходный текст на разделители между словами
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      spans.add(TextSpan(
        text: word,
        style: widget.style,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            widget.onWordTap(word);
          },
      ));
      if (i < separators.length - 1) { // Добавляем соответствующий разделитель между словами
        final separator = separators[i + 1];
        spans.add(TextSpan(text: separator, style: widget.style));
      }
    }
    return spans;
  }

  @override

  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _spans),
    );
  }
}
class MyWidget extends StatefulWidget {
  final String text;

  MyWidget({required this.text});

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class Textt extends StatelessWidget {
  final String text;

  Textt({required this.text});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyWidget(text: text),
    );
  }
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Center();
  }
}


