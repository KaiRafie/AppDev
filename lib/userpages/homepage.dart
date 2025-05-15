import 'package:flutter/material.dart';
import '../components/sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 0,),
      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
      ),
    );
  }
}
