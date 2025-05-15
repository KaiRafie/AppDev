import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:quartier_sur/components/sidebar.dart';
import 'package:quartier_sur/userpages/savedpage.dart';
import 'package:quartier_sur/userpages/statisticspage.dart';
import '../system/userSession.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> topFiveAreas = [];
  Set<String> expandedCrimeIds = {};

  @override
  void initState() {
    super.initState();
    _fetchTopAreas();
  }

  Future<void> _fetchTopAreas() async {
    final snapshot = await FirebaseFirestore.instance.collection('areaStats').get();
    final data = snapshot.docs.map((doc) => {
      'area': doc.id,
      'count': doc['count'] ?? 0,
    }).toList();
    data.sort((a, b) => b['count'].compareTo(a['count']));
    if (mounted) {
      setState(() {
        topFiveAreas = data.take(5).toList();
      });
    }

  }

  String formatDate(dynamic rawDate) {
    DateTime? parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate);
    }
    return parsedDate != null
        ? DateFormat('MMM, dd yyyy').format(parsedDate)
        : 'Unknown date';
  }

  DateTime _parseDate(dynamic input) {
    if (input is Timestamp) {
      return input.toDate();
    } else if (input is String) {
      try {
        return DateTime.parse(input);
      } catch (_) {
        return DateTime.now();
      }
    } else if (input is DateTime) {
      return input;
    } else {
      return DateTime.now();
    }
  }

  Widget buildCrimeCard(Map<String, dynamic> crime, String scopedCrimeId) {
    final location = crime['crimeArea'] ?? 'Unknown location';
    final type = crime['crimeType'] ?? 'Unknown crime';
    final date = _parseDate(crime['date']);
    final formattedDate = DateFormat('MMM, dd yyyy').format(date);
    final description = crime['description'] ?? 'No description provided.';
    final isExpanded = expandedCrimeIds.contains(scopedCrimeId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            expandedCrimeIds.remove(scopedCrimeId);
          } else {
            expandedCrimeIds.add(scopedCrimeId);
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
            Text(formattedDate, style: const TextStyle(fontSize: 14, color: Colors.white)),
            const SizedBox(height: 4),
            Text("$type reported at $location", style: const TextStyle(fontSize: 16, color: Colors.white)),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]
          ],
        ),
      ),
    );
  }

  Widget buildBarChart(List<Map<String, dynamic>> topAreas) {
    if (topAreas.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text("No data available"),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: topAreas.asMap().entries.map((entry) {
            int index = entry.key;
            var area = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (area['count'] as num).toDouble(),
                  color: const Color(0xFF2F4F4F),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < topAreas.length) {
                    return Text(
                      topAreas[index]['area'].toString().split('-')[0],
                      style: const TextStyle(fontSize: 14),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getSavedCrimes() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(UserSession.username)
        .get();

    final savedIds = List<String>.from(userDoc.data()?['crimesSaved'] ?? []);
    if (savedIds.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('crimes')
        .where(FieldPath.documentId, whereIn: savedIds.take(5).toList())
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
      ),
      drawer: SideBar(selectedIndex: 0),
      backgroundColor: const Color(0xFFA8B5A2),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "QuartierSur",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Reports'),
                  ),
                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('crimes')
                        .orderBy('date', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();

                      final crimes = snapshot.data!.docs; // List<DocumentSnapshot>

                      return ListView.builder(
                        itemCount: crimes.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final doc = crimes[index];
                          final crime = doc.data() as Map<String, dynamic>;
                          final crimeId = doc.id;
                          return buildCrimeCard(crime, 'latest_$crimeId');
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => StatisticsPage()));
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xFF2F4F4F)),
                        ),
                        child: Text("View Statistics", style: TextStyle(color: Colors.white)),
                      ),
                      Text("View Statistics on the last Reports", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 60),
                  buildBarChart(topFiveAreas),

                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SavedIncidentsPage()));
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Color(0xFF2F4F4F)),
                        ),
                        child: Text("Saved Reports", style: TextStyle(color: Colors.white)),
                      ),
                      Text("View Last Saved Reports", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  FutureBuilder<List<DocumentSnapshot>>(
                    future: getSavedCrimes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final savedCrimes = snapshot.data!;
                      return ListView.builder(
                          itemCount: savedCrimes.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final doc = savedCrimes[index];
                            final crime = doc.data() as Map<String, dynamic>;
                            final crimeId = doc.id;
                            return buildCrimeCard(crime, 'saved_$crimeId');
                          }
                      );
                    },
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}