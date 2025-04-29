import 'package:flutter/material.dart';
import '../components/sidebar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLocationOn = false;
  bool isNotificationsOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D4B4F),
        title: Text('Settings'),
      ),
      body: Container(
        color: Color(0xFFA8B3A0),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            switchTile('Location', isLocationOn, (val) {
              setState(() => isLocationOn = val);
            }),
            SizedBox(height: 10),
            switchTile('Notifications', isNotificationsOn, (val) {
              setState(() => isNotificationsOn = val);
            }),
            SizedBox(height: 30),
            buttonTile('About Us'),
            SizedBox(height: 10),
            buttonTile('Privacy Policy'),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF2D4B4F),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Text('Rate Us', style: TextStyle(color: Colors.white)),
                  Spacer(),
                  Row(
                      children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber))
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('App Version 1.0.0.1', style: TextStyle(color: Colors.grey.shade700))
          ],
        ),
      ),
    );
  }

  Widget switchTile(String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFCDD8B6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green[500],
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: Colors.grey[400],
          ),
          Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }


  Widget buttonTile(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2D4B4F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Widget drawerLink(String text) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
      onTap: () {},
    );
  }

  Widget drawerItem(IconData icon, String title, {bool isSelected = false}) {
    return Container(
      color: isSelected ? Color(0xFF6F948C) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF231F20)),
        title: Text(title, style: TextStyle(color: Color(0xFFD6D3D3))),
        onTap: () {},
      ),
    );
  }

}
