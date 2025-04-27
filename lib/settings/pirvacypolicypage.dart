import 'package:flutter/material.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrivacyPolicyPage(),
    );
  }
}


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFA8B5A2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      backgroundColor: backgroundColor,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Text(
              'Purpose of Data Collection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We collect and display crime-related reports for the sole purpose of community awareness, '
                  'statistical analysis, and public safety discussions. This app is not intended for official '
                  'law enforcement or emergency reporting.',
            ),
            SizedBox(height: 16),

            Text(
              'User Anonymity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We do not require users to provide personally identifiable information (PII) to report incidents. '
                  'Reports can be submitted anonymously.',
            ),
            SizedBox(height: 16),

            Text(
              'Data Types Collected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We collect general location (e.g., neighborhood or postal code), time and date of the incident, '
                  'type of incident, and optional descriptions or images. We do not collect names, addresses, '
                  'or phone numbers unless voluntarily provided.',
            ),
            SizedBox(height: 16),

            Text(
              'Location Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We collect general location data associated with reports to display trends and incidents on the map. '
                  'We do not track users’ real-time location.',
            ),
            SizedBox(height: 16),

            Text(
              'No Official Endorsement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'The information reported through the app is user-generated and may not be verified. '
                  'We do not guarantee the accuracy, completeness, or reliability of any report.',
            ),
            SizedBox(height: 16),

            Text(
              'Data Sharing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We do not sell, trade, or otherwise transfer your information to outside parties. '
                  'Data may be shared in aggregated, anonymized formats for research or public awareness purposes.',
            ),
            SizedBox(height: 16),

            Text(
              'Content Moderation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Reports containing discriminatory, hateful, or inappropriate content will be removed without notice. '
                  'Repeated abuse may result in user restrictions.',
            ),
            SizedBox(height: 16),

            Text(
              'Data Retention',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We retain reports for a limited period to support statistical tracking and community awareness. '
                  'After this period, data may be archived or deleted.',
            ),
            SizedBox(height: 16),

            Text(
              'Security Measures',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'We implement standard security measures to protect report submissions and any stored data '
                  'against unauthorized access.',
            ),
            SizedBox(height: 16),

            Text(
              'User Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Users can request the removal of a report they submitted by contacting our support team.',
            ),
            SizedBox(height: 24),

            Text(
              'Important Disclaimer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(
              'If you are witnessing an emergency, contact 911 immediately. '
                  'This app does not replace official law enforcement services.'
                  'To contact 911 in case of an emergency, you can press the '
                  'button "call for help" on the bottom left corner when creating '
                  'a report.',
            ),
          ],
        ),
      ),
    );
  }
}