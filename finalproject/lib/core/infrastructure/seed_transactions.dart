import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model;

Future<void> seedTransactionsFromCsv() async {
  final csvString = await rootBundle.loadString('assets/transactions.csv');
  final rows = const CsvToListConverter(eol: '\n').convert(csvString);
  final header = rows.first.cast<String>();
  final transactions = rows.skip(1);
  for (var row in transactions) {
    final data = <String, dynamic>{};
    for (int i = 0; i < header.length; i++) {
      data[header[i]] = row[i];
    }
    final transaction = model.Transaction.fromMap(data, data['Transaction_ID']);
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }
}
