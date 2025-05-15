import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';
import 'package:quartier_sur/prehomepage/loginpage.dart';
import 'package:quartier_sur/settings/aboutus.dart';
import 'package:quartier_sur/settings/privacypolicypage.dart';
import '../system/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import '../system/userSession.dart';
import 'package:geolocator/geolocator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool locationEnabled = false;
  bool notificationsEnabled = false;
  double rating = 0.0;
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
    'Villeray–Saint-Michel–Parc-Extension',
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        print("No placemarks found.");
        return;
      }

      final Placemark firstPlacemark = placemarks.first;
      final String? subLocality = firstPlacemark.subLocality;
      final String? locality = firstPlacemark.locality;

      if (subLocality == null && locality == null) {
        print("Both subLocality and locality are null.");
        return;
      }

      final String matchedArea = matchArea(subLocality ?? locality);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .set({
        'locationEnabled': true,
        'location': matchedArea,
      }, SetOptions(merge: true));

      print("Borough saved: $matchedArea");
    } catch (e, stack) {
      print("Error fetching location: $e");
      print("Stacktrace: $stack");
    }
  }

  void _onSwitchChangedNotification(bool value) async {
    if (mounted) {
      setState(() {
        notificationsEnabled = value;
      });
    }
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
        body:
        'You turned on notifications. Now you can receive notifications\n'
            'about new incidents in your area.',
      );
    }
  }

  void _onSwitchChangedLocation(bool value) async {
    if (mounted) {
      setState(() {
        locationEnabled = value;
      });
    }
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .set({'locationEnabled': false}, SetOptions(merge: true));
    }
  }

  Future<void> _enableLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied.');
      return;
    }

    if (mounted) {
      setState(() {
        locationEnabled = true;
      });
    }
  }

  Future<void> _loadLocationPreference() async {
    final doc =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UserSession.username)
        .get();

    if (doc.exists && doc.data()!.containsKey('locationEnabled')) {
      final enabled = doc['locationEnabled'] as bool;
      if (mounted) {
        setState(() {
          locationEnabled = enabled;
        });
      }

      if (enabled) {
        _enableLocationService();
        _determineLocation();
      }
    }
  }

  void _loadNotificationSetting() async {
    try {
      final doc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .get();

      if (doc.exists) {
        if (mounted) {
          setState(() {
            notificationsEnabled = doc.data()?['notificationsEnabled'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Failed to load Firestore setting: $e");
    }
  }

  Future<void> _updateRating(double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .update({'rateUs': rating});
      print("Rating updated to $rating");
    } catch (e) {
      print("Failed to update rating: $e");
    }
  }

  Future<void> _loadRating() async {
    try {
      final doc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('rateUs')) {
          final savedRating = data['rateUs'];
          if (savedRating is num) {
            setState(() {
              rating = savedRating.toDouble();
            });
            print("Loaded saved rating: $rating");
          }
        }
      }
    } catch (e) {
      print("Failed to load rating: $e");
    }
  }

  _signOut(BuildContext context) {
    UserSession.username = null;

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
    _loadLocationPreference();
    _loadRating();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFA8B5A2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Location Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8EA682), width: 2),
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
                                color: Colors.grey.withOpacity(0.15),
                                offset: const Offset(2, 6),
                                spreadRadius: 0.25,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: SwitchTheme(
                            data: SwitchThemeData(
                              thumbColor: WidgetStateProperty.all(const Color(0xFFB7C2A9)),
                              trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                                return states.contains(WidgetState.selected) ? Colors.black : Colors.white;
                              }),
                            ),
                            child: Switch(
                              value: locationEnabled,
                              onChanged: _onSwitchChangedLocation,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Location', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notification Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8EA682), width: 2),
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
                                color: Colors.grey.withOpacity(0.15),
                                offset: const Offset(2, 6),
                                spreadRadius: 0.25,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: SwitchTheme(
                            data: SwitchThemeData(
                              thumbColor: WidgetStateProperty.all(const Color(0xFFB7C2A9)),
                              trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                                return states.contains(WidgetState.selected) ? Colors.black : Colors.white;
                              }),
                            ),
                            child: Switch(
                              value: notificationsEnabled,
                              onChanged: _onSwitchChangedNotification,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Us Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('About Us', style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 12),

                  // Privacy Policy Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 80),

                  // Rating bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4F4F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rate Us', style: TextStyle(color: Colors.white)),
                        Row(
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = starIndex.toDouble();
                                });
                                _updateRating(rating);
                              },
                              child: Icon(
                                Icons.star,
                                color: rating >= starIndex ? Colors.amber : Colors.grey[400],
                                size: 28,
                              ),
                            );
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
                      Text('App Version 1.0.0.1', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Sign Out Button
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  _signOut(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
