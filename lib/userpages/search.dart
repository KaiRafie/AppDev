import 'package:flutter/material.dart';
import '../components/sidebar.dart'; // Adjust if in a subfolder

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
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedBorough = '';
  String selectedFilter = '';

  final boroughs = [
    'Ahuntsic-Cartierville',
    'Anjou',
    'Côte-des-Neiges–Notre-Dame-de-Grâce',
    'Lachine',
    'LaSalle',
    'Le Plateau-Mont-Royal',
    'Le Sud-Ouest',
    "L'Île-Bizard–Sainte-Geneviève",
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

  final filters = ['A-Z', 'Newest', 'Oldest'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 1,),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Search'),
      ),
      body: Container(
        color: const Color(0xFFA8B5A2),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Search Incidents',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBorough == '' ? null : selectedBorough,
                    hint: const Text('Location'),
                    items: boroughs
                        .map((borough) => DropdownMenuItem(
                      value: borough,
                      child: Text(
                        borough,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedBorough = value);
                      }
                    },
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                  ),
                ),

// Filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter == '' ? null : selectedFilter,
                    hint: const Text('Order By'),
                    items: filters
                        .map((filter) => DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedFilter = value);
                      }
                    },
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Results
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDD8B6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Apr, 26 2025",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Auto-theft reported at West Mount Montreal"),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
