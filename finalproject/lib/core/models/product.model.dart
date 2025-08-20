class ProductModel {
  final String productId;
  final String productName;
  final String category;
  final String supplierName;
  final String warehouseLocation;
  final String status;
  final String supplierId;
  final DateTime dateReceived;
  final DateTime lastOrderDate;
  final DateTime expirationDate;
  final int stockQuantity;
  final int reorderLevel;
  final int reorderQuantity;
  final double unitPrice;
  final int salesVolume;
  final int inventoryTurnoverRate;
  final String percentage;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.category,
    required this.supplierName,
    required this.warehouseLocation,
    required this.status,
    required this.supplierId,
    required this.dateReceived,
    required this.lastOrderDate,
    required this.expirationDate,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.reorderQuantity,
    required this.unitPrice,
    required this.salesVolume,
    required this.inventoryTurnoverRate,
    required this.percentage,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['Product_ID'] ?? '',
      productName: map['Product_Name'] ?? '',
      category: map['Catagory'] ?? '',
      supplierName: map['Supplier_Name'] ?? '',
      warehouseLocation: map['Warehouse_Location'] ?? '',
      status: map['Status'] ?? '',
      supplierId: map['Supplier_ID'] ?? '',
      dateReceived: _parseDate(map['Date_Received']),
      lastOrderDate: _parseDate(map['Last_Order_Date']),
      expirationDate: _parseDate(map['Expiration_Date']),
      stockQuantity: int.tryParse(map['Stock_Quantity']?.toString() ?? '') ?? 0,
      reorderLevel: int.tryParse(map['Reorder_Level']?.toString() ?? '') ?? 0,
      reorderQuantity:
          int.tryParse(map['Reorder_Quantity']?.toString() ?? '') ?? 0,
      unitPrice: _parsePrice(map['Unit_Price']),
      salesVolume: int.tryParse(map['Sales_Volume']?.toString() ?? '') ?? 0,
      inventoryTurnoverRate:
          int.tryParse(map['Inventory_Turnover_Rate']?.toString() ?? '') ?? 0,
      percentage: map['percentage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Product_ID': productId,
      'Product_Name': productName,
      'Catagory': category,
      'Supplier_Name': supplierName,
      'Warehouse_Location': warehouseLocation,
      'Status': status,
      'Supplier_ID': supplierId,
      'Date_Received': dateReceived.toIso8601String(),
      'Last_Order_Date': lastOrderDate.toIso8601String(),
      'Expiration_Date': expirationDate.toIso8601String(),
      'Stock_Quantity': stockQuantity,
      'Reorder_Level': reorderLevel,
      'Reorder_Quantity': reorderQuantity,
      'Unit_Price': unitPrice,
      'Sales_Volume': salesVolume,
      'Inventory_Turnover_Rate': inventoryTurnoverRate,
      'percentage': percentage,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(1970, 1, 1);
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Try MM/DD/YYYY
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
      return DateTime(1970, 1, 1);
    }
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    final str = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(str) ?? 0.0;
  }
}
