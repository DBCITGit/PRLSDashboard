import 'package:flutter/material.dart';

class SelectedEmployeeNotifier {
  static ValueNotifier<int> _index = ValueNotifier<int>(0);

  static void notify(int selected) {
    _index.value = selected;
  }

  static void reset() {
    _index.value = 0;
  }

  static ValueNotifier<int> ret(int def) {
    _index = ValueNotifier<int>(def);
    return _index;
  }
}
