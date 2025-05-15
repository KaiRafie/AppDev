import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quartier_sur/system/userSession.dart';
import '../components/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuartierSûr',
      theme: ThemeData(useMaterial3: false),
      home: const CreateReportPage(),
    );
  }
}

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime? selectedDateTime;
  final Uri _phoneUri = Uri(scheme: 'tel', path: '911');
  final Uri emergencyUri = Uri(scheme: 'tel', path: '911');

  Future<void> _makeEmergencyCall() async {
    if (!await launchUrl(emergencyUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $emergencyUri');
    }
    if (await canLaunchUrl(_phoneUri)) {
      await launchUrl(_phoneUri);
    } else {
      throw 'Could not launch $_phoneUri';
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F4F4F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFFCDD8B6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F4F4F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFFCDD8B6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    if (mounted) {
      setState(() {
        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _createCrime(
      String username,
      String createdDate,
      String crimeType,
      String crimeArea,
      String description,
      String date,
      String time,
      ) async {
    final db = FirebaseFirestore.instance;

    try {
      // Step 1: Fetch last ID
      final snapshot =
      await db
          .collection('crimes')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      int lastId = 0;
      if (snapshot.docs.isNotEmpty) {
        lastId = int.tryParse(snapshot.docs.first.id) ?? 0;
      }
      int newId = lastId + 1;

      // Step 2: Add crime document
      await db.collection('crimes').doc(newId.toString()).set({
        'createdBy': username,
        'createdDate': createdDate,
        'crimeType': crimeType,
        'crimeArea': crimeArea,
        'description': description,
        'date': date,
        'time': time,
      });

      await _countCrime(crimeType);
      await _countArea(crimeArea);
      await _saveCrimeId(username, newId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Crime reported successfully")),
      );
    } catch (e) {
      print("Error creating crime: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to post crime")));
    }
  }

  Future<void> _countCrime(String crimeType) async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('crimeStats').doc(crimeType);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final currentCount = snapshot.data()?['count'] ?? 0;
        await docRef.update({'count': currentCount + 1});
      } else {
        await docRef.set({'count': 1});
      }
    } catch (e) {
      print("Error updating crime count: $e");
    }
  }

  Future<void> _countArea(String areaName) async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('areaStats').doc(areaName);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final currentCount = snapshot.data()?['count'] ?? 0;
        await docRef.update({'count': currentCount + 1});
      } else {
        await docRef.set({'count': 1});
      }
    } catch (e) {
      print("Error updating area count: $e");
    }
  }

  Future<void> _saveCrimeId(String username, int crimeId) async {
    final db = FirebaseFirestore.instance;

    try {
      final userDoc = db.collection('users').doc(username);

      await userDoc.update({
        'crimesCreated': FieldValue.arrayUnion([crimeId.toString()]),
      });
    } catch (e) {
      print("Error saving crime ID to user: $e");
    }
  }

  String? selectedCrimeType;

  final List<String> cimeTypes = [
    'Assault',
    'Sexual Assault',
    'Robbery',
    'Homicide',
    'Theft',
    'Vehicle Theft',
    'Break and Enter',
    'Vandalism',
    'Fraud - Scams',
    'Drug Offences',
    'Weapons Offences',
    'Impaired Driving',
    'Harassment - Threats',
    'Kidnapping',
    'Arson',
    'Disturbance - Mischief',
  ];

  String? selectedArea;

  final List<String> montrealAreas = [
    'Longueuil',
    'Laval',
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

  void _validateInput({
    required String username,
    required String createdDate,
    required String crimeType,
    required String crimeArea,
    required String description,
    required DateTime selectedDate,
  }) {
    final now = DateTime.now();

    // Validate allowed time range
    final startOfYesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (selectedDate.isBefore(startOfYesterday) || selectedDate.isAfter(endOfToday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only reports from yesterday up to the end of today are allowed")),
      );
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(selectedDate);
    final time = DateFormat('HH:mm').format(selectedDate);

    _createCrime(username, createdDate, crimeType, crimeArea, description, date, time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Create Report', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFA8B5A2),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // drop down list of crime types
            DropdownButtonFormField<String>(
              hint: Text(
                "Select a crime type",
                style: TextStyle(color: Colors.black),
              ),
              value: selectedCrimeType,
              onChanged: (String? newValue) {
                if (mounted) {
                  setState(() {
                    selectedCrimeType = newValue;
                  });
                }
              },
              items:
              cimeTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFCDD8B6), // Match your form color
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Color(0xFFCDD8B6), // Dropdown background
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            // Incident text box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFCDD8B6),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _textController,
                maxLength: 1000,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us about it',
                  counterStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time Picker
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFCDD8B6),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDateTime == null
                        ? 'Select date & time'
                        : DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(selectedDateTime!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                    ),
                    child: const Text('Pick', style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //select the area where the crime happened
            DropdownButtonFormField<String>(
              hint: const Text(
                "Select a Montreal area",
                style: TextStyle(color: Colors.black),
              ),
              value: selectedArea,
              onChanged: (String? newValue) {
                if (mounted) {
                  setState(() {
                    selectedArea = newValue;
                  });
                }
              },
              items: montrealAreas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFCDD8B6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: const Color(0xFFCDD8B6),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              style: const TextStyle(color: Colors.black),
            ),
            const Spacer(),

            // Bottom row buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _makeEmergencyCall,
                  icon: const Icon(Icons.call),
                  label: const Text('Call for help', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8EA682),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final username = UserSession.username;
                    final createdDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                    final crimeType = selectedCrimeType ?? '';
                    final crimeArea = selectedArea ?? '';
                    final description = _textController.text.trim();
                    final selected = selectedDateTime;

                    if (crimeType.isEmpty || description.isEmpty || selected == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please complete all fields")),
                      );
                      return;
                    }

                    _validateInput(
                      username: username!,
                      createdDate: createdDate,
                      crimeType: crimeType,
                      crimeArea: crimeArea,
                      description: description,
                      selectedDate: selected, // only for validation range check
                    );

                    if (mounted) {
                      setState(() {
                        selectedArea = null;
                        selectedCrimeType = null;
                        selectedDateTime = null;
                        _textController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4F4F),
                  ),
                  child: const Text('Post Report', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
