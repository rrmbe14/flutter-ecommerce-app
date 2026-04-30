import 'dart:async';

import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/cart/cart_state.dart';
import 'package:ecommerce_app/cubits/product/product_cubit.dart';
import 'package:ecommerce_app/cubits/product/product_state.dart';
import 'package:ecommerce_app/cubits/theme/theme_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_state.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/widgets/category_tabs.dart';
import 'package:ecommerce_app/widgets/empty_state.dart';
import 'package:ecommerce_app/widgets/error_view.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UKAYX'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.tune, size: 20),
            onPressed: () => _openSortSheet(context),
            tooltip: 'Sort',
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (BuildContext context, ThemeState state) => IconButton(
              icon: Icon(
                state.viewMode == ViewMode.grid ? Icons.view_list_outlined : Icons.grid_view_outlined,
                size: 20,
              ),
              onPressed: () => context.read<ThemeCubit>().setViewMode(
                state.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
              ),
              tooltip: 'Toggle view',
            ),
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (BuildContext context, CartState state) => IconButton(
              icon: Badge(
                isLabelVisible: state.itemCount > 0,
                label: Text('${state.itemCount}'),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (BuildContext _) => const CartScreen()),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, size: 18),
                prefixIconConstraints: BoxConstraints(minWidth: 32),
              ),
              onChanged: (String value) => context.read<ProductCubit>().searchProducts(value),
            ),
          ),
          BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (ProductState a, ProductState b) =>
                b is ProductLoaded && (a is! ProductLoaded || a.categories != b.categories || a.category != b.category),
            builder: (BuildContext context, ProductState state) {
              if (state is! ProductLoaded || state.categories.isEmpty) {
                return const SizedBox(height: 40);
              }
              return CategoryTabs(
                categories: state.categories,
                selected: state.category,
                onSelected: (String c) => context.read<ProductCubit>().filterByCategory(c),
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(child: _ProductBody()),
        ],
      ),
    );
  }

  void _openSortSheet(BuildContext context) {
    final ProductState state = context.read<ProductCubit>().state;
    final SortOption current = state is ProductLoaded ? state.sortOption : SortOption.none;
    unawaited(showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('SORT BY', style: Theme.of(context).textTheme.labelLarge),
              ),
              for (final SortOption option in SortOption.values)
                ListTile(
                  title: Text(option.label),
                  trailing: option == current ? const Icon(Icons.check, size: 18) : null,
                  onTap: () {
                    context.read<ProductCubit>().sortProducts(option);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ));
  }

}

class _ProductBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (BuildContext context, ProductState state) {
        if (state is ProductInitial || state is ProductLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 1));
        }
        if (state is ProductError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<ProductCubit>().loadProducts(),
          );
        }
        if (state is ProductLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<ProductCubit>().refreshProducts(),
            child: _LoadedView(state: state),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final ProductLoaded state;

  @override
  Widget build(BuildContext context) {
    final List<Product> products = state.visibleProducts;

    if (products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          if (state.staleFromCache) const _OfflineBanner(),
          const SizedBox(height: 80),
          const EmptyState(
            icon: Icons.search_off_outlined,
            title: 'No products found',
            message: 'Try a different search or category.',
          ),
        ],
      );
    }

    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (ThemeState a, ThemeState b) => a.viewMode != b.viewMode,
      builder: (BuildContext context, ThemeState themeState) {
        if (themeState.viewMode == ViewMode.grid) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              if (state.staleFromCache) const SliverToBoxAdapter(child: _OfflineBanner()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 32,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: products.length,
                  itemBuilder: (BuildContext _, int index) => ProductCard(
                    product: products[index],
                    onTap: () => _openDetail(context, products[index]),
                  ),
                ),
              ),
            ],
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          itemCount: products.length + (state.staleFromCache ? 1 : 0),
          separatorBuilder: (BuildContext _, int _) => const Divider(),
          itemBuilder: (BuildContext _, int index) {
            if (state.staleFromCache && index == 0) {
              return const _OfflineBanner();
            }
            final int productIndex = state.staleFromCache ? index - 1 : index;
            final Product product = products[productIndex];
            return ProductListTile(product: product, onTap: () => _openDetail(context, product));
          },
        );
      },
    );
  }

  void _openDetail(BuildContext context, Product product) {
    unawaited(Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => ProductDetailScreen(product: product)),
    ));
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text('OFFLINE — SHOWING CACHED PRODUCTS', style: theme.textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}
