import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final List<String> _alerts = [];

  @override
  void initState() {
    super.initState();
    // Listen for FCM messages and add to alerts list
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final alert = message.notification?.title ?? 'Alert';
      final body = message.notification?.body ?? '';
      setState(() {
        _alerts.add('$alert: $body');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Inventory Alerts')),
      body: _alerts.isEmpty
          ? const Center(child: Text('No alerts received yet.'))
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(_alerts[index]),
              ),
            ),
    );
  }
}
