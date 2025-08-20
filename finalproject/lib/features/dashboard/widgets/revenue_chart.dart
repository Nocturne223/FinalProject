import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for revenue chart
    return Card(
      elevation: 2,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(child: Center(child: Text('Revenue chart goes here.'))),
          ],
        ),
      ),
    );
  }
}
