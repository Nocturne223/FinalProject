import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

Future<void> seedUsersFromCsv() async {
  final csvString = await rootBundle.loadString('assets/users.csv');
  final rows = const CsvToListConverter(eol: '\n').convert(csvString);
  final header = rows.first.cast<String>();
  final users = rows.skip(1);
  for (var row in users) {
    final data = <String, dynamic>{};
    for (int i = 0; i < header.length; i++) {
      data[header[i]] = row[i];
    }
    final user = AppUser.fromMap(data, data['User_ID']);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }
}
