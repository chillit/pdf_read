import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';

void main() {
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Widget _currentContent = Container(color: Color(0xFFDED9C2),);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentUserUID = "";
  String _currentUserNickname = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setCurrentContent();
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
    print(_currentUserNickname);
  }

  void _setCurrentContent() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent dataSnapshot = await _databaseReference.child('users/${user.uid}/phrases').once();
      Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      List<String> phrases = [];
      values.forEach((key, value) {
        phrases.add(value);
      });

      setState(() {
        _currentContent = Expanded(
          child: Container(
            color: Color(0xFFDED9C2),
            child: FutureBuilder<List<String>>(
              future: fetchFiles(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.library_books),
                        title: Text(snapshot.data![index]),
                        // You can add functionality to each file item if needed
                      );
                    },
                  );
                }
              },
            ),
          ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TextFilePicker()),
                      );
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _currentUserNickname,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xFFDED9C2),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async{
                      User? user = _auth.currentUser;
                      if (user != null) {
                        DatabaseEvent dataSnapshot = await _databaseReference.child('users/${user.uid}/phrases').once();
                        Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
                        List<String> phrases = [];
                        values.forEach((key, value) {
                          phrases.add(value);
                        });

                        setState(() {
                          _currentContent = Expanded(
                            child: Container(
                              color: Color(0xFFDED9C2),
                              child: FutureBuilder<List<String>>(
                                future: fetchFiles(user.uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    return ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Icon(Icons.library_books),
                                          title: Text(snapshot.data![index]),
                                          // You can add functionality to each file item if needed
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.recentdoc),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xFFDED9C2),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = _auth.currentUser;
                      if (user != null) {
                        DatabaseEvent dataSnapshot = await _databaseReference.child('users/${user.uid}/phrases').once();
                        Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
                        List<String> phrases = [];
                        values.forEach((key, value) {
                          phrases.add(value);
                        });

                        setState(() {
                          _currentContent = StreamBuilder(
                            stream: _databaseReference.child('users/${user.uid}/phrases').onValue,
                            builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                                Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                List<String> phrases = values.values.cast<String>().toList();

                                return ListView.builder(
                                  itemCount: phrases.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      color: Color(0xFFDED9C2),
                                      padding: const EdgeInsets.all(10),
                                      child: Card(
                                        elevation: 10,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, left: 20, bottom: 20, right: 20),
                                              child: Text(
                                                phrases[index].trim(),
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(child: Text(AppLocalizations.of(context)!.nodata));
                              }
                            },
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.quotes),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _currentContent,
          ),
        ],
      ),
    );
  }

  Future<List<String>> fetchFiles(String currentUserUid) async {
    List<String> filesList = [];

    try {
      firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance
          .ref('user_files/$currentUserUid')
          .listAll();

      for (firebase_storage.Reference ref in result.items) {
        filesList.add(ref.name);
      }
    } catch (e) {
      print('Error fetching files: $e');
    }

    return filesList;
  }
}
