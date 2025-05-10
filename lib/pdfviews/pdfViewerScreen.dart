import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pdf_read/profile.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../main.dart';
import '../nWebView.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class PDFViewerScreen extends StatefulWidget {
  final File? file;

  PDFViewerScreen({required this.file});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _currentUserUID = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserUID = user.uid;
      });
      await _fetchUserNickname(user.uid);
    }
  }
  void createUser({required String name}) {
    final DatabaseReference _database = FirebaseDatabase.instance.reference();
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUID != null) {
      final fileName = widget.file!.path.split('/').last;
      _database
          .child("users")
          .child(currentUserUID)
          .child("words")
          .child("kz")
          .update({name: fileName});
    }
  }

  Future<void> _fetchUserNickname(String uid) async {
    final DatabaseReference _database = FirebaseDatabase.instance.reference();
    DatabaseEvent snapshot = await _database.child('users').child(uid).child('username').once();
    setState(() {
      _currentUserNickname = snapshot.snapshot.value.toString() ?? 'Unknown';
    });
    print(_currentUserNickname);
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showButton = false;
  late String word = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            widget.file!,
            enableTextSelection: true,
            onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              if (details.selectedText != null && details.selectedText!.isNotEmpty) { // Check if selectedText is not null
                setState(() {
                  showButton = true;
                  word = details.selectedText!;
                });
              } else {
                setState(() {
                  showButton = false;
                });
              }
            },
          ),
          if (showButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      word = word.replaceAll(RegExp(r'[^АаӘәБбВвГгҒғДдЕеЁёЖжЗзИиЙйКкҚқЛлМмНнҢңОоӨөПпРрСсТтУуҰұҮүФфХхҺһЦцЧчШшЩщЪъЫыІіЬьЭэЮюЯя]'), '');
                      print(word);
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200.0,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.selectcon,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.access_alarm),
                                        title: Text(AppLocalizations.of(context)!.deff),
                                        onTap: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) => StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return AlertDialog(
                                                  title: Text(word, textAlign: TextAlign.center,),
                                                  content: MyWebView(url: 'https://sozdikqor.kz/search?q=${word}', path: 'body > section > div > div > div.col-lg-8 > div'),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.accessibility),
                                        title: Text(AppLocalizations.of(context)!.rudeff),
                                        onTap: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) => StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return AlertDialog(
                                                  title: Text(word),
                                                  content: MyWebView(url: 'https://sozdik.kz/kk/dictionary/translate/kk/ru/${word}/', path: '#dictionary_translate_article_translation'),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.translate),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      word = word.replaceAll(RegExp(r'[^АаӘәБбВвГгҒғДдЕеЁёЖжЗзИиЙйКкҚқЛлМмНнҢңОоӨөПпРрСсТтУуҰұҮүФфХхҺһЦцЧчШшЩщЪъЫыІіЬьЭэЮюЯя]'), '');
                      createUser(name: word);
                    },
                    child: Text(AppLocalizations.of(context)!.adddict),
                  ),
                  containsTwoOrMoreWords(word)?
                  ElevatedButton(
                    onPressed: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        DatabaseReference dbRef = FirebaseDatabase.instance.reference();
                        String uid = user.uid;
                        DatabaseReference userPhrasesRef = dbRef.child('users/$uid/phrases');
                        userPhrasesRef.push().set(word).then((_) {
                          print("Фраза успешно добавлена");
                        }).catchError((error) {
                          print("Произошла ошибка при добавлении фразы: $error");
                        });
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.phrase),
                  ):SizedBox(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}