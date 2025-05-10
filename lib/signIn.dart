import 'package:flutter/material.dart';
import 'package:pdf_read/LoginPage.dart';
import 'package:pdf_read/components/my_button.dart';
import 'package:pdf_read/components/my_textfield.dart';
import 'package:pdf_read/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';
class SignIn extends StatefulWidget {
  SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // text editing controllers
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth =FirebaseAuth.instance;
  Future<void> signupemailpass() async{
    await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text);
  }
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // В случае успешного входа перенаправляем пользователя на главную страницу
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TextFilePicker()));
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wrong email or password. Try again'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
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
                  onTap: () async{
                    login();
                  },
                  text: AppLocalizations.of(context)!.signin,
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
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.stillnoacc,
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