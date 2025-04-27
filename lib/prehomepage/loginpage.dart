import 'package:flutter/material.dart';

main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFA8B5A2);
    const fieldColor = Color(0xFF2F4F4F);
    const textColor = Colors.white;

    TextEditingController usernameOrEmail = TextEditingController();
    TextEditingController password = TextEditingController();

    return MaterialApp(
      home: Scaffold(
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
                          hintText: 'Username or email',
                          hintStyle: const TextStyle(color: textColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: textColor),
                        controller: usernameOrEmail,
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
                        controller: password,
                      ),
                      const SizedBox(height: 16),

                      // Text links
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'New to The Neighbourhood?\nSign up',
                        style: TextStyle(color: textColor),
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
                    onPressed: () {},
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
      ),
    );
  }
}