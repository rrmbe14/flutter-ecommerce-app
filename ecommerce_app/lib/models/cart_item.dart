import 'package:ecommerce_app/models/product.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      quantity: quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: (json['productId'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );
  }

  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      price: price,
      image: image,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productId': productId,
    'title': title,
    'price': price,
    'image': image,
    'quantity': quantity,
  };

  @override
  List<Object?> get props => <Object?>[productId, title, price, image, quantity];
}
