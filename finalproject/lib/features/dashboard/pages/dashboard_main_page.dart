import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../core/infrastructure/seed_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/summary_card.dart';
import '../../product/product_page.dart';
import '../../alerts/alerts_page.dart';
import '../../reports/reports_page.dart';
import '../../auth/services/auth_service.dart';
import '../../settings/settings_page.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

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

  String _productTrendType = 'Monthly';
  String _stockTrendType = 'Monthly';
  String _categoryTrendType = 'Monthly';
  String _supplierTrendType = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intellistock'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightSurface,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.lightSurface,
                    child: Icon(
                      Icons.inventory_2,
                      size: 35,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Intellistock',
                    style: TextStyle(
                      color: AppColors.lightSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Smart Inventory Management',
                    style: TextStyle(
                      color: AppColors.lightSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: const Text('Products'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Alerts'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlertsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.assessment),
                    title: const Text('Reports'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Help & Support'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement help page
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final authService = AuthService();
                await authService.signOut();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
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

                  // Trend logic for all cards
                  final now = DateTime.now();
                  // --- Product Trend ---
                  List<double> productTrendPoints = [];
                  String productTimeFilter = _productTrendType;
                  if (productTimeFilter == 'Weekly') {
                    List<int> weeklyCounts = List.filled(8, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final weekDiff =
                            now.difference(dateReceived).inDays ~/ 7;
                        if (weekDiff >= 0 && weekDiff < 8) {
                          weeklyCounts[7 - weekDiff]++;
                        }
                      }
                    }
                    productTrendPoints = weeklyCounts
                        .map((e) => e.toDouble())
                        .toList();
                  } else if (productTimeFilter == 'Monthly') {
                    List<int> monthlyCounts = List.filled(12, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final monthDiff =
                            (now.year - dateReceived.year) * 12 +
                            (now.month - dateReceived.month);
                        if (monthDiff >= 0 && monthDiff < 12) {
                          monthlyCounts[11 - monthDiff]++;
                        }
                      }
                    }
                    productTrendPoints = monthlyCounts
                        .map((e) => e.toDouble())
                        .toList();
                  } else if (productTimeFilter == 'Yearly') {
                    List<int> yearlyCounts = List.filled(5, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final yearDiff = now.year - dateReceived.year;
                        if (yearDiff >= 0 && yearDiff < 5) {
                          yearlyCounts[4 - yearDiff]++;
                        }
                      }
                    }
                    productTrendPoints = yearlyCounts
                        .map((e) => e.toDouble())
                        .toList();
                  }

                  // --- Stock Trend ---
                  List<double> stockTrendPoints = [];
                  String stockTimeFilter = _stockTrendType;
                  if (stockTimeFilter == 'Weekly') {
                    List<int> weeklyStock = List.filled(8, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final weekDiff =
                            now.difference(dateReceived).inDays ~/ 7;
                        if (weekDiff >= 0 && weekDiff < 8) {
                          weeklyStock[7 -
                              weekDiff] += (doc['Stock_Quantity'] is int
                              ? doc['Stock_Quantity'] as int
                              : int.tryParse(
                                      doc['Stock_Quantity']?.toString() ?? '',
                                    ) ??
                                    0);
                        }
                      }
                    }
                    stockTrendPoints = weeklyStock
                        .map((e) => e.toDouble())
                        .toList();
                  } else if (stockTimeFilter == 'Monthly') {
                    List<int> monthlyStock = List.filled(12, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final monthDiff =
                            (now.year - dateReceived.year) * 12 +
                            (now.month - dateReceived.month);
                        if (monthDiff >= 0 && monthDiff < 12) {
                          monthlyStock[11 -
                              monthDiff] += (doc['Stock_Quantity'] is int
                              ? doc['Stock_Quantity'] as int
                              : int.tryParse(
                                      doc['Stock_Quantity']?.toString() ?? '',
                                    ) ??
                                    0);
                        }
                      }
                    }
                    stockTrendPoints = monthlyStock
                        .map((e) => e.toDouble())
                        .toList();
                  } else if (stockTimeFilter == 'Yearly') {
                    List<int> yearlyStock = List.filled(5, 0);
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final yearDiff = now.year - dateReceived.year;
                        if (yearDiff >= 0 && yearDiff < 5) {
                          yearlyStock[4 -
                              yearDiff] += (doc['Stock_Quantity'] is int
                              ? doc['Stock_Quantity'] as int
                              : int.tryParse(
                                      doc['Stock_Quantity']?.toString() ?? '',
                                    ) ??
                                    0);
                        }
                      }
                    }
                    stockTrendPoints = yearlyStock
                        .map((e) => e.toDouble())
                        .toList();
                  }

                  // --- Category Trend ---
                  List<double> categoryTrendPoints = [];
                  String categoryTimeFilter = _categoryTrendType;
                  if (categoryTimeFilter == 'Weekly') {
                    List<Set> weeklyCategories = List.generate(
                      8,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final weekDiff =
                            now.difference(dateReceived).inDays ~/ 7;
                        if (weekDiff >= 0 && weekDiff < 8) {
                          weeklyCategories[7 - weekDiff].add(doc['Catagory']);
                        }
                      }
                    }
                    categoryTrendPoints = weeklyCategories
                        .map((set) => set.length.toDouble())
                        .toList();
                  } else if (categoryTimeFilter == 'Monthly') {
                    List<Set> monthlyCategories = List.generate(
                      12,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final monthDiff =
                            (now.year - dateReceived.year) * 12 +
                            (now.month - dateReceived.month);
                        if (monthDiff >= 0 && monthDiff < 12) {
                          monthlyCategories[11 - monthDiff].add(
                            doc['Catagory'],
                          );
                        }
                      }
                    }
                    categoryTrendPoints = monthlyCategories
                        .map((set) => set.length.toDouble())
                        .toList();
                  } else if (categoryTimeFilter == 'Yearly') {
                    List<Set> yearlyCategories = List.generate(
                      5,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final yearDiff = now.year - dateReceived.year;
                        if (yearDiff >= 0 && yearDiff < 5) {
                          yearlyCategories[4 - yearDiff].add(doc['Catagory']);
                        }
                      }
                    }
                    categoryTrendPoints = yearlyCategories
                        .map((set) => set.length.toDouble())
                        .toList();
                  }

                  // --- Supplier Trend ---
                  List<double> supplierTrendPoints = [];
                  String supplierTimeFilter = _supplierTrendType;
                  if (supplierTimeFilter == 'Weekly') {
                    List<Set> weeklySuppliers = List.generate(
                      8,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final weekDiff =
                            now.difference(dateReceived).inDays ~/ 7;
                        if (weekDiff >= 0 && weekDiff < 8) {
                          weeklySuppliers[7 - weekDiff].add(
                            doc['Supplier_Name'],
                          );
                        }
                      }
                    }
                    supplierTrendPoints = weeklySuppliers
                        .map((set) => set.length.toDouble())
                        .toList();
                  } else if (supplierTimeFilter == 'Monthly') {
                    List<Set> monthlySuppliers = List.generate(
                      12,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final monthDiff =
                            (now.year - dateReceived.year) * 12 +
                            (now.month - dateReceived.month);
                        if (monthDiff >= 0 && monthDiff < 12) {
                          monthlySuppliers[11 - monthDiff].add(
                            doc['Supplier_Name'],
                          );
                        }
                      }
                    }
                    supplierTrendPoints = monthlySuppliers
                        .map((set) => set.length.toDouble())
                        .toList();
                  } else if (supplierTimeFilter == 'Yearly') {
                    List<Set> yearlySuppliers = List.generate(
                      5,
                      (_) => <dynamic>{},
                    );
                    for (var doc in products) {
                      final dateReceivedStr = doc['Date_Received'];
                      DateTime? dateReceived;
                      if (dateReceivedStr is String) {
                        try {
                          dateReceived = DateTime.parse(dateReceivedStr);
                        } catch (_) {
                          final parts = dateReceivedStr.split('/');
                          if (parts.length == 3) {
                            dateReceived = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                            );
                          }
                        }
                      }
                      if (dateReceived != null) {
                        final yearDiff = now.year - dateReceived.year;
                        if (yearDiff >= 0 && yearDiff < 5) {
                          yearlySuppliers[4 - yearDiff].add(
                            doc['Supplier_Name'],
                          );
                        }
                      }
                    }
                    supplierTrendPoints = yearlySuppliers
                        .map((set) => set.length.toDouble())
                        .toList();
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isNarrow = constraints.maxWidth < 900;
                      final double itemWidth = isNarrow
                          ? (constraints.maxWidth - 24) / 2
                          : (constraints.maxWidth - 48) / 4;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: SummaryCard(
                              title: 'Total Products',
                              value: '$totalProducts',
                              percent: percentChange,
                              color: Colors.green,
                              icon: Icons.shopping_bag,
                              timeFilter: productTimeFilter,
                              onTimeFilterChanged: (val) {
                                setState(() {
                                  _productTrendType = val ?? 'Monthly';
                                });
                              },
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
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SummaryCard(
                              title: 'Total Stock',
                              value: '$totalStock',
                              percent: percentChange,
                              color: Colors.orange,
                              icon: Icons.inventory,
                              timeFilter: stockTimeFilter,
                              onTimeFilterChanged: (val) {
                                setState(() {
                                  _stockTrendType = val ?? 'Monthly';
                                });
                              },
                              miniGraph: SizedBox(
                                height: 32,
                                width: 60,
                                child: CustomPaint(
                                  painter: MiniGraphPainter(
                                    color: Colors.orange,
                                    points: stockTrendPoints,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SummaryCard(
                              title: 'Categories',
                              value: '${categories.length}',
                              percent: percentChange,
                              color: Colors.purple,
                              icon: Icons.category,
                              timeFilter: categoryTimeFilter,
                              onTimeFilterChanged: (val) {
                                setState(() {
                                  _categoryTrendType = val ?? 'Monthly';
                                });
                              },
                              miniGraph: SizedBox(
                                height: 32,
                                width: 60,
                                child: CustomPaint(
                                  painter: MiniGraphPainter(
                                    color: Colors.purple,
                                    points: categoryTrendPoints,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SummaryCard(
                              title: 'Suppliers',
                              value: '${suppliers.length}',
                              percent: percentChange,
                              color: Colors.blue,
                              icon: Icons.people,
                              timeFilter: supplierTimeFilter,
                              onTimeFilterChanged: (val) {
                                setState(() {
                                  _supplierTrendType = val ?? 'Monthly';
                                });
                              },
                              miniGraph: SizedBox(
                                height: 32,
                                width: 60,
                                child: CustomPaint(
                                  painter: MiniGraphPainter(
                                    color: Colors.blue,
                                    points: supplierTrendPoints,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // ...existing code for other dashboard widgets...
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
