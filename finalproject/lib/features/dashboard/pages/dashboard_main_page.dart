import 'package:flutter/material.dart';
import '../../../core/infrastructure/seed_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/summary_card.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/pie_chart.dart';
import '../widgets/top_sale_list.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({Key? key}) : super(key: key);

  @override
  State<DashboardMainPage> createState() => _DashboardMainPageState();
}

class _DashboardMainPageState extends State<DashboardMainPage> {
  bool _isSeeding = false;

  Future<void> _seedProducts() async {
    setState(() => _isSeeding = true);
    await seedProductsFromCsv();
    setState(() => _isSeeding = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Seeding complete!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecomus'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text(
                'Ecommerce',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Product'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Category'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Users'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Setting'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  final totalProducts = products.length;
                  final totalStock = products.fold<int>(
                    0,
                    (sum, doc) =>
                        sum +
                        (doc['Stock_Quantity'] is int
                            ? doc['Stock_Quantity'] as int
                            : int.tryParse(
                                    doc['Stock_Quantity']?.toString() ?? '',
                                  ) ??
                                  0),
                  );
                  final categories = products
                      .map((doc) => doc['Catagory'])
                      .toSet();
                  final suppliers = products
                      .map((doc) => doc['Supplier_Name'])
                      .toSet();
                  final percentChange = '+1.56%';
                  final timeFilter = 'Weekly';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(
                        title: 'Total Products',
                        value: '$totalProducts',
                        percent: percentChange,
                        color: Colors.green,
                        icon: Icons.shopping_bag,
                        timeFilter: timeFilter,
                        miniGraph: Container(
                          height: 32,
                          width: 60,
                          child: CustomPaint(
                            painter: MiniGraphPainter(color: Colors.green),
                          ),
                        ),
                      ),
                      SummaryCard(
                        title: 'Total Stock',
                        value: '$totalStock',
                        percent: percentChange,
                        color: Colors.orange,
                        icon: Icons.inventory,
                        timeFilter: timeFilter,
                        miniGraph: Container(
                          height: 32,
                          width: 60,
                          child: CustomPaint(
                            painter: MiniGraphPainter(color: Colors.orange),
                          ),
                        ),
                      ),
                      SummaryCard(
                        title: 'Categories',
                        value: '${categories.length}',
                        percent: percentChange,
                        color: Colors.purple,
                        icon: Icons.category,
                        timeFilter: timeFilter,
                        miniGraph: Container(
                          height: 32,
                          width: 60,
                          child: CustomPaint(
                            painter: MiniGraphPainter(color: Colors.purple),
                          ),
                        ),
                      ),
                      SummaryCard(
                        title: 'Suppliers',
                        value: '${suppliers.length}',
                        percent: percentChange,
                        color: Colors.blue,
                        icon: Icons.people,
                        timeFilter: timeFilter,
                        miniGraph: Container(
                          height: 32,
                          width: 60,
                          child: CustomPaint(
                            painter: MiniGraphPainter(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: const [
                        RevenueChart(),
                        SizedBox(height: 24),
                        PieChartWidget(),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: TopSaleList()),
                ],
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
