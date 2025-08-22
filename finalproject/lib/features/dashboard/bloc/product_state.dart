import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoadInProgress extends ProductState {}

class ProductLoadSuccess extends ProductState {
  final List<QueryDocumentSnapshot> products;
  const ProductLoadSuccess(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductLoadFailure extends ProductState {
  final String error;
  const ProductLoadFailure(this.error);
  @override
  List<Object?> get props => [error];
}
