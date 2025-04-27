import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  final Color darkGreen = const Color(0xFF2F4F4F);
  final Color lightGreen = const Color(0xFFA8B5A2);

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
            padding: EdgeInsets.only(
              left: 10,
              top: 50,
              right: 10,
              bottom: 30,
            ),
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

          _buildListTile(0, Icons.home, 'Home'),
          const SizedBox(height: 20),
          _buildListTile(1, Icons.search, 'Search'),
          const SizedBox(height: 20),
          _buildListTile(2, Icons.bookmark, 'Saved'),
          const SizedBox(height: 20),
          _buildListTile(3, Icons.person, 'Profile'),
          const SizedBox(height: 20),
          _buildListTile(4, Icons.settings, 'Settings'),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {},
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

  Widget _buildListTile(int index, IconData icon, String title) {
    final isSelected = index == selectedIndex;

    return Container(
      color: isSelected ? const Color(0xFF487B7B) : darkGreen,
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 35),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFD6D3D3)),
        ),
        onTap: () => onItemTap(index),
      ),
    );
  }
}