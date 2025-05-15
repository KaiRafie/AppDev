import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quartier_sur/components/sidebar.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
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

  Map<String, int> crimeData = {};
  Map<String, double> processedData = {};
  bool isLoading = true;

  List<Map<String, dynamic>> topFiveAreas = [];
  List<Map<String, dynamic>> allAreasData = [];

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
    _fetchTopAreas();
  }

  Future<void> fetchCrimeData() async {
    final Map<String, int> rawData = {};
    try {
      // Fetch all 17 documents in parallel
      final futures = crimeTypes.map((type) =>
          FirebaseFirestore.instance.collection('crimeStats').doc(type).get());
      final snapshots = await Future.wait(futures);

      for (int i = 0; i < crimeTypes.length; i++) {
        final data = snapshots[i].data();
        final count = data != null ? int.tryParse(data['count'].toString()) ?? 0 : 0;
        rawData[crimeTypes[i]] = count;
      }

      final int total = rawData.values.fold(0, (sum, item) => sum + item);

      final Map<String, double> displayMap = {};
      if (total == 0) {
        // Avoid division by 0 and fallback to 0% for all
        rawData.forEach((key, value) => displayMap[key] = 0.0);
      } else {
        final sorted = rawData.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        int otherTotal = 0;
        for (int i = 0; i < sorted.length; i++) {
          if (i < 4) {
            displayMap[sorted[i].key] = (sorted[i].value / total) * 100;
          } else {
            otherTotal += sorted[i].value;
          }
        }

        if (otherTotal > 0) {
          displayMap['Other'] = (otherTotal / total) * 100;
        }
      }

      if (mounted) {
        setState(() {
          crimeData = rawData;
          processedData = displayMap;
          isLoading = false;
        });
      }

      print('Raw counts: $rawData');
      print('Processed percentages: $displayMap');

    } catch (e) {
      print('Error fetching stats: $e');
      setState(() => isLoading = false);
    }
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
        allAreasData = data;
        topFiveAreas = data.take(5).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 0),
      backgroundColor: const Color(0xFFA6B19E),
      appBar: AppBar(
        title: const Text('Most Recent Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D4A46),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Most Reported Incidents",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.1,
              child: PieChart(
                PieChartData(
                  sections: generatePieSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Detailed Breakdown:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: crimeTypes.length,
              itemBuilder: (context, index) {
                final label = crimeTypes[index];
                final count = crimeData[label] ?? 0;
                final total = crimeData.values.fold(0, (sum, item) => sum + item);
                final percent = total > 0 ? (count / total) * 100 : 0.0;

                return ListTile(
                  title: Text(label),
                  trailing: Text("${percent.toStringAsFixed(1)}%"),
                );
              },
            ),
            const SizedBox(height: 50),
            const Text(
              "Most Reported Areas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 60),
            buildBarChart(topFiveAreas),
            const SizedBox(height: 30),
            buildAreaList(allAreasData),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> generatePieSections() {
    final colors = [
      Colors.cyan,
      Colors.amber,
      Colors.pinkAccent,
      Colors.deepOrange,
      Colors.blueGrey,
    ];

    List<PieChartSectionData> sections = [];
    int i = 0;

    processedData.forEach((label, percent) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: percent,
          title: '$label\n${percent.toStringAsFixed(1)}%',
          radius: 250,
          titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          titlePositionPercentageOffset: 0.6,
        ),
      );
      i++;
    });

    return sections;
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
}

Widget buildAreaList(List<Map<String, dynamic>> allAreas) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: allAreas.length,
    itemBuilder: (context, index) {
      final area = allAreas[index];
      return ListTile(
        title: Text(area['area']),
        trailing: Text("Count: ${area['count']}"),
      );
    },
  );
}
