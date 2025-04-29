import 'package:flutter/material.dart';

void main() {
  runApp(const ForgotPassPage());
}

class ForgotPassPage extends StatelessWidget {
  const ForgotPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFA8B5A2);
    const fieldColor = Color(0xFF2F4F4F);
    const textColor = Colors.white;
    const double fieldWidth = 350;

    TextEditingController email = TextEditingController();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Navigator.pop(context); or use your login page route
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2F4F4F)),
              label: const Text(
                'Back to Login Page',
                style: TextStyle(
                  color: Color(0xFF2F4F4F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(flex: 2),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Forgot Your Password?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2F4F4F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your username and we\'ll send you a reset link.',
                    style: TextStyle(color: Color(0xFF2F4F4F)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Center(
              child: SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _textFieldInstance(hint: 'Username', controller: email),
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
                    'Reset Password',
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

  static Widget _textFieldInstance({
    required String hint,
    bool obscure = false,
    required TextEditingController controller,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF2F4F4F),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white),
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
