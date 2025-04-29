import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
      ),
    );
  }
}
