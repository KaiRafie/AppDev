import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../components/sidebar.dart'; // adjust path if needed

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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: const Color(0xFFCDD8B6),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F4F4F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
            dialogBackgroundColor: const Color(0xFFCDD8B6),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F4F4F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

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

  Future<void> _createCrime(String username, String createdDate, String crimeType
      , String description, String date, String time) async{

    /*
    * todo: make the id auto increment by fetching the last id from the db
    * todo: and increment it here
    * todo: create a crime and save it in the db
    * */


  }

  Future<void> _countCrime(String crimeType) async{
    /*
    * todo: get the crime type's count and increment it here each time the type
    * todo: is used and save it in the crimeStats collection
    * */
  }

  Future<void> _saveCrimeId(String username) async{
    /*
    * todo: based on the username, save the crime's id in the user's crimeCreated array
    * */
  }

  String? selectedValue;

  final List<String> items = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 2,),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Create Report'),
      ),
      body: Container(
        color: const Color(0xFFA8B5A2),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // drop down list of crime types
            DropdownButtonFormField<String>(
              hint: Text("Select a crime type", style: TextStyle(color: Colors.black)),
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue;
                });
              },
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFCDD8B6), // Match your form color
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        : DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(selectedDateTime!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                    ),
                    child: const Text('Pick'),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Bottom row buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text('Call for help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8EA682),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4F4F),
                  ),
                  child: const Text('Post Report'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
