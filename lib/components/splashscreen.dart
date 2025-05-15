import 'dart:async';
import 'package:flutter/material.dart';
import '../prehomepage/loginpage.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2),
            () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => LoginPage())
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8B5A2), // Light green background
      body: const Center(
        child: Text(
          'QuartierSûr',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F4F4F), // Dark green text
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
