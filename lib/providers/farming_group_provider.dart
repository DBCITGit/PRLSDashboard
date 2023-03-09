import 'package:flutter/material.dart';

class FarmingGroupNotifier {
  static ValueNotifier<String> _act;

  static void notify(String farmingGroup) {
    _act.value = farmingGroup;
  }

  static ValueNotifier<String> ret(String def) {
    _act = ValueNotifier<String>(def);
    return _act;
  }

  static String currentValue() => _act.value;
}
