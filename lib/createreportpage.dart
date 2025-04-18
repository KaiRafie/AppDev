import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sidebar.dart'; // adjust path if needed

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        selectedIndex: -1,
        onItemTap: (index) => Navigator.pop(context),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Create Report'),
      ),
      body: Container(
        color: const Color(0xFFA8B5A2),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
