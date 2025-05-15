import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quartier_sur/components/sidebar.dart';
import 'package:quartier_sur/prehomepage/loginpage.dart';
import 'package:quartier_sur/system/userSession.dart';

class SearchIncidentsPage extends StatefulWidget {
  const SearchIncidentsPage({super.key});

  @override
  State<SearchIncidentsPage> createState() => _SearchIncidentsPageState();
}

class _SearchIncidentsPageState extends State<SearchIncidentsPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> allAreas = [
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

  String? selectedArea;
  String sortBy = 'Most Recent';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> allCrimes = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredCrimes = [];

  Set<String> expandedCrimeIds = {};

  @override
  void initState() {
    super.initState();
    _loadCrimes();
  }

  Future<void> _loadCrimes() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('crimes').get();

      if (snapshot.docs.isEmpty) {
        print("No crime documents found.");
      } else {
        print("Loaded ${snapshot.docs.length} crimes");
      }

      if (mounted) {
        setState(() {
          allCrimes = snapshot.docs;
          _applyFilters();
        });
      }
    } catch (e) {
      print("Firestore error: $e");
    }
  }

  void _applyFilters() {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = allCrimes;

    final keyword = _searchController.text.toLowerCase();
    if (keyword.isNotEmpty) {
      filtered =
          filtered.where((doc) {
            final data = doc.data();
            final content =
            "${data['crimeType']} ${data['crimeArea']} ${data['description']}"
                .toLowerCase();
            return content.contains(keyword);
          }).toList();
    }

    if (selectedArea != null) {
      filtered =
          filtered
              .where((doc) => doc.data()['crimeArea'] == selectedArea)
              .toList();
    }

    if (sortBy == 'A–Z') {
      filtered.sort(
            (a, b) => (a.data()['crimeType'] ?? '').compareTo(
          b.data()['crimeType'] ?? '',
        ),
      );
    } else if (sortBy == 'Most Recent') {
      filtered.sort((a, b) {
        final aDate = _parseDate(a.data()['date']);
        final bDate = _parseDate(b.data()['date']);
        return bDate.compareTo(aDate);
      });
    } else if (sortBy == 'Oldest') {
      filtered.sort((a, b) {
        final aDate = _parseDate(a.data()['date']);
        final bDate = _parseDate(b.data()['date']);
        return aDate.compareTo(bDate);
      });
    }

    if (mounted) {
      setState(() {
        filteredCrimes = filtered;
      });
    }
  }

  DateTime _parseDate(dynamic dateField) {
    if (dateField is Timestamp) return dateField.toDate();
    if (dateField is String)
      return DateTime.tryParse(dateField) ?? DateTime(2000);
    return DateTime(2000);
  }

  Future<void> _saveCrimeToUser(
      String username,
      String crimeId,
      BuildContext context,
      ) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(username);
      await userRef.update({
        'crimesSaved': FieldValue.arrayUnion([crimeId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crime saved to your profile')),
      );
    } catch (e) {
      print("Error saving crime: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save crime')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 1),
      backgroundColor: const Color(0xFFA6B19E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A46),
        title: const Text(
          "Search Incidents",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Search by ID, Name, or Location",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search Incidents',
                filled: true,
                fillColor: const Color(0xFFD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedArea,
                    onChanged: (value) {
                      selectedArea = value;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFD9D9D9),
                      filled: true,
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                    allAreas
                        .map(
                          (area) => DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    onChanged: (value) {
                      sortBy = value!;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      fillColor: const Color(0xFFD9D9D9),
                      filled: true,
                      labelText: 'Filter By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                    ['A–Z', 'Most Recent', 'Oldest'].map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCrimes.length,
                itemBuilder: (context, index) {
                  final doc = filteredCrimes[index];
                  final crime = doc.data();
                  final String crimeId = doc.id;
                  final location = crime['crimeArea'] ?? 'Unknown location';
                  final type = crime['crimeType'] ?? 'Unknown crime';
                  final date = _parseDate(crime['date']);
                  final formattedDate = DateFormat('MMM, dd yyyy').format(date);
                  final description =
                      crime['description'] ?? 'No description provided.';
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
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
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => _saveCrimeToUser(
                                  UserSession.username!,
                                  crimeId,
                                  context,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D4A46),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
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
