import 'package:flutter/material.dart';
import '../userpages/homepage.dart';
import '../userpages/createdpage.dart';
import '../userpages/savedpage.dart';
import '../userpages/search.dart';
import '../settings/profilepage.dart';
import '../settings/pirvacypolicypage.dart';
import '../settings/aboutus.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = 0;
  final Color darkGreen = const Color(0xFF2F4F4F);

  void _navigateToPage(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget page;

    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = SearchPage();
        break;
      case 2:
        page = SavedPage();
        break;
      case 3:
        page = ProfilePage();
        break;
      case 4:
        page = SettingsPage();
        break;
      default:
        page = HomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const BeveledRectangleBorder(),
      width: 220,
      backgroundColor: darkGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                'QuartierSûr',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA8B5A2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildListTile(context, 0, Icons.home, 'Home'),
          const SizedBox(height: 20),
          _buildListTile(context, 1, Icons.search, 'Search'),
          const SizedBox(height: 20),
          _buildListTile(context, 2, Icons.bookmark, 'Saved'),
          const SizedBox(height: 20),
          _buildListTile(context, 3, Icons.person, 'Profile'),
          const SizedBox(height: 20),
          _buildListTile(context, 4, Icons.settings, 'Settings'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
                    );
                  },
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AboutUsPage()),
                    );
                  },
                  child: const Text(
                    'About Us',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '© 2025 QuartierSûr\nAll Rights Reserved.',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, int index, IconData icon, String title) {
    final isSelected = index == _selectedIndex;

    return Container(
      color: isSelected ? const Color(0xFF487B7B) : darkGreen,
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 35),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFD6D3D3)),
        ),
        onTap: () => _navigateToPage(context, index),
      ),
    );
  }
}