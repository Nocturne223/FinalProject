import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductExporter {
  const ProductExporter._();

  static Future<void> exportAllProducts(BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      final docs = snapshot.docs;

      if (docs.isEmpty) {
        _showSnack(context, 'No products to export');
        return;
      }

      // Collect all keys dynamically from all documents
      final Set<String> dynamicKeys = {};
      for (final doc in docs) {
        final data = doc.data();
        dynamicKeys.addAll(data.keys);
      }

      // Ensure Product_ID is present and first; stable deterministic header order
      final List<String> headers = [
        'Product_ID',
        ...dynamicKeys.where((k) => k != 'Product_ID').toList(),
      ];

      // Build CSV rows; JSON-encode nested values
      final List<List<String>> rows = <List<String>>[];
      rows.add(headers);
      for (final doc in docs) {
        final data = doc.data();
        final List<String> row = <String>[];
        row.add((data['Product_ID'] ?? doc.id).toString());
        for (final key in headers.skip(1)) {
          final value = data[key];
          if (value == null) {
            row.add('');
          } else if (value is Map || value is List) {
            row.add(jsonEncode(value));
          } else {
            row.add(value.toString());
          }
        }
        rows.add(row);
      }

      final String csvString = const ListToCsvConverter().convert(rows);
      final Uint8List csvBytes = Uint8List.fromList(utf8.encode(csvString));

      if (kIsWeb) {
        final params = ShareParams(
          files: [XFile.fromData(csvBytes, mimeType: 'text/csv')],
          fileNameOverrides: ['products_export.csv'],
          text: 'Exported products data',
        );
        await SharePlus.instance.share(params);
      } else {
        final dir = await getTemporaryDirectory();
        final String path = '${dir.path}/products_export.csv';
        final file = File(path);
        await file.writeAsBytes(csvBytes, flush: true);

        final box = context.findRenderObject() as RenderBox?;
        final params = ShareParams(
          files: [XFile(path)],
          text: 'Exported products data',
          sharePositionOrigin: box != null
              ? (box.localToGlobal(Offset.zero) & box.size)
              : null,
        );
        await SharePlus.instance.share(params);
      }
    } catch (e) {
      _showSnack(context, 'Export failed: $e');
    }
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
