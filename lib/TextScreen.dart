import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf_read/text.dart';
import 'package:pdf_read/nWebView.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class TextScreen extends StatefulWidget {
  final String text;

  TextScreen({Key? key, required this.text}) : super(key: key);

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String traslatedword = "";
  bool _contentChanged = false;

  void _changeContent() {
    setState(() {
      _contentChanged = !_contentChanged;
    });
  }
  final PageController _pageController = PageController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _totalPages = _splitTextIntoPages().length;
    _pageController.addListener(_handlePageChange);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    int currentPage = (_pageController.page?.floor() ?? 0) + 1;
    setState(() {
      _currentPage = currentPage;
    });
  }

  List<String> _splitTextIntoPages({int characterCount = 1000}) {
    List<String> pages = [];

    for (int i = 0; i < widget.text.length; i += characterCount) {
      int endIndex = i + characterCount;
      String page = widget.text.substring(i, endIndex < widget.text.length ? endIndex : widget.text.length);
      pages.add(page);
    }

    return pages;
  }

  Widget _buildPage(String pageText) {
    String info = AppLocalizations.of(context)!.chooseweb;
    String cleanedText = pageText.replaceAll('\n', ' ');

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cleanedText,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontFamily: "NotoSans",
            ),
            textAlign: TextAlign.justify, // Выравнивание текста по ширине.
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<String> pages = _splitTextIntoPages();

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.textfrompdf} $_currentPage ${AppLocalizations.of(context)!.offff} $_totalPages'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          return _buildPage(pages[index]);
        },
        itemCount: pages.length,
      ),
    );

  }
}

Future createWord({required String name}) async{
  final docUser = FirebaseFirestore.instance.collection("words").doc(name);
  final json = {
    'name': name,
  };
  await docUser.set(json);
}
