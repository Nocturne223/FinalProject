import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardDataHelper {
  static Map<String, dynamic> processDashboardData(List<QueryDocumentSnapshot> products) {
    final totalProducts = products.length;
    final totalStock = products.fold<int>(
      0,
      (sum, doc) => sum + _parseStockQuantity(doc['Stock_Quantity']),
    );
    
    final categories = products.map((doc) => doc['Catagory']).toSet();
    final suppliers = products.map((doc) => doc['Supplier_Name']).toSet();
    
    // Calculate category stock breakdown
    final Map<String, int> categoryStock = {};
    for (var doc in products) {
      final cat = doc['Catagory'] ?? 'Unknown';
      final qty = _parseStockQuantity(doc['Stock_Quantity']);
      categoryStock[cat] = (categoryStock[cat] ?? 0) + qty;
    }
    
    // Find low inventory items
    final lowInventory = products.where((doc) {
      final qty = _parseStockQuantity(doc['Stock_Quantity']);
      return qty < 10; // threshold
    }).toList();
    
    // Get recent activity
    final recentActivity = products
        .where((doc) => doc['Date_Received'] != null)
        .toList()
      ..sort((a, b) {
        final aDate = _parseDate(a['Date_Received']) ?? DateTime(2000);
        final bDate = _parseDate(b['Date_Received']) ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    final recentFive = recentActivity.take(5).toList();
    
    // Find top category by stock quantity
    final topCategory = categoryStock.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'categories': categories,
      'suppliers': suppliers,
      'categoryStock': categoryStock,
      'lowInventory': lowInventory,
      'recentFive': recentFive,
      'topCategory': topCategory,
      'lowInventoryCount': lowInventory.length,
      'recentAdditions': recentFive.length,
      'activeSuppliers': suppliers.length,
    };
  }
  
  static List<double> calculateTrendPoints(
    List<QueryDocumentSnapshot> products,
    String timeFilter,
    String field,
  ) {
    final now = DateTime.now();
    
    if (timeFilter == 'Weekly') {
      return _calculateWeeklyTrend(products, now, field);
    } else if (timeFilter == 'Monthly') {
      return _calculateMonthlyTrend(products, now, field);
    } else if (timeFilter == 'Yearly') {
      return _calculateYearlyTrend(products, now, field);
    }
    
    return [];
  }
  
  static List<double> _calculateWeeklyTrend(
    List<QueryDocumentSnapshot> products,
    DateTime now,
    String field,
  ) {
    List<int> weeklyCounts = List.filled(8, 0);
    
    for (var doc in products) {
      final dateReceived = _parseDate(doc['Date_Received']);
      if (dateReceived != null) {
        final weekDiff = now.difference(dateReceived).inDays ~/ 7;
        if (weekDiff >= 0 && weekDiff < 8) {
          weeklyCounts[7 - weekDiff]++;
        }
      }
    }
    
    return weeklyCounts.map((e) => e.toDouble()).toList();
  }
  
  static List<double> _calculateMonthlyTrend(
    List<QueryDocumentSnapshot> products,
    DateTime now,
    String field,
  ) {
    List<int> monthlyCounts = List.filled(12, 0);
    
    for (var doc in products) {
      final dateReceived = _parseDate(doc['Date_Received']);
      if (dateReceived != null) {
        final monthDiff = (now.year - dateReceived.year) * 12 + (now.month - dateReceived.month);
        if (monthDiff >= 0 && monthDiff < 12) {
          monthlyCounts[11 - monthDiff]++;
        }
      }
    }
    
    return monthlyCounts.map((e) => e.toDouble()).toList();
  }
  
  static List<double> _calculateYearlyTrend(
    List<QueryDocumentSnapshot> products,
    DateTime now,
    String field,
  ) {
    List<int> yearlyCounts = List.filled(5, 0);
    
    for (var doc in products) {
      final dateReceived = _parseDate(doc['Date_Received']);
      if (dateReceived != null) {
        final yearDiff = now.year - dateReceived.year;
        if (yearDiff >= 0 && yearDiff < 5) {
          yearlyCounts[4 - yearDiff]++;
        }
      }
    }
    
    return yearlyCounts.map((e) => e.toDouble()).toList();
  }
  
  static int _parseStockQuantity(dynamic stockQuantity) {
    if (stockQuantity is int) {
      return stockQuantity;
    }
    return int.tryParse(stockQuantity?.toString() ?? '') ?? 0;
  }
  
  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    
    if (dateStr is String) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      }
    }
    return null;
  }
}
