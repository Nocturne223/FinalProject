import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/infrastructure/seed_products.dart';
import '../helpers/responsive_layout_helper.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_summary_cards.dart';
import '../widgets/dashboard_activity_widgets.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

  @override
  State<DashboardMainPage> createState() => _DashboardMainPageState();
}

class _DashboardMainPageState extends State<DashboardMainPage> {
  bool _isSeeding = false;
  String _productTrendType = 'Monthly';
  String _stockTrendType = 'Monthly';
  String _categoryTrendType = 'Monthly';
  String _supplierTrendType = 'Monthly';

  Future<void> _seedProducts() async {
    setState(() => _isSeeding = true);
    await seedProductsFromCsv();
    setState(() => _isSeeding = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seeding complete!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellistock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightSurface,
      ),
      drawer: const DashboardDrawer(),
      body: Padding(
        padding: EdgeInsets.all(
          ResponsiveLayoutHelper.getHorizontalPadding(context),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      DashboardSummaryCards(
                        products: products,
                        productTrendType: _productTrendType,
                        stockTrendType: _stockTrendType,
                        categoryTrendType: _categoryTrendType,
                        supplierTrendType: _supplierTrendType,
                        onProductTrendChanged: (val) {
                          setState(() {
                            _productTrendType = val ?? 'Monthly';
                          });
                        },
                        onStockTrendChanged: (val) {
                          setState(() {
                            _stockTrendType = val ?? 'Monthly';
                          });
                        },
                        onCategoryTrendChanged: (val) {
                          setState(() {
                            _categoryTrendType = val ?? 'Monthly';
                          });
                        },
                        onSupplierTrendChanged: (val) {
                          setState(() {
                            _supplierTrendType = val ?? 'Monthly';
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Low Inventory Widget
                      LowInventoryWidget(products: products),

                      const SizedBox(height: 16),

                      // Recent Activity Widget
                      RecentActivityWidget(products: products),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSeeding ? null : _seedProducts,
        label: _isSeeding
            ? const Text('Seeding...')
            : const Text('Seed Products'),
        icon: const Icon(Icons.cloud_upload),
      ),
    );
  }
}
