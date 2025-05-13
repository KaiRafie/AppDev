import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';
import '../system/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../system/userSession.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool locationEnabled = false;
  final loc.Location _location = loc.Location();
  bool notificationsEnabled = false;
  double rating = 5.0;
  final montrealAreas = [
    'Ahuntsic-Cartierville',
    'Anjou',
    'Côte-des-Neiges–Notre-Dame-de-Grâce',
    'Lachine',
    'LaSalle',
    'Le Plateau-Mont-Royal',
    'Le Sud-Ouest',
    'L’Île-Bizard–Sainte-Geneviève',
    'Mercier–Hochelaga-Maisonneuve',
    'Montréal-Nord',
    'Outremont',
    'Pierrefonds-Roxboro',
    'Rivière-des-Prairies–Pointe-aux-Trembles',
    'Rosemont–La Petite-Patrie',
    'Saint-Laurent',
    'Saint-Léonard',
    'Verdun',
    'Ville-Marie',
    'Villeray–Saint-Michel–Parc-Extension'
  ];

  String matchArea(String? rawArea) {
    if (rawArea == null) return 'Unknown';
    return montrealAreas.firstWhere(
          (area) => rawArea.toLowerCase().contains(area.toLowerCase()),
      orElse: () => 'Unknown',
    );
  }

  Future<void> _determineLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
      }

      if (serviceEnabled && permissionGranted == loc.PermissionStatus.granted) {
        loc.LocationData locationData = await _location.getLocation();
        double latitude = locationData.latitude!;
        double longitude = locationData.longitude!;

        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        String? rawArea = placemarks.first.subLocality ?? placemarks.first.locality;
        String matchedArea = matchArea(rawArea);

        await FirebaseFirestore.instance.collection('users').doc(UserSession.username).set({
          'locationEnabled': true,
          'location': matchedArea,
        }, SetOptions(merge: true));

        print("✅ Borough saved: $matchedArea");
      }
    } catch (e) {
      print("❌ Error fetching location: $e");
    }
  }

  void _onSwitchChangedNotification(bool value) async {
    setState(() {
      notificationsEnabled = value;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .update({'notificationsEnabled': value});
    } catch (e) {
      print("Failed to update Firestore: $e");
    }

    if (value) {
      NotificationService().showNotification(
        id: 0,
        title: 'Notifications Enabled',
        body: 'You turned on notifications. Now you can receive notifications\n'
            'about new incidents in your area.',
      );
    }
  }

  void _onSwitchChangedLocation(bool value) async {
    setState(() {
      locationEnabled = value;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .update({'locationEnabled': value});
    } catch (e) {
      print("Failed to update Firestore: $e");
    }

    if (value) {
      await _determineLocation();
    } else {
      await FirebaseFirestore.instance.collection('users').doc(UserSession.username).set({
        'location_enabled': false,
      }, SetOptions(merge: true));
    }

  }

  Future<void> _enableLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (serviceEnabled && permissionGranted == loc.PermissionStatus.granted) {
      setState(() {
        locationEnabled = true;
      });
    }
  }

  Future<void> _loadLocationPreference() async {
    final doc = await FirebaseFirestore.instance.collection('users')
        .doc(UserSession.username).get();

    if (doc.exists && doc.data()!.containsKey('locationEnabled')) {
      final enabled = doc['locationEnabled'] as bool;
      setState(() {
        locationEnabled = enabled;
      });

      if (enabled) {
        _enableLocationService();
        _determineLocation();
      }
    }
  }

  void _loadNotificationSetting() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .get();

      if (doc.exists) {
        setState(() {
          notificationsEnabled = doc.data()?['notificationsEnabled'] ?? false;
        });
      }
    } catch (e) {
      print("Failed to load Firestore setting: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
    _loadLocationPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 5,),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Settings'),
      ),
      backgroundColor: const Color(0xFFA8B5A2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8EA682),
                  width: 2,
                ),
                color: const Color(0xFFB7C2A9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(red: 0, green: 0, blue: 0, alpha: 0.15),
                          offset: Offset(2, 6),
                          spreadRadius: 0.25,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor: WidgetStateProperty.all(Color(0xFFB7C2A9)),
                        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.black; // ON -> Black
                          }
                          return Colors.white; // OFF -> White
                        }),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                        thumbIcon: WidgetStateProperty.all(null),
                      ),
                      child: Switch(
                        value: locationEnabled,
                        onChanged: _onSwitchChangedLocation
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Location',
                    style: TextStyle(
                        color: Colors.white,
                      fontSize: 20
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8EA682),
                  width: 2,
                ),
                color: const Color(0xFFB7C2A9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(red: 0, green: 0, blue: 0, alpha: 0.15),
                          offset: Offset(2, 6),
                          spreadRadius: 0.25,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor: WidgetStateProperty.all(Color(0xFFB7C2A9)),
                        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.black;
                          }
                          return Colors.white;
                        }),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                        thumbIcon: WidgetStateProperty.all(null),
                      ),
                      child: Switch(
                        value: notificationsEnabled,
                        onChanged: _onSwitchChangedNotification,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Us Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4F4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('About Us', style: TextStyle(color: Colors.white),),
            ),

            const SizedBox(height: 12),

            // Privacy Policy Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4F4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Privacy Policy', style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 80,),
            // Rate Us Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F4F4F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('Rate Us', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return const Icon(Icons.star, color: Colors.amber, size: 24);
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // App Version
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'App Version 1.0.0.1',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}