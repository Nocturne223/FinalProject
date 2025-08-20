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
    Key? key,
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    required this.timeFilter,
    required this.miniGraph,
    this.onTimeFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: color),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            miniGraph,
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      percent,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: color),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: timeFilter,
                    items: ['Weekly', 'Monthly', 'Yearly']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: onTimeFilterChanged,
                    underline: Container(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    borderRadius: BorderRadius.circular(8),
                  ),
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
