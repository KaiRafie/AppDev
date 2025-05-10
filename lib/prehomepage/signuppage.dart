import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quartier_sur/prehomepage/loginpage.dart';

main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDV3lAVmT4sXUj9v3hf0Tiw0TTptWqyeWc",
          appId: "1001879692422",
          messagingSenderId: "1001879692422",
          projectId: "quartiersur"
      )
  );
  runApp(SignupPage());
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFA8B5A2);
    const fieldColor = Color(0xFF2F4F4F);
    const textColor = Colors.white;
    const double fieldWidth = 350;

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController checkPasswordController = TextEditingController();

    String username = '';
    String email = '';
    String password = '';
    String confirmPassword = '';

    List<int> newLists = [0];
    Future<void> _signUp(String username, String email, String password) async{
      if (username.trim().isNotEmpty && password.trim().isNotEmpty) {
        try {
          await users.doc(username).set({
            'email': email,
            'password': password,
            'crimesCreated': newLists,
            'crimesSaved': newLists,
            'notificationsEnabled': false,
            'locationEnabled': false,
            'location': "",
          });
          print('user added');
        } catch (error) {
          print('failed to add the user :$error');
        }
      } else {
        _showErrorDialog(context, 'Invalid username or password', 'Please enter '
            'valid Credentials.');
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Center(
              child: Text(
                'Join The Neighbourhood',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F4F4F),
                ),
              ),
            ),
            const Spacer(flex: 3),

            // Input fields
            Center(
              child: SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _textFieldInstance(hint: 'Username', controller: usernameController),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Email', controller: emailController),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Password', obscure: true, controller: passwordController),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Re-enter Password', obscure: true, controller: checkPasswordController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 180,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    username = usernameController.text;
                    email = emailController.text;
                    password = passwordController.text;
                    confirmPassword = checkPasswordController.text;
                    if (password == confirmPassword) {
                      _signUp(username, email, password);

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage(),));
                    } else {
                      _showErrorDialog(context, 'Passwords do not match', 'Please '
                          'confirm the password with the correct input');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fieldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign-up',
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _textFieldInstance({required String hint, bool obscure = false, required var controller}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2F4F4F),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      controller: controller,
    );
  }
}

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}