import 'package:flutter/material.dart';

class LocationNotifier {
  static ValueNotifier<int> _loc;
  static List<String> selectedLocation = [];
  static String ranch;

  static void notify(int index) => _loc.value = index;

  static ValueNotifier ret() {
    _loc = ValueNotifier<int>(0);
    return _loc;
  }

  static int currentValue() => _loc.value;

  static void newLocation(List<String> location) => selectedLocation = location;

  static List<String> getLocation() => selectedLocation;
}
