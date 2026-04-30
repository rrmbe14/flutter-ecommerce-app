import 'package:ecommerce_app/models/product.dart';
import 'package:equatable/equatable.dart';

enum SortOption {
  none('Default'),
  priceAsc('Price: Low to High'),
  priceDesc('Price: High to Low'),
  ratingDesc('Top rated'),
  titleAsc('Name: A → Z');

  const SortOption(this.label);
  final String label;
}

const String allCategories = 'All';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  const ProductLoaded({
    required this.allProducts,
    required this.visibleProducts,
    required this.categories,
    required this.query,
    required this.category,
    required this.sortOption,
    this.staleFromCache = false,
  });

  final List<Product> allProducts;
  final List<Product> visibleProducts;
  final List<String> categories;
  final String query;
  final String category;
  final SortOption sortOption;
  final bool staleFromCache;

  ProductLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? visibleProducts,
    List<String>? categories,
    String? query,
    String? category,
    SortOption? sortOption,
    bool? staleFromCache,
  }) {
    return ProductLoaded(
      allProducts: allProducts ?? this.allProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      category: category ?? this.category,
      sortOption: sortOption ?? this.sortOption,
      staleFromCache: staleFromCache ?? this.staleFromCache,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    allProducts,
    visibleProducts,
    categories,
    query,
    category,
    sortOption,
    staleFromCache,
  ];
}

class ProductError extends ProductState {
  const ProductError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
