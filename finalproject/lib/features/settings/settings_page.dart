import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Evaluation'),
            subtitle: const Text(
              'View performance, scalability, and usability metrics',
            ),
            onTap: () => Navigator.of(context).pushNamed('/evaluation'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Intellistock – Smart Inventory Management'),
          ),
        ],
      ),
    );
  }
}
