import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quartier_sur/prehomepage/loginpage.dart';
import 'package:quartier_sur/userpages/createdpage.dart';
import '../components/sidebar.dart';
import '../system/userSession.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    // Simulate async init (or replace with actual async call if needed)
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          username = UserSession.username;
          debugPrint("username loaded: $username");
        });
      }
    });
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(username);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        throw Exception("User not found.");
      }

      final storedPassword = userDoc.data()!['password'];
      if (storedPassword != oldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
        return;
      }

      await userDocRef.update({'password': newPassword});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } catch (e) {
      debugPrint('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change password')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Delete user document only
      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Clear session and redirect
      UserSession.username = null;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      ); // Adjust route as needed
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(selectedIndex: 4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4F4F),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFA8B5A2),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                140,
              ), // leave space at bottom
              children: [
                SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatedIncidentsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        150,
                        40,
                      ), // width: 150, height: 40
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'View Your Reports',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                StreamBuilder<QuerySnapshot>(
                  stream:
                  FirebaseFirestore.instance
                      .collection('crimes')
                      .where('createdBy', isEqualTo: username)
                      .orderBy('date', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("No recent reports found."),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final date = formatDate(data['date']);
                        final area = data['crimeArea'] ?? 'Unknown area';
                        final type = data['crimeType'] ?? 'Unknown type';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDD8B6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("$type reported at $area"),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final oldPasswordController = TextEditingController();
                          final newPasswordController = TextEditingController();

                          return AlertDialog(
                            title: const Text('Change Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: oldPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'Current Password'),
                                ),
                                TextField(
                                  controller: newPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'New Password'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final oldPass = oldPasswordController.text.trim();
                                  final newPass = newPasswordController.text.trim();
                                  Navigator.pop(context);
                                  if (oldPass.isNotEmpty && newPass.isNotEmpty) {
                                    await _changePassword(oldPass, newPass);
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      minimumSize: const Size(150, 40),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteAccount();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      minimumSize: const Size(150, 40),
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(dynamic rawDate) {
    DateTime? parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate);
    }
    return parsedDate != null
        ? "${_monthName(parsedDate.month)}, ${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.year}"
        : 'Unknown date';
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month];
  }
}
