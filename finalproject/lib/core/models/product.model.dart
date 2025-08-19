class ProductModel {
  final String productId;
  final String name;
  final String categoryId;
  final int stockQty;
  final int reorderLevel;

  ProductModel({
    required this.productId,
    required this.name,
    required this.categoryId,
    required this.stockQty,
    required this.reorderLevel,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'] ?? '',
      name: map['name'] ?? '',
      categoryId: map['category_id'] ?? '',
      stockQty: map['stock_qty'] ?? 0,
      reorderLevel: map['reorder_level'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'category_id': categoryId,
      'stock_qty': stockQty,
      'reorder_level': reorderLevel,
    };
  }
}
