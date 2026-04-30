import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating rating;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: json['rating'] is Map<String, dynamic>
          ? ProductRating.fromJson(json['rating'] as Map<String, dynamic>)
          : ProductRating.empty(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
    'rating': rating.toJson(),
  };

  @override
  List<Object?> get props => <Object?>[id, title, price, description, category, image, rating];
}

class ProductRating extends Equatable {
  const ProductRating({required this.rate, required this.count});

  factory ProductRating.empty() => const ProductRating(rate: 0, count: 0);

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      rate: (json['rate'] as num? ?? 0).toDouble(),
      count: (json['count'] as num? ?? 0).toInt(),
    );
  }

  final double rate;
  final int count;

  Map<String, dynamic> toJson() => <String, dynamic>{'rate': rate, 'count': count};

  @override
  List<Object?> get props => <Object?>[rate, count];
}
