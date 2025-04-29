import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
    );
  }
}
