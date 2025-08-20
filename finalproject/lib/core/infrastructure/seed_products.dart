import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.model.dart';

Future<void> seedProductsFromCsv() async {
  final csvString = await rootBundle.loadString(
    'assets/Grocery_Inventory_new_v1.csv',
  );
  final rows = const CsvToListConverter(eol: '\n').convert(csvString);

  final header = rows.first.cast<String>();
  final products = rows.skip(1);

  for (var row in products) {
    final data = <String, dynamic>{};
    for (int i = 0; i < header.length; i++) {
      data[header[i]] = row[i];
    }
    final product = ProductModel.fromMap(data);
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.productId)
        .set(product.toMap());
  }
}
