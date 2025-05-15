import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../userpages/homepage.dart';
import 'forgotpasspage.dart';
import 'signuppage.dart';
import '../system/userSession.dart';

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
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFA8B5A2);
    const fieldColor = Color(0xFF2F4F4F);
    const textColor = Colors.white;

    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    String username = '';
    String password = '';

    //Collection reference for users
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // helper method to show error dialogs to simplify the code
    void showErrorDialog(BuildContext context, String title, String message) {
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

    //method to fetch the username then the password of that username if exists
    Future<bool?> checkCredentials0(String username, String password) async {
      if (username.trim().isEmpty) {
        showErrorDialog(context, 'Username Empty', 'Please enter a valid username.');
        return false;
      }

      if (password.trim().isEmpty) {
        showErrorDialog(context, 'Password Empty', 'Please enter a valid password.');
        return false;
      }

      try {
        DocumentSnapshot snapshot = await users.doc(username).get();

        if (snapshot.exists) {
          if (snapshot['password'] == password) {
            return true;
          } else {
            showErrorDialog(context, 'Invalid Password',
                'The username and password do not match. Please check your password.');
            return false;
          }
        } else {
          showErrorDialog(context, 'Invalid Username',
              'The username provided does not exist. Please enter a valid username.');
          return false;
        }
      } on FirebaseException catch (e) {
        showErrorDialog(context, 'Firebase Error', e.message ?? 'An error occurred.');
        return false;
      } catch (e) {
        showErrorDialog(context, 'Unknown Error', 'An unexpected error occurred.');
        return false;
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
                'QuartierSûr',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF2F4F4F),
                ),
              ),
            ),
            const Spacer(flex: 3),

            // Fixed width container for inputs
            Center(
              child: SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username or email
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fieldColor,
                        hintText: 'Username',
                        hintStyle: const TextStyle(color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: textColor),
                      controller: usernameController,
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fieldColor,
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: textColor),
                      controller: passwordController,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPassPage(),)
                          );
                        },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.centerLeft
                      ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: textColor),
                        ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                        padding: EdgeInsets.only(left: 12),
                      child: const Text(
                        'New to The Neighbourhood?',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),)
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: textColor),
                      ),
                    ),
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
                  onPressed: () async{
                    username = usernameController.text;
                    password = passwordController.text;
                    bool? checkCredentials = await checkCredentials0(username, password);
                    if (checkCredentials == true) {
                      UserSession.username = username;
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage(),));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fieldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Log-in',
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
}