import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

Future<void> seedCategoriesFromCsv() async {
  final csvString = await rootBundle.loadString('assets/categories.csv');
  final rows = const CsvToListConverter(eol: '\n').convert(csvString);
  final header = rows.first.cast<String>();
  final categories = rows.skip(1);
  for (var row in categories) {
    if (row.length < 4) {
      print('Skipped row: $row');
      continue;
    }
    final id = row[0]?.toString() ?? '';
    if (id.isEmpty) {
      print('Skipped row: $row');
      continue;
    }
    print(
      'Seeding category: $id, name: ${row[1]}, description: ${row[2]}, createdAt: ${row[3]}',
    );
    final category = Category.fromMap({
      'name': row[1],
      'description': row[2],
      'createdAt': row[3],
    }, id);
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }
}
