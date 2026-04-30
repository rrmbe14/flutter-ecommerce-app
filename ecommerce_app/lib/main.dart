import 'package:ecommerce_app/api/api_service.dart';
import 'package:ecommerce_app/cubits/cart/cart_cubit.dart';
import 'package:ecommerce_app/cubits/product/product_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_state.dart';
import 'package:ecommerce_app/screens/main_shell.dart';
import 'package:ecommerce_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ApiService apiService = ApiService();
  runApp(EcommerceApp(prefs: prefs, apiService: apiService));
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({required this.prefs, required this.apiService, super.key});

  final SharedPreferences prefs;
  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ThemeCubit>(create: (BuildContext _) => ThemeCubit(prefs: prefs)),
        BlocProvider<ProductCubit>(create: (BuildContext _) => ProductCubit(apiService: apiService, prefs: prefs)),
        BlocProvider<CartCubit>(create: (BuildContext _) => CartCubit(prefs: prefs)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (ThemeState a, ThemeState b) => a.mode != b.mode,
        builder: (BuildContext context, ThemeState themeState) {
          return MaterialApp(
            title: 'UKAYX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeState.mode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
