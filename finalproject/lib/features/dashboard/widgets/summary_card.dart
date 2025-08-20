import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String percent;
  final Color color;
  final IconData icon;
  final String timeFilter;
  final Widget miniGraph;
  final ValueChanged<String?>? onTimeFilterChanged;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    required this.timeFilter,
    required this.miniGraph,
    this.onTimeFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            miniGraph,
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(percent, style: TextStyle(color: color)),
                  ],
                ),
                DropdownButton<String>(
                  value: timeFilter,
                  items: ['Weekly', 'Monthly', 'Yearly']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onTimeFilterChanged,
                  underline: Container(),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniGraphPainter extends CustomPainter {
  final Color color;
  final List<double> points;
  MiniGraphPainter({required this.color, required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (points.isNotEmpty) {
      double maxVal = points.reduce((a, b) => a > b ? a : b);
      double minVal = points.reduce((a, b) => a < b ? a : b);
      double range = (maxVal - minVal).abs();
      if (range == 0) range = 1;
      for (int i = 0; i < points.length; i++) {
        double x = size.width * i / (points.length - 1);
        double y = size.height - ((points[i] - minVal) / range) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
