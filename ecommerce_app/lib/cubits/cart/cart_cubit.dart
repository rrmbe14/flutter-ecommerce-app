import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_app/cubits/cart/cart_state.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required SharedPreferences prefs}) : _prefs = prefs, super(const CartState()) {
    unawaited(_loadCart());
  }

  static const String _cartKey = 'cart_items_v1';

  final SharedPreferences _prefs;

  void addItem(Product product, {int quantity = 1}) {
    final List<CartItem> updated = List<CartItem>.from(state.items);
    final int idx = updated.indexWhere((CartItem item) => item.productId == product.id);
    if (idx == -1) {
      updated.add(CartItem.fromProduct(product, quantity: quantity));
    } else {
      final CartItem existing = updated[idx];
      updated[idx] = existing.copyWith(quantity: existing.quantity + quantity);
    }
    _emitAndSave(updated);
  }

  void removeItem(int productId) {
    final List<CartItem> updated = state.items.where((CartItem item) => item.productId != productId).toList();
    _emitAndSave(updated);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final List<CartItem> updated = state.items
        .map((CartItem item) => item.productId == productId ? item.copyWith(quantity: quantity) : item)
        .toList();
    _emitAndSave(updated);
  }

  void clearCart() {
    _emitAndSave(const <CartItem>[]);
  }

  void _emitAndSave(List<CartItem> items) {
    emit(state.copyWith(items: items));
    unawaited(_saveCart());
  }

  Future<void> _loadCart() async {
    final String? raw = _prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<CartItem> items = decoded
          .map((dynamic item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      emit(state.copyWith(items: items));
    } catch (_) {
      // Corrupted cart payload — ignore and start fresh.
    }
  }

  Future<void> _saveCart() async {
    final String raw = jsonEncode(state.items.map((CartItem item) => item.toJson()).toList());
    await _prefs.setString(_cartKey, raw);
  }
}
