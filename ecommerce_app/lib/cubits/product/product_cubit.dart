import 'dart:convert';

import 'package:ecommerce_app/api/api_service.dart';
import 'package:ecommerce_app/cubits/product/product_state.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit({required ApiService apiService, required SharedPreferences prefs})
    : _api = apiService,
      _prefs = prefs,
      super(const ProductInitial());

  static const String _cacheKey = 'products_cache_v1';

  final ApiService _api;
  final SharedPreferences _prefs;

  List<Product> _allProducts = const <Product>[];
  String _query = '';
  String _category = allCategories;
  SortOption _sortOption = SortOption.none;

  Future<void> loadProducts() async {
    emit(const ProductLoading());
    await _fetchAndEmit();
  }

  Future<void> refreshProducts() => _fetchAndEmit();

  void searchProducts(String query) {
    _query = query;
    _emitLoaded();
  }

  void filterByCategory(String category) {
    _category = category;
    _emitLoaded();
  }

  void sortProducts(SortOption option) {
    _sortOption = option;
    _emitLoaded();
  }

  Future<void> _fetchAndEmit() async {
    try {
      final List<Product> fetched = await _api.getProducts();
      _allProducts = fetched;
      await _writeCache(fetched);
      _emitLoaded(staleFromCache: false);
    } catch (e) {
      final List<Product> cache = await _readCache();
      if (cache.isNotEmpty) {
        _allProducts = cache;
        _emitLoaded(staleFromCache: true);
      } else {
        emit(ProductError('Failed to load products: $e'));
      }
    }
  }

  void _emitLoaded({bool staleFromCache = false}) {
    final List<Product> visible = _filterAndSort(_allProducts);
    final List<String> categories = <String>[
      allCategories,
      ..._allProducts.map((Product p) => p.category).toSet(),
    ];
    emit(
      ProductLoaded(
        allProducts: _allProducts,
        visibleProducts: visible,
        categories: categories,
        query: _query,
        category: _category,
        sortOption: _sortOption,
        staleFromCache: staleFromCache,
      ),
    );
  }

  List<Product> _filterAndSort(List<Product> source) {
    final String q = _query.trim().toLowerCase();
    Iterable<Product> result = source;
    if (_category != allCategories) {
      result = result.where((Product p) => p.category == _category);
    }
    if (q.isNotEmpty) {
      result = result.where(
        (Product p) => p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q),
      );
    }
    final List<Product> list = result.toList();
    switch (_sortOption) {
      case SortOption.none:
        break;
      case SortOption.priceAsc:
        list.sort((Product a, Product b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        list.sort((Product a, Product b) => b.price.compareTo(a.price));
      case SortOption.ratingDesc:
        list.sort((Product a, Product b) => b.rating.rate.compareTo(a.rating.rate));
      case SortOption.titleAsc:
        list.sort((Product a, Product b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  }

  Future<void> _writeCache(List<Product> products) async {
    final List<Map<String, dynamic>> raw = products.map((Product p) => p.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(raw));
  }

  Future<List<Product>> _readCache() async {
    final String? raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return const <Product>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const <Product>[];
    }
  }
}
