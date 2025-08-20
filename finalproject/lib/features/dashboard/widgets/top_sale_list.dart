import 'package:flutter/material.dart';

class TopSaleList extends StatelessWidget {
  const TopSaleList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for top sale list
    return Card(
      elevation: 2,
      child: Container(
        height: 420,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Top sale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(child: Center(child: Text('Top sale list goes here.'))),
          ],
        ),
      ),
    );
  }
}
