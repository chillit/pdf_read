import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class MyWebView extends StatelessWidget {
  final String url;
  final String path;

  MyWebView({required this.url, required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadHtmlFromUrl(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          String htmlData = _removeLinks(snapshot.data!); // Remove links
          return WebView(
            backgroundColor: Color.fromRGBO(238, 232, 244, 255),
            initialUrl: '',
            onWebViewCreated: (WebViewController controller) {
              controller.loadUrl(Uri.dataFromString(
                '<html><head><style>body {font-size: 50px;}</style></head><body>$htmlData</body></html>',
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ).toString());
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<String> _loadHtmlFromUrl() async {
    final response = await http.get(Uri.parse(url));
    final document = parse(response.body);
    final element = document.querySelector(path);
    if (element != null) {
      return element.outerHtml;
    } else {
      return '<html><body>No data found</body></html>';
    }
  }

  String _removeLinks(String htmlString) {
    RegExp exp = RegExp(r"<a[^>]*>([^<]*)<\/a>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAllMapped(exp, (match) {
      return match.group(1) ?? ''; // Возвращаем текст ссылки
    });
  }
}
