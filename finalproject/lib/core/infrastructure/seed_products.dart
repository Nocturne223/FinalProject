import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.model.dart';

Future<void> seedProductsFromCsv() async {
  print('Starting CSV seed...');
  final csvString = await rootBundle.loadString(
    'assets/Grocery_Inventory_new_v2.csv',
  );
  print('CSV file loaded, length: \\${csvString.length}');
  final rows = const CsvToListConverter(eol: '\n').convert(csvString);
  print('CSV parsed, total rows: \\${rows.length}');

  final header = rows.first.cast<String>();
  print('Header: \\${header}');
  final products = rows.skip(1);
  int count = 0;
  for (var row in products) {
    final data = <String, dynamic>{};
    for (int i = 0; i < header.length; i++) {
      data[header[i]] = row[i];
    }
    print(
      'Seeding product: \\${data['Product_Name']} (ID: \\${data['Product_ID']})',
    );
    try {
      final product = ProductModel.fromMap(data);
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .set(product.toMap());
      count++;
    } catch (e) {
      print('Error seeding product: \\${data['Product_Name']} - \\${e}');
    }
  }
  print('Seeding complete. Total products seeded: \\${count}');
}
