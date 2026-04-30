import 'dart:convert';

import 'package:ecommerce_app/models/product.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}): $message';
}

class ApiService {
  ApiService({http.Client? client, this.baseUrl = 'https://fakestoreapi.com'}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;
  final String baseUrl;

  Future<List<Product>> getProducts() async {
    final Uri uri = Uri.parse('$baseUrl/products');
    final http.Response response = await _send(() => _client.get(uri));
    final List<dynamic> raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Product> getProduct(int id) async {
    final Uri uri = Uri.parse('$baseUrl/products/$id');
    final http.Response response = await _send(() => _client.get(uri));
    final Map<String, dynamic> raw = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(raw);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final http.Response response = await request().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Request failed', statusCode: response.statusCode);
      }
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
