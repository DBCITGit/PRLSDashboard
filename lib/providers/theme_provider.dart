import 'package:flutter/material.dart';

class ThemeNotifier {
  static ValueNotifier<int> _theme = ValueNotifier<int>(0);
  static ThemeData theme = ThemeData(
    cardColor: Colors.grey[100],
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
    //textTheme: TextTheme(titleLarge: TextStyle(color: Colors.red))
  ).copyWith(typography: Typography.material2018());

  static void notify() => _theme.value++;

  static void update(ThemeData newTheme) => theme = newTheme;

  static ValueNotifier<int> ret() {
    _theme = ValueNotifier<int>(0);
    return _theme;
  }

  static ThemeData getTheme() => theme;
}
