import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Product product = widget.product;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: CachedNetworkImage(imageUrl: product.image, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(product.category.toUpperCase(), style: theme.textTheme.labelMedium),
          const SizedBox(height: 12),
          Text(product.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text('\$${product.price.toStringAsFixed(2)}', style: theme.textTheme.displayMedium),
              const SizedBox(width: 16),
              if (product.rating.count > 0)
                Text(
                  '★ ${product.rating.rate.toStringAsFixed(1)}  (${product.rating.count})',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
          const Divider(),
          Text('DESCRIPTION', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Text(product.description, style: theme.textTheme.bodyLarge),
          const Divider(),
          Text('QUANTITY', style: theme.textTheme.labelLarge),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _QtyButton(
                icon: Icons.remove,
                onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              SizedBox(
                width: 56,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: () => setState(() => _quantity++)),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => _addToCart(context, product),
            child: const Text('ADD TO BAG'),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    context.read<CartCubit>().addItem(product, quantity: _quantity);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity × ${product.title} to bag'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: onTap == null ? 0.15 : 0.4),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: onTap == null ? 0.25 : 1),
        ),
      ),
    );
  }
}
