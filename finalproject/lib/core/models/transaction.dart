import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String productId;
  final int quantity;
  final String type;
  final DateTime timestamp;
  final String userId;
  final String? notes;

  Transaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.timestamp,
    required this.userId,
    this.notes,
  });

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 0,
      type: map['type'] ?? '',
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now(),
      userId: map['userId'] ?? '',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'type': type,
      'timestamp': timestamp,
      'userId': userId,
      'notes': notes,
    };
  }
}
