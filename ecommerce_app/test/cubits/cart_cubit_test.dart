import 'package:bloc_test/bloc_test.dart';
import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/cart/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_data.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  group('CartCubit', () {
    blocTest<CartCubit, CartState>(
      'addItem adds a new line, then increments quantity on second add',
      build: () => CartCubit(prefs: prefs),
      act: (CartCubit c) {
        c.addItem(fakeProduct(id: 1, price: 10));
        c.addItem(fakeProduct(id: 1, price: 10), quantity: 2);
      },
      expect: () => <Matcher>[
        isA<CartState>().having((CartState s) => s.itemCount, 'count', 1).having((CartState s) => s.totalPrice, 'total', 10),
        isA<CartState>().having((CartState s) => s.itemCount, 'count', 3).having((CartState s) => s.totalPrice, 'total', 30),
      ],
    );

    blocTest<CartCubit, CartState>(
      'updateQuantity to zero removes the item',
      build: () => CartCubit(prefs: prefs),
      act: (CartCubit c) {
        c.addItem(fakeProduct(id: 1, price: 10));
        c.updateQuantity(1, 0);
      },
      expect: () => <Matcher>[
        isA<CartState>().having((CartState s) => s.itemCount, 'count', 1),
        isA<CartState>().having((CartState s) => s.isEmpty, 'isEmpty', true),
      ],
    );

    blocTest<CartCubit, CartState>(
      'clearCart empties the bag',
      build: () => CartCubit(prefs: prefs),
      act: (CartCubit c) {
        c.addItem(fakeProduct(id: 1));
        c.addItem(fakeProduct(id: 2));
        c.clearCart();
      },
      skip: 2,
      expect: () => <Matcher>[isA<CartState>().having((CartState s) => s.isEmpty, 'isEmpty', true)],
    );

    test('cart hydrates from SharedPreferences on construction', () async {
      final CartCubit first = CartCubit(prefs: prefs);
      first.addItem(fakeProduct(id: 1, price: 10), quantity: 2);
      // Allow the async _saveCart to flush.
      await Future<void>.delayed(Duration.zero);

      final SharedPreferences freshPrefs = await SharedPreferences.getInstance();
      final CartCubit hydrated = CartCubit(prefs: freshPrefs);
      // Allow the constructor's _loadCart future to resolve.
      await Future<void>.delayed(Duration.zero);

      expect(hydrated.state.itemCount, 2);
      expect(hydrated.state.totalPrice, 20);
    });
  });
}
