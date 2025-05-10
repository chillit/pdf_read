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
import 'package:http/http.dart' as http;
import 'dart:convert';
class otherPdf extends StatefulWidget {
  final File file;
  final String source;
  final String target;

  otherPdf({required this.file, required this.source, required this.target});

  @override
  _otherPdfState createState() => _otherPdfState();
}

class _otherPdfState extends State<otherPdf> {
  String _currentUserUID = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  Future<String> translateText(String text, String sourceLang, String targetLang) async {
    print(text);
    const url = 'https://swift-translate.p.rapidapi.com/translate';
    const headers = {
      'Content-Type': 'application/json',
      'X-RapidAPI-Key': 'b728a92002msh7af4d272fe4b9eap153ae0jsn8e3402bb5fe9', // Use your actual RapidAPI key
      'X-RapidAPI-Host': 'swift-translate.p.rapidapi.com',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'text': text,
        'sourceLang': widget.source,
        'targetLang': widget.target,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translatedText'] ?? "Translation unavailable";
    } else {
      throw Exception('Failed to translate text.');
    }
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
  Future<String> fetchWordDefinition(String word) async {
    final String apiUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/$word";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        // Initialize an empty StringBuffer to accumulate the definitions, synonyms, and examples.
        StringBuffer buffer = StringBuffer();

        for (var entry in json) {
          for (var meaning in entry['meanings']) {
            if (meaning['definitions'] != null) {
              for (var definition in meaning['definitions']) {
                if (definition['definition'] != null) {
                  buffer.writeln('Definition: ${definition['definition']}\n');
                }
                if (definition['example'] != null) {
                  buffer.writeln('Example: ${definition['example']}\n');
                }
              }
            }
            if (meaning['synonyms'] != null) {
              buffer.writeln('Synonyms: ${meaning['synonyms'].join(', ')}\n');
            }
          }
        }

        // Check if buffer is empty, indicating no data was found.
        return buffer.isEmpty ? "No definition found." : buffer.toString();
      } else {
        return "Failed to load definition.";
      }
    } catch (e) {
      return "Error occurred: $e";
    }
  }

  void createUser({required String name,required String translate}) {
    final DatabaseReference _database = FirebaseDatabase.instance.reference();
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUID != null) {
      final fileName = widget.file.path.split('/').last;
      _database
          .child("users")
          .child(currentUserUID)
          .child("words")
          .child("other")
          .child(name)
          .update({translate:fileName});
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
          leading: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_outlined, color: Colors.brown),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          )
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(_currentUserNickname),
                    accountEmail: null,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text(AppLocalizations.of(context)!.home),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TextFilePicker()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.settings),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () {
                // Handle user logout
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            widget.file,
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
                        word = word.replaceAll(RegExp(r'[-,.\:;!?\—]'), '');
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
                                          leading: Icon(Icons.access_time),
                                          title: Text(AppLocalizations.of(context)!.translate),
                                          onTap: () async {
                                            try {
                                              final translatedText = await translateText(word, widget.source, widget.target); // Adjust source and target languages as needed
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(AppLocalizations.of(context)!.translate),
                                                  content: Text(translatedText),
                                                ),
                                              );
                                            } catch (e) {
                                              // Handle errors, perhaps show an error dialog
                                              print("Error translating text: $e");
                                            }
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
                      child: Text(AppLocalizations.of(context)!.translate)
                  ),
                  ElevatedButton(
                    onPressed: () async{
                      final translatedText = await translateText(word, widget.source, widget.target);
                      word = word.replaceAll(RegExp(r'[-,.\:;!?\—]'), '');
                      createUser(name: word, translate: translatedText);
                    },
                    child: Text(AppLocalizations.of(context)!.adddict),
                  ),
                  containsTwoOrMoreWords(word)?
                  ElevatedButton(
                    onPressed: () async{
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
