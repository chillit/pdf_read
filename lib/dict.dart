import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf_read/profile.dart';
import 'package:pdf_read/pdfviews/enPdfView.dart';
import 'package:pdf_read/pdfviews/pdfViewerScreen.dart';
import 'package:pdf_read/pdfviews/rupdfview.dart';
import 'main.dart';
import 'nWebView.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class dict extends StatefulWidget {
  @override
  State<dict> createState() => _dictState();
}

class _dictState extends State<dict> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserUID = "";
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  late DatabaseReference _database;
  String selectedLanguage = "kz";
  Widget _currentContent = Container(color: Color(0xFFDED9C2),);
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserUID = user.uid;
        _database = FirebaseDatabase.instance.reference().child('users').child(currentUserUID).child("words");
      });
    }
  }
  Future<void> _fetchUserLanguageData(String uid, String language) async {
    setState(() {
      selectedLanguage = language;
    });
    // Остальной код получения данных для нового языка
    DatabaseEvent snapshot = await _database.child('users').child(uid).child('username').child(language).once();
    // Дальнейшая обработка данных
  }

  String _currentUserUID = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setCurrentContent();
    _fetchUserDataa();
  }

  Future<void> _fetchUserDataa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserUID = user.uid;
      });
      await _fetchUserNickname(user.uid);
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
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translatedText'] ?? "Translation unavailable";
    } else {
      throw Exception('Failed to translate text.');
    }
  }

  void _setCurrentContent() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _database = FirebaseDatabase.instance.reference().child('users').child(currentUserUID).child("words").child("kz");

      setState(() {
        _currentContent = StreamBuilder(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
                child: Text('No data available'),
              );
            }

            Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> wordWidgets = [];

            values.forEach((key, value) {
              wordWidgets.add(
                ListTile(
                  title: Text(
                    key,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  subtitle: Text(
                    value,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  onTap: () {
                    key = key.replaceAll(RegExp(r'[^АаӘәБбВвГгҒғДдЕеЁёЖжЗзИиЙйКкҚқЛлМмНнҢңОоӨөПпРрСсТтУуҰұҮүФфХхҺһЦцЧчШшЩщЪъЫыІіЬьЭэЮюЯя]'), '');
                    print(key);
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
                                                title: Text(key),
                                                content: MyWebView(url: 'https://sozdikqor.kz/search?q=${key}', path: 'body > section > div > div > div.col-lg-8 > div'),
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
                                                title: Text(key),
                                                content: MyWebView(url: 'https://sozdik.kz/kk/dictionary/translate/kk/ru/${key}/', path: '#dictionary_translate_article_translation'),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.access_time),
                                      title: Text(AppLocalizations.of(context)!.translate),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) => StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              return AlertDialog(
                                                title: Text(key),
                                                content: Text(AppLocalizations.of(context)!.translate),
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
                ),
              );
            });

            return ListView(
              children: wordWidgets,
            );
          },
        );
      });
    }
  }
  void _setCurrentContentother() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _database = FirebaseDatabase.instance.reference().child('users').child(user.uid).child("words").child("other");

      setState(() {
        _currentContent = StreamBuilder(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
                child: Text('No data available'),
              );
            }

            Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> wordWidgets = [];

            values.forEach((key, valueMap) {
              // Проверка, является ли value Map'ом
              if (valueMap is Map) {
                valueMap.forEach((innerKey, innerValue) {
                  // Здесь innerKey и innerValue - это ключ и значение внутреннего Map
                  wordWidgets.add(
                    ListTile(
                      title: Text(
                        key.toString(),
                        style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                      ),
                      subtitle: Text(
                        innerValue.toString(),
                        style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                      ),
                      onTap: () {
                        key = key.replaceAll(RegExp(r'[-,.\:;!?\—]'), '');
                        print(key);
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
                                              final translatedText = innerKey; // Adjust source and target languages as needed
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
                    ),
                  );
                });
              }
            });

            return ListView(
              children: wordWidgets,
            );
          },
        );
      });
    }

  }
  void _setCurrentContentru() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _database = FirebaseDatabase.instance.reference().child('users').child(currentUserUID).child("words").child("ru");

      setState(() {
        _currentContent = StreamBuilder(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
                child: Text('No data available'),
              );
            }

            Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> wordWidgets = [];

            values.forEach((key, value) {
              wordWidgets.add(
                ListTile(
                  title: Text(
                    key,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  subtitle: Text(
                    value,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  onTap: () {
                    key = key.replaceAll(RegExp(r'[^АаӘәБбВвГгҒғДдЕеЁёЖжЗзИиЙйКкҚқЛлМмНнҢңОоӨөПпРрСсТтУуҰұҮүФфХхҺһЦцЧчШшЩщЪъЫыІіЬьЭэЮюЯя]'), '');
                    print(key);
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
                                      leading: Icon(Icons.accessibility),
                                      title: Text(AppLocalizations.of(context)!.rudeff),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) => StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              return AlertDialog(
                                                title: Text(key),
                                                content: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minWidth: 600, // Минимальная ширина
                                                    maxWidth: 800, // Максимальная ширина
                                                  ),

                                                  child: MyWebView(url: 'https://gufo.me/search?term=${key}', path: '#dictionary-search > article > div'),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.access_time),
                                      title: Text(AppLocalizations.of(context)!.translate),
                                      onTap: () async {
                                        try {
                                          final translatedText = await translateText(key, 'ru', 'en'); // Adjust source and target languages as needed
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
                ),
              );
            });

            return ListView(
              children: wordWidgets,
            );
          },
        );
      });
    }
  }
  void _setCurrentContenten() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _database = FirebaseDatabase.instance.reference().child('users').child(currentUserUID).child("words").child("en");

      setState(() {
        _currentContent = StreamBuilder(
          stream: _database.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(
                child: Text('No data available'),
              );
            }

            Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> wordWidgets = [];

            values.forEach((key, value) {
              wordWidgets.add(
                ListTile(
                  title: Text(
                    key,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  subtitle: Text(
                    value,
                    style: TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                  ),
                  onTap: () {
                    key = key.replaceAll(RegExp(r'[^АаӘәБбВвГгҒғДдЕеЁёЖжЗзИиЙйКкҚқЛлМмНнҢңОоӨөПпРрСсТтУуҰұҮүФфХхҺһЦцЧчШшЩщЪъЫыІіЬьЭэЮюЯяabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]'), '');
                    print(key);
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
                                      leading: Icon(Icons.accessibility),
                                      title: Text(AppLocalizations.of(context)!.deff),
                                      onTap: () async {
                                        key = key.replaceAll(RegExp(r'[^A-Za-z]'), ''); // Убедитесь, что слово содержит только буквы
                                        final definition = await fetchWordDefinition(key);
                                        print(definition);
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: 200.0,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Text(
                                                        key,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Text(definition ?? 'No definition available'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.access_time),
                                      title: Text(AppLocalizations.of(context)!.translate),
                                      onTap: () async {
                                        try {
                                          final translatedText = await translateText(key, 'en', 'ru'); // Adjust source and target languages as needed
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
                ),
              );
            });

            return ListView(
              children: wordWidgets,
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.language), // Иконка для переключения языка
            onPressed: () {
              // Показать диалог выбора языка
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.selectcon),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.kzzz),
                          onTap: () {
                            _setCurrentContent();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.ruuu),
                          onTap: () {
                            _setCurrentContentru();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.english),
                          onTap: () {
                            _setCurrentContenten();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.other),
                          onTap: () {
                            _setCurrentContentother();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _currentContent,
    );
  }
}
