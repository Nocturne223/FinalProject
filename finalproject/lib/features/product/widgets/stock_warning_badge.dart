import 'package:flutter/material.dart';

class StockWarningBadge extends StatelessWidget {
  final bool isLowStock;
  final int stockQuantity;
  final int reorderLevel;

  const StockWarningBadge({
    super.key,
    required this.isLowStock,
    required this.stockQuantity,
    required this.reorderLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLowStock) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Low Stock ($stockQuantity/$reorderLevel)',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
