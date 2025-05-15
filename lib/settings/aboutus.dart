import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 6),
      backgroundColor: const Color(0xFFA6B19E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A46),
        title: const Text("About Us", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Quartier Sûr",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Quartier Sûr is a crime reporting application developed by "
                    "students at Vanier College with the goal of making "
                    "communities safer and more informed.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Purpose",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "Our goal is to provide residents of Montreal with a quick and "
                    "easy way to report incidents, track local crimes, and stay"
                    " alert.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Features",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "- Report crimes with location and details\n"
                    "- Save and track incidents\n"
                    "- Search by keyword, area, and date\n"
                    "- Emergency call shortcut\n"
                    "- Clean and accessible UI",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Our Team",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "Quartier Sûr was built by a passionate team of Computer Science"
                    " students, Kais Rafie & Tarek Abou Chahin, as part of a "
                    "semester-long project at Vanier College.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Contact Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                "If you have suggestions, feedback, or want to contribute, feel "
                    "free to reach out at quartier_sur@gmail.com.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}