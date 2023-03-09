import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class AppL10N {
  static String locale = 'en';
  static Map<String, String> localStr = {};

  Future<void> load() async {
    String jsonString =
        await rootBundle.loadString('lib/assets/translations/$locale.json');

    Map<String, dynamic> jsonMap = await json.decode(jsonString);

    localStr = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return localStr;
  }

  Future<String> getLocale() async {
    return locale;
  }
}
