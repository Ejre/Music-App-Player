import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'app_theme.dart';

@singleton
class ThemeCubit extends Cubit<ThemeData> {
  static const String _boxName = 'settings';
  static const String _key = 'theme_mode';

  ThemeCubit() : super(AppTheme.darkTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);
    final themeIndex = box.get(_key, defaultValue: 0); // 0 = dark
    emit(AppTheme.getTheme(AppThemeType.values[themeIndex]));
  }

  Future<void> setTheme(AppThemeType type) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, type.index);
    emit(AppTheme.getTheme(type));
  }
}
