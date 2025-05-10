import 'package:flutter/material.dart';
import 'package:pdf_read/components/my_button.dart';
import 'package:pdf_read/components/my_textfield.dart';
import 'package:pdf_read/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pdf_read/signIn.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {


    try {
      String email = emailController.text;
      String password = passwordController.text;
      String fio = usernameController.text;

      // Создаем аккаунт
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final locale = Localizations.localeOf(context);
      print(locale.languageCode);

      dbRef.child('users').child(uid).set({
        'username': fio,
        'email': email,
        'role': "student",
        "locale": "en"
      });


      AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon:false,
          title: "ура",
          btnOkOnPress: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TextFilePicker()));
          },
          btnOkColor: Colors.green

      ).show();

      print('Данные успешно отправлены в Firebase.');
    } catch (e) {
      AwesomeDialog(
        context: context,
        width: MediaQuery.of(context).size.width,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon:false,
        title:"Ошибка",
        desc: "а че это",
      ).show();
      print('Ошибка отправки данных в Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE7DC),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                Container(
                  width: double.infinity, // Ensures the container takes all available width
                  height: 225, // Set this to the height you want for your image
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/mainpic.png'), // Path to your image asset
                      fit: BoxFit.contain, // Use BoxFit to fit the image in the best way
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
                  hintText: AppLocalizations.of(context)!.username,
                  obscureText: false,
                ),

                const SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: AppLocalizations.of(context)!.email,
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: AppLocalizations.of(context)!.password,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password?

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  onTap: signUserIn,
                  text: AppLocalizations.of(context)!.signup,
                ),

                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.alracc,
                          style: TextStyle(
                            color: Colors.blue, // Цвет текста кнопки
                            // Дополнительные стили для текста кнопки
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}