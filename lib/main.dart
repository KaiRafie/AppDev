import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quartier_sur/system/notification_service.dart';
import 'components/splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDV3lAVmT4sXUj9v3hf0Tiw0TTptWqyeWc",
          appId: "1001879692422",
          messagingSenderId: "1001879692422",
          projectId: "quartiersur"
      )
  );

  await NotificationService().init();

  runApp(const QuartierSur());
}

class QuartierSur extends StatelessWidget {
  const QuartierSur({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splashscreen(),
    );
  }
}

