import 'package:flutter/material.dart';
import 'prehomepage/splashscreen.dart';


void main() {
  runApp(const QuartierSur());
}

class QuartierSur extends StatelessWidget {
  const QuartierSur({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splashscreen(),
    );
  }
}

