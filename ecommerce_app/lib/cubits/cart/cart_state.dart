import 'package:ecommerce_app/models/cart_item.dart';
import 'package:equatable/equatable.dart';

class CartState extends Equatable {
  const CartState({this.items = const <CartItem>[]});

  final List<CartItem> items;

  int get itemCount => items.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);

  double get totalPrice => items.fold<double>(0, (double sum, CartItem item) => sum + item.lineTotal);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);

  @override
  List<Object?> get props => <Object?>[items];
}
