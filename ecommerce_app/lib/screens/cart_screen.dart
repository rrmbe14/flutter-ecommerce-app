import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/cart/cart_state.dart';
import 'package:ecommerce_app/models/cart_item.dart';
import 'package:ecommerce_app/widgets/confirm_dialog.dart';
import 'package:ecommerce_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      appBar: AppBar(
        leading: canPop ? IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ) : null,
        automaticallyImplyLeading: false,
        title: const Text('BAG'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (BuildContext context, CartState state) {
          if (state.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your bag is empty',
              message: 'Add something special to get started.',
            );
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.items.length,
                  separatorBuilder: (BuildContext _, int _) => const Divider(),
                  itemBuilder: (BuildContext _, int index) => _CartItemRow(item: state.items[index]),
                ),
              ),
              const Divider(height: 1),
              _CartSummary(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 80,
            height: 80,
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CachedNetworkImage(imageUrl: item.image, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                    ),
                    InkWell(
                      onTap: () => context.read<CartCubit>().removeItem(item.productId),
                      child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('\$${item.price.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _QtyStep(
                      icon: Icons.remove,
                      onTap: () => context.read<CartCubit>().updateQuantity(item.productId, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text('${item.quantity}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                    ),
                    _QtyStep(
                      icon: Icons.add,
                      onTap: () => context.read<CartCubit>().updateQuantity(item.productId, item.quantity + 1),
                    ),
                    const Spacer(),
                    Text('\$${item.lineTotal.toStringAsFixed(2)}', style: theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStep extends StatelessWidget {
  const _QtyStep({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('SUBTOTAL (${state.itemCount})', style: theme.textTheme.labelLarge),
                Text('\$${state.totalPrice.toStringAsFixed(2)}', style: theme.textTheme.displayMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text('Shipping & taxes calculated at checkout.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => _showCheckoutPlaceholder(context), child: const Text('CHECKOUT')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _confirmClear(context),
              child: const Text('CLEAR BAG'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout flow is out of scope for this capstone.')),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Clear bag?',
      message: 'All items will be removed.',
      confirmLabel: 'CLEAR',
    );
    if (confirmed && context.mounted) {
      context.read<CartCubit>().clearCart();
    }
  }
}
