import 'package:flutter/material.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Inventory Alerts')),
      body: Center(child: Text('Low inventory alerts will go here.')),
    );
  }
}
