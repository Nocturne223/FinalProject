import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  StreamSubscription? _productSubscription;

  ProductBloc() : super(ProductInitial()) {
    on<ProductStreamStarted>(_onStreamStarted);
  }

  void _onStreamStarted(
    ProductStreamStarted event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductLoadInProgress());
    _productSubscription?.cancel();
    _productSubscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen(
          (snapshot) {
            emit(ProductLoadSuccess(snapshot.docs));
          },
          onError: (error) {
            emit(ProductLoadFailure(error.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
