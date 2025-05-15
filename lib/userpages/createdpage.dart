import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';
import 'package:quartier_sur/system/userSession.dart';
import 'package:intl/intl.dart';

class CreatedIncidentsPage extends StatefulWidget {
  const CreatedIncidentsPage({super.key});

  @override
  State<CreatedIncidentsPage> createState() => _CreatedIncidentsPageState();
}

class _CreatedIncidentsPageState extends State<CreatedIncidentsPage> {
  List<Map<String, dynamic>> incidents = [];
  Set<String> expandedCrimeIds = {};

  final List<String> crimeTypes = [
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

  void _showEditDialog(Map<String, dynamic> crimeData, String crimeId) {
    String selectedCrimeType = crimeData['crimeType'] ?? '';
    String selectedCrimeArea = crimeData['crimeArea'] ?? '';
    TextEditingController descriptionController = TextEditingController(text: crimeData['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFB4C2A7),
          title: const Text("Edit Crime Report", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCrimeType.isNotEmpty ? selectedCrimeType : null,
                  items: crimeTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Crime Type'),
                  onChanged: (val) {
                    if (val != null) {
                      selectedCrimeType = val;
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedCrimeArea.isNotEmpty ? selectedCrimeArea : null,
                  items: montrealAreas.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Crime Area'),
                  onChanged: (val) {
                    if (val != null) {
                      selectedCrimeArea = val;
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D4A46)),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('crimes').doc(crimeId).update({
                  'crimeType': selectedCrimeType,
                  'crimeArea': selectedCrimeArea,
                  'description': descriptionController.text,
                });

                Navigator.pop(context);
                _loadUserCrimes(); // Refresh list
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserCrimes();
  }

  Future<void> _loadUserCrimes() async {
    try {
      final userDoc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserSession.username)
          .get();
      final crimeIds = List<String>.from(userDoc.data()?['crimesCreated'] ?? []);

      List<Map<String, dynamic>> loadedIncidents = [];

      for (String crimeId in crimeIds) {
        final crimeDoc =
        await FirebaseFirestore.instance
            .collection('crimes')
            .doc(crimeId)
            .get();
        final data = crimeDoc.data();
        if (data != null) {
          data['id'] = crimeId;
          loadedIncidents.add(data);
        }
      }

      if (mounted) {
        setState(() {
          incidents = loadedIncidents;
        });
      }
    } catch (e) {
      print('Error loading crimes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 4,),
      backgroundColor: const Color(
        0xFFA6B19E,
      ), // Background color from screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A46),
        title: const Text("Created Incidents", style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Created Incidents",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final crime = incidents[index];
                  final crimeId = crime['id'] ?? '';
                  final dateStr = crime['date'];
                  DateTime? parsedDate;
                  if (dateStr is String) {
                    parsedDate = DateTime.tryParse(dateStr);
                  }
                  final location = crime['crimeArea'] ?? 'Unknown location';
                  final type = crime['crimeType'] ?? 'Unknown crime';
                  final description = crime['description'] ?? 'No description available.';
                  final formattedDate = parsedDate != null
                      ? DateFormat('MMM, dd yyyy').format(parsedDate)
                      : "Unknown date";

                  final isExpanded = expandedCrimeIds.contains(crimeId);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          expandedCrimeIds.remove(crimeId);
                        } else {
                          expandedCrimeIds.add(crimeId);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4C2A7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF90A88F)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$type reported at $location",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _showEditDialog(crime, crimeId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D4A46),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text("Edit", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
