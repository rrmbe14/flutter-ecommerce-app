import 'dart:async';

import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/cart/cart_state.dart';
import 'package:ecommerce_app/cubits/product/product_cubit.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      unawaited(context.read<ProductCubit>().loadProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        buildWhen: (CartState a, CartState b) => a.itemCount != b.itemCount,
        builder: (BuildContext context, CartState cartState) => BottomNavigationBar(
          currentIndex: _index,
          onTap: (int i) => setState(() => _index = i),
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined, size: 22),
              activeIcon: Icon(Icons.storefront, size: 22),
              label: 'SHOP',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartState.itemCount > 0,
                label: Text('${cartState.itemCount}'),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              activeIcon: Badge(
                isLabelVisible: cartState.itemCount > 0,
                label: Text('${cartState.itemCount}'),
                child: const Icon(Icons.shopping_bag, size: 22),
              ),
              label: 'BAG',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined, size: 22),
              activeIcon: Icon(Icons.tune, size: 22),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
