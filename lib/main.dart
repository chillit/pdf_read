import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pdf_read/dict.dart';
import 'package:pdf_read/pdfviews/enPdfView.dart';
import 'package:pdf_read/pdfviews/otherpdf.dart';
import 'package:pdf_read/pdfviews/pdfViewerScreen.dart';
import 'package:pdf_read/pdfviews/rupdfview.dart';
import 'package:pdf_read/profile.dart';
import 'package:pdf_read/signIn.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf_read/l10n/l10n.dart';
import 'dart:typed_data';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale("en");

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Set the global font for the entire app
        fontFamily: 'NotoSans',
      ),
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      title: 'My App',
      home: AuthChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  void initState(){
    super.initState();
    _fetchUserData();
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserUID = "";
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      currentUserUID = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while checking login status.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? TextFilePicker() : SignIn();
        }
      },
    );
  }
}
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if the user is already logged in.
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  // Sign in with email and password.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      return user?.uid;
    } catch (e) {
      return null; // Handle authentication errors here.
    }
  }

  // Sign out the user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
class TextFilePicker extends StatefulWidget {
  @override
  _TextFilePickerState createState() => _TextFilePickerState();
}



class _TextFilePickerState extends State<TextFilePicker> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileContents = "";
  @override
  String _currentUserUID = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    requestPermission();
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

  Future<void> _fetchUserNickname(String uid) async {
    final DatabaseReference _database = FirebaseDatabase.instance.reference();
    DatabaseEvent snapshot = await _database.child('users').child(uid).child('username').once();
    setState(() {
      _currentUserNickname = snapshot.snapshot.value.toString() ?? 'Unknown';
    });
  }
  Future<void> requestPermission() async {
    if (!kIsWeb) {
      // Запрос разрешений только на мобильных устройствах
      var status = await Permission.storage.request();
      if (status.isDenied) {
        // Обработка отказа в разрешении
        print('Permission denied');
      }
    }
  }
  String _fromLanguageCode = 'en';
  String _fromLanguageName = 'English';
  String _toLanguageCode = 'fr';
  String _toLanguageName = 'French';
  // Пример списка языков
  final Map<String, String> _languages = {
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'ny': 'Chichewa',
    'zh-cn': 'Chinese Simplified',
    'zh-tw': 'Chinese Traditional',
    'co': 'Corsican',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'en': 'English',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'tl': 'Filipino',
    'fi': 'Finnish',
    'fr': 'French',
    'fy': 'Frisian',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'iw': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jw': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'ko': 'Korean',
    'ku': 'Kurdish (Kurmanji)',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ma': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'uz': 'Uzbek',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };

  Future<void> _selectFromLanguage(BuildContext context) async {
    String searchText = '';
    List<MapEntry<String, String>> filteredLanguages = _languages.entries.toList();

    final String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Column(
                children: [
                  Text('Select source language'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                        filteredLanguages = _languages.entries
                            .where((entry) =>
                        entry.key.toLowerCase().contains(searchText) ||
                            entry.value.toLowerCase().contains(searchText))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              children: filteredLanguages.map((entry) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, entry.key);
                  },
                  child: Text(entry.value),
                );
              }).toList(),
            );
          },
        );
      },
    );

    if (selectedLanguage != null) {
      setState(() {
        _fromLanguageCode = selectedLanguage;
        _fromLanguageName = _languages[selectedLanguage]!;
      });
      await _selectToLanguage(context); // Вызов функции выбора языка назначения после выбора исходного языка
    }
  }

  Future<void> _selectToLanguage(BuildContext context) async {
    String searchText = '';
    List<MapEntry<String, String>> filteredLanguages = _languages.entries.toList();

    final String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Column(
                children: [
                  Text('Select target language'),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                        filteredLanguages = _languages.entries
                            .where((entry) =>
                        entry.key.toLowerCase().contains(searchText) ||
                            entry.value.toLowerCase().contains(searchText))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              children: filteredLanguages.map((entry) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, entry.key);
                  },
                  child: Text(entry.value),
                );
              }).toList(),
            );
          },
        );
      },
    );

    if (selectedLanguage != null) {
      setState(() {
        _toLanguageCode = selectedLanguage;
        _toLanguageName = _languages[selectedLanguage]!;
      });
    }
    _loadFile("other");
  }


  Future<void> _loadFile(String locale) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(result!=null){
      File file = File(result.files.single.path!);
      if (file != null) {
        if (file.existsSync()) {
          if (file.path.endsWith('.pdf')) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if(locale == "kk") {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(file: file)));
              }
              else if(locale == "ru"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ruPDFViewerScreen(file: file)));
              }
              else if(locale == "other"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => otherPdf(file: file, source: _fromLanguageCode, target: _toLanguageCode,)));
              }
              else{
                Navigator.push(context, MaterialPageRoute(builder: (context) => enPDFViewerScreen(file: file)));
              }
              print(":Eh");
              String uid = user.uid;
              Reference storageReference = FirebaseStorage.instance.ref().child('user_files/$uid/${locale}${result.files.single.name}');
              try {
                await storageReference.putFile(file);
                print('Файл успешно загружен в Firebase Storage.');
              } catch (e) {
                print('Ошибка загрузки файла: $e');
              }
            } else {
              print('Пользователь не вошел в систему.');
            }
          }
        } else {
          print('File does not exist.');
        }
      }
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
          icon: Icon(Icons.menu, color: Colors.brown),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
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
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.profile),
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
      backgroundColor: Color(0xFFEAE7DC),
      body: Center(
        child: Column(
          children: [
            // Image widget added here
            Container(
              width: double.infinity, // Ensures the container takes all available width
              height: 350, // Set this to the height you want for your image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mainpic.png'), // Path to your image asset
                  fit: BoxFit.contain, // Use BoxFit to fit the image in the best way
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:()async{ _loadFile("kz");},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'kz',
                        child: Text(AppLocalizations.of(context)!.kzzz),
                        onTap: ()async{ _loadFile("kk");},
                      ),
                      PopupMenuItem<String>(
                        value: 'ru',
                        child: Text(AppLocalizations.of(context)!.ruuu),
                        onTap: ()async{ _loadFile("ru");},
                      ),
                      PopupMenuItem<String>(
                        value: 'en',
                        child: Text(AppLocalizations.of(context)!.english),
                        onTap: ()async{ _loadFile("en");},
                      ),
                      PopupMenuItem<String>(
                        value: 'other',
                        child: Text(AppLocalizations.of(context)!.other),
                        onTap: (){ _selectFromLanguage(context);},
                      ),
                    ],
                    child: Row(
                      children: [
                        Text('kz/ru/en', style: TextStyle(color: Colors.brown, fontFamily: 'NotoSans')),
                        Icon(Icons.arrow_drop_down, color: Colors.brown),
                      ],
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.brown, width: 2),
                ),
                elevation: 0,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomButton(
                    iconData: Icons.menu,
                    label: AppLocalizations.of(context)!.dict,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => dict()),
                      );
                    },
                  ),
                  CustomButton(
                    iconData: Icons.settings,
                    label: AppLocalizations.of(context)!.settings,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: EdgeInsets.all(20.0), // Adjust padding as needed
                            title: Center(
                              child: Text(
                                AppLocalizations.of(context)!.chselan,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // Add your title text style here
                                ),
                              ),
                            ),
                            content: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      MyApp.of(context)?.setLocale(Locale.fromSubtags(languageCode: 'kk'));
                                    },
                                    child: Text(AppLocalizations.of(context)!.kzzz),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      MyApp.of(context)?.setLocale(Locale.fromSubtags(languageCode: 'ru'));
                                    },
                                    child: Text(AppLocalizations.of(context)!.ruuu),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      MyApp.of(context)?.setLocale(Locale.fromSubtags(languageCode: 'en'));
                                    },
                                    child: Text(AppLocalizations.of(context)!.english),
                                  ),
                                ),
                              ],
                            ),
                          );

                        },
                      );
                    }
                  ),
                  CustomButton(
                    iconData: Icons.description,
                    label: AppLocalizations.of(context)!.docs,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );

  }
}
class CustomButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        onPrimary: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.brown, width: 2),
        ),
        padding: EdgeInsets.all(8), // Add padding to the button
        minimumSize: Size(100, 65), // Ensure minimum size for the button
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            iconData,
            color: Colors.brown,
            size: 30, // Reduce icon size if needed
          ),
          SizedBox(height: 5), // Add spacing between icon and text
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: Colors.brown, fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Handle text overflow
            ),
          ),
        ],
      ),
    );
  }
}




bool containsTwoOrMoreWords(String input) {
  // Split the input string by whitespace
  List<String> words = input.split(' ');

  // Check if the number of words is two or more
  return words.length >= 2;
}
class PDFDocumentData {
  final Uint8List fileBytes;
  final String fileName;

  PDFDocumentData({required this.fileBytes, required this.fileName});
}

