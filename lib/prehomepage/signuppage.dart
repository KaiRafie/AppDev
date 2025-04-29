import 'package:flutter/material.dart';

main() {
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

    TextEditingController username = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    TextEditingController checkPassword = TextEditingController();

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
                    _textFieldInstance(hint: 'Username', controller: username),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Email', controller: email),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Password', obscure: true, controller: password),
                    const SizedBox(height: 12),
                    _textFieldInstance(hint: 'Re-enter Password', obscure: true, controller: checkPassword),
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