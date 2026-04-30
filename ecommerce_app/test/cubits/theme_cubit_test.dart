import 'package:bloc_test/bloc_test.dart';
import 'package:ecommerce_app/cubits/theme/theme_cubit.dart';
import 'package:ecommerce_app/cubits/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  group('ThemeCubit', () {
    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme flips between light and dark',
      build: () => ThemeCubit(prefs: prefs),
      act: (ThemeCubit c) {
        c.setLightMode();
        c.toggleTheme();
        c.toggleTheme();
      },
      expect: () => <Matcher>[
        isA<ThemeState>().having((ThemeState s) => s.mode, 'mode', ThemeMode.light),
        isA<ThemeState>().having((ThemeState s) => s.mode, 'mode', ThemeMode.dark),
        isA<ThemeState>().having((ThemeState s) => s.mode, 'mode', ThemeMode.light),
      ],
    );

    test('theme persists across cubit restarts', () async {
      final ThemeCubit first = ThemeCubit(prefs: prefs);
      first.setDarkMode();
      await Future<void>.delayed(Duration.zero);

      final SharedPreferences freshPrefs = await SharedPreferences.getInstance();
      final ThemeCubit hydrated = ThemeCubit(prefs: freshPrefs);
      await Future<void>.delayed(Duration.zero);

      expect(hydrated.state.mode, ThemeMode.dark);
    });

    blocTest<ThemeCubit, ThemeState>(
      'setViewMode updates view preference without changing theme mode',
      build: () => ThemeCubit(prefs: prefs),
      act: (ThemeCubit c) => c.setViewMode(ViewMode.list),
      expect: () => <Matcher>[
        isA<ThemeState>().having((ThemeState s) => s.viewMode, 'viewMode', ViewMode.list),
      ],
    );
  });
}
