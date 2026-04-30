import 'package:bloc_test/bloc_test.dart';
import 'package:ecommerce_app/api/api_service.dart';
import 'package:ecommerce_app/cubits/product/product_cubit.dart';
import 'package:ecommerce_app/cubits/product/product_state.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_data.dart';
import 'product_cubit_test.mocks.dart';

@GenerateMocks(<Type>[ApiService])
void main() {
  late MockApiService api;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    api = MockApiService();
  });

  group('ProductCubit', () {
    blocTest<ProductCubit, ProductState>(
      'emits [Loading, Loaded] on successful load',
      build: () {
        when(api.getProducts()).thenAnswer((_) async => fakeProducts());
        return ProductCubit(apiService: api, prefs: prefs);
      },
      act: (ProductCubit c) => c.loadProducts(),
      expect: () => <Matcher>[
        isA<ProductLoading>(),
        isA<ProductLoaded>().having((ProductLoaded s) => s.allProducts.length, 'allProducts.length', 3),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'emits [Loading, Error] on failure when no cache exists',
      build: () {
        when(api.getProducts()).thenThrow(const ApiException('boom'));
        return ProductCubit(apiService: api, prefs: prefs);
      },
      act: (ProductCubit c) => c.loadProducts(),
      expect: () => <Matcher>[isA<ProductLoading>(), isA<ProductError>()],
    );

    blocTest<ProductCubit, ProductState>(
      'falls back to cached products when API fails after a previous success',
      build: () {
        when(api.getProducts()).thenAnswer((_) async => fakeProducts());
        return ProductCubit(apiService: api, prefs: prefs);
      },
      act: (ProductCubit c) async {
        await c.loadProducts();
        when(api.getProducts()).thenThrow(const ApiException('offline'));
        await c.loadProducts();
      },
      skip: 2,
      expect: () => <Matcher>[
        isA<ProductLoading>(),
        isA<ProductLoaded>().having((ProductLoaded s) => s.staleFromCache, 'staleFromCache', true),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'searchProducts narrows visibleProducts to matching titles',
      build: () {
        when(api.getProducts()).thenAnswer((_) async => fakeProducts());
        return ProductCubit(apiService: api, prefs: prefs);
      },
      act: (ProductCubit c) async {
        await c.loadProducts();
        c.searchProducts('necklace');
      },
      skip: 2,
      expect: () => <Matcher>[
        isA<ProductLoaded>()
            .having((ProductLoaded s) => s.visibleProducts.map((Product p) => p.id).toList(), 'visible ids', <int>[2]),
      ],
    );
  });
}
