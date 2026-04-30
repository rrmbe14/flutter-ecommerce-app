import 'dart:async';

import 'package:ecommerce_app/cubits/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required SharedPreferences prefs}) : _prefs = prefs, super(const ThemeState()) {
    _hydrate();
  }

  static const String _themeKey = 'theme_mode_v1';
  static const String _viewModeKey = 'view_mode_v1';

  final SharedPreferences _prefs;

  void toggleTheme() {
    final ThemeMode next = state.isDark ? ThemeMode.light : ThemeMode.dark;
    _setMode(next);
  }

  void setLightMode() => _setMode(ThemeMode.light);
  void setDarkMode() => _setMode(ThemeMode.dark);
  void setSystemMode() => _setMode(ThemeMode.system);

  void setViewMode(ViewMode mode) {
    emit(state.copyWith(viewMode: mode));
    unawaited(_prefs.setString(_viewModeKey, mode.name));
  }

  void _setMode(ThemeMode mode) {
    emit(state.copyWith(mode: mode));
    unawaited(_prefs.setString(_themeKey, mode.name));
  }

  void _hydrate() {
    final String? themeRaw = _prefs.getString(_themeKey);
    final String? viewRaw = _prefs.getString(_viewModeKey);
    final ThemeMode mode = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == themeRaw,
      orElse: () => ThemeMode.system,
    );
    final ViewMode viewMode = ViewMode.values.firstWhere(
      (ViewMode v) => v.name == viewRaw,
      orElse: () => ViewMode.grid,
    );
    emit(ThemeState(mode: mode, viewMode: viewMode));
  }
}
