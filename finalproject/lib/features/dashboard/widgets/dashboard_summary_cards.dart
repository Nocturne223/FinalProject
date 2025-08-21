import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/dashboard_data_helper.dart';
import 'summary_card.dart';

class DashboardSummaryCards extends StatelessWidget {
  final List<QueryDocumentSnapshot> products;
  final String productTrendType;
  final String stockTrendType;
  final String categoryTrendType;
  final String supplierTrendType;
  final Function(String?) onProductTrendChanged;
  final Function(String?) onStockTrendChanged;
  final Function(String?) onCategoryTrendChanged;
  final Function(String?) onSupplierTrendChanged;

  const DashboardSummaryCards({
    Key? key,
    required this.products,
    required this.productTrendType,
    required this.stockTrendType,
    required this.categoryTrendType,
    required this.supplierTrendType,
    required this.onProductTrendChanged,
    required this.onStockTrendChanged,
    required this.onCategoryTrendChanged,
    required this.onSupplierTrendChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = DashboardDataHelper.processDashboardData(products);

    final productTrendPoints = DashboardDataHelper.calculateTrendPoints(
      products,
      productTrendType,
      'Date_Received',
    );

    // ignore: unused_local_variable
    final stockTrendPoints = DashboardDataHelper.calculateTrendPoints(
      products,
      stockTrendType,
      'Stock_Quantity',
    );

    final categoryTrendPoints = DashboardDataHelper.calculateTrendPoints(
      products,
      categoryTrendType,
      'Catagory',
    );

    final supplierTrendPoints = DashboardDataHelper.calculateTrendPoints(
      products,
      supplierTrendType,
      'Supplier_Name',
    );

    final timeFilters = ['Monthly', 'Weekly', 'Yearly'];
    String safeDropdownValue(String? value) {
      if (value == null || !timeFilters.contains(value)) {
        return timeFilters.first;
      }
      return value;
    }

    final summaryCards = [
      SummaryCard(
        title: 'Total Products',
        value: '${data['totalProducts']}',
        percent: '+1.56%',
        color: Colors.green,
        icon: Icons.shopping_bag,
        timeFilter: '',
        miniGraph: SizedBox(
          height: 32,
          width: 60,
          child: CustomPaint(
            painter: MiniGraphPainter(
              color: Colors.green,
              points: productTrendPoints,
            ),
          ),
        ),
      ),
      SummaryCard(
        title: 'Low Inventory',
        value: '${data['lowInventoryCount']}',
        percent: '',
        color: Colors.red,
        icon: Icons.warning,
        timeFilter: '',
        miniGraph: const SizedBox.shrink(),
      ),
      SummaryCard(
        title: 'Top Category',
        value: data['topCategory'] ?? 'N/A',
        percent: '',
        color: Colors.blue,
        icon: Icons.category,
        timeFilter: safeDropdownValue(categoryTrendType),
        onTimeFilterChanged: onCategoryTrendChanged,
        timeFilterOptions: timeFilters,
        miniGraph: SizedBox(
          height: 32,
          width: 60,
          child: CustomPaint(
            painter: MiniGraphPainter(
              color: Colors.blue,
              points: categoryTrendPoints,
            ),
          ),
        ),
      ),
      SummaryCard(
        title: 'Recent Additions',
        value: '${data['recentAdditions']}',
        percent: '',
        color: Colors.orange,
        icon: Icons.new_releases,
        timeFilter: '',
        miniGraph: const SizedBox.shrink(),
      ),
      SummaryCard(
        title: 'Active Suppliers',
        value: '${data['activeSuppliers']}',
        percent: '',
        color: Colors.purple,
        icon: Icons.people,
        timeFilter: safeDropdownValue(supplierTrendType),
        onTimeFilterChanged: onSupplierTrendChanged,
        timeFilterOptions: timeFilters,
        miniGraph: SizedBox(
          height: 32,
          width: 60,
          child: CustomPaint(
            painter: MiniGraphPainter(
              color: Colors.purple,
              points: supplierTrendPoints,
            ),
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isLandscape = screenHeight < constraints.maxWidth;
        final is414pxPhone =
            constraints.maxWidth >= 414 &&
            constraints.maxWidth < 450; // Specific handling for 414px phones

        double maxCardWidth;
        double childAspectRatio;
        double mainAxisSpacing;
        double crossAxisSpacing;

        if (constraints.maxWidth < 600) {
          // Mobile: 1 column
          maxCardWidth = constraints.maxWidth - 32;
          if (is414pxPhone) {
            // Special handling for 414px phones to prevent overflow
            childAspectRatio = isLandscape
                ? 2.0
                : 1.5; // Wider ratio for 414px phones
          } else {
            childAspectRatio = isLandscape
                ? 1.8
                : 1.3; // Standard landscape ratio
          }
          mainAxisSpacing = 16;
          crossAxisSpacing = 16;
        } else if (constraints.maxWidth < 900) {
          // Tablet: 2 columns
          maxCardWidth = constraints.maxWidth / 2 - 32;
          childAspectRatio = isLandscape
              ? 2.0
              : 1.4; // Wider ratio for landscape
          mainAxisSpacing = 20;
          crossAxisSpacing = 20;
        } else {
          // Desktop: 3 columns
          maxCardWidth = constraints.maxWidth / 3 - 32;
          childAspectRatio = isLandscape
              ? 2.2
              : 1.5; // Wider ratio for landscape
          mainAxisSpacing = 24;
          crossAxisSpacing = 24;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCardWidth,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: summaryCards.length,
          itemBuilder: (context, idx) {
            return summaryCards[idx];
          },
        );
      },
    );
  }
}

class MiniGraphPainter extends CustomPainter {
  final Color color;
  final List<double> points;

  MiniGraphPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs();

    if (range == 0) return;

    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - ((points[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
