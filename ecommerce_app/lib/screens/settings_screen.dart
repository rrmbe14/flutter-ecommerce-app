import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_state.dart';
import 'package:ecommerce_app/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: <Widget>[
              const SizedBox(height: 8),
              Text('APPEARANCE', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                subtitle: Text(_themeSubtitle(state.mode)),
                value: state.isDark,
                onChanged: (bool _) => context.read<ThemeCubit>().toggleTheme(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Follow system'),
                trailing: state.mode == ThemeMode.system ? const Icon(Icons.check, size: 18) : null,
                onTap: () => context.read<ThemeCubit>().setSystemMode(),
              ),
              const Divider(),
              Text('LIST STYLE', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              RadioGroup<ViewMode>(
                groupValue: state.viewMode,
                onChanged: (ViewMode? v) {
                  if (v != null) {
                    context.read<ThemeCubit>().setViewMode(v);
                  }
                },
                child: const Column(
                  children: <Widget>[
                    RadioListTile<ViewMode>(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Grid'),
                      value: ViewMode.grid,
                    ),
                    RadioListTile<ViewMode>(
                      contentPadding: EdgeInsets.zero,
                      title: Text('List'),
                      value: ViewMode.list,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Text('DATA', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Clear shopping bag'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => _confirmClearCart(context),
              ),
              const Divider(),
              const SizedBox(height: 24),
              Center(
                child: Text('UKAYX  ·  v$_appVersion', style: theme.textTheme.labelMedium),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _themeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Following system';
    }
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Clear shopping bag?',
      message: 'All items will be removed.',
      confirmLabel: 'CLEAR',
    );
    if (confirmed && context.mounted) {
      context.read<CartCubit>().clearCart();
    }
  }
}
