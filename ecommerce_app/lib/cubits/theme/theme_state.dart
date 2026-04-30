import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ViewMode { grid, list }

class ThemeState extends Equatable {
  const ThemeState({this.mode = ThemeMode.system, this.viewMode = ViewMode.grid});

  final ThemeMode mode;
  final ViewMode viewMode;

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? mode, ViewMode? viewMode}) {
    return ThemeState(mode: mode ?? this.mode, viewMode: viewMode ?? this.viewMode);
  }

  @override
  List<Object?> get props => <Object?>[mode, viewMode];
}
