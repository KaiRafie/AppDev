import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quartier_sur/components/sidebar.dart';
import 'package:quartier_sur/system/userSession.dart';

class SavedIncidentsPage extends StatefulWidget {
  const SavedIncidentsPage({super.key});

  @override
  State<SavedIncidentsPage> createState() => _SavedIncidentsPageState();
}

class _SavedIncidentsPageState extends State<SavedIncidentsPage> {
  List<Map<String, dynamic>> incidents = [];
  List<String> crimeIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCrimes();
  }

  Future<void> _loadSavedCrimes() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(UserSession.username).get();
      final rawList = userDoc.data()?['crimesSaved'] ?? [];
      final savedIds = (rawList as List).map((e) => e.toString()).toList();
      List<Map<String, dynamic>> loadedIncidents = [];

      for (String crimeId in savedIds) {
        final crimeDoc = await FirebaseFirestore.instance.collection('crimes').doc(crimeId).get();
        final data = crimeDoc.data();
        if (data != null) {
          loadedIncidents.add(data);
        }
      }

      if (mounted) {
        setState(() {
          crimeIds = savedIds;
          incidents = loadedIncidents;
        });
      }
    } catch (e) {
      print('Error loading saved crimes: $e');
    }
  }

  Future<void> _removeCrime(int index) async {
    try {
      crimeIds.removeAt(index);
      incidents.removeAt(index);

      await FirebaseFirestore.instance.collection('users').doc(UserSession.username).update({
        'crimesSaved': crimeIds,
      });

    } catch (e) {
      print('Error removing crime: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 3,),
      backgroundColor: const Color(0xFFA6B19E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A46),
        title: const Text("Saved Incidents", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saved Incidents",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final crime = incidents[index];
                  final location = crime['crimeArea'] ?? 'Unknown location';
                  final type = crime['crimeType'] ?? 'Unknown crime';

                  DateTime? parsedDate;
                  if (crime['date'] is String) {
                    parsedDate = DateTime.tryParse(crime['date']);
                  } else if (crime['date'] is Timestamp) {
                    parsedDate = (crime['date'] as Timestamp).toDate();
                  }

                  final formattedDate = parsedDate != null
                      ? DateFormat('MMM, dd yyyy').format(parsedDate)
                      : 'Unknown date';

                  return Container(
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
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$type reported at $location",
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => _removeCrime(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D4A46),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text("Remove"),
                          ),
                        ),
                      ],
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