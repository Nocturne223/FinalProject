import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transId;
  final String productId;
  final int qty;
  final String transType;
  final DateTime date;
  final String userId;

  TransactionModel({
    required this.transId,
    required this.productId,
    required this.qty,
    required this.transType,
    required this.date,
    required this.userId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transId: map['trans_id'] ?? '',
      productId: map['product_id'] ?? '',
      qty: map['qty'] ?? 0,
      transType: map['trans_type'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trans_id': transId,
      'product_id': productId,
      'qty': qty,
      'trans_type': transType,
      'date': date,
      'user_id': userId,
    };
  }
}
