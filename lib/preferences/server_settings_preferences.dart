import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerSettingsPreferences {
  static String currentEmail = "temp_id";
  static String currentUserID = "temp_user";
  static Color preferredColor = Colors.blue;
  static ThemeData preferredTheme = ThemeData.light();
  static bool production = true;
  static String webUrl =
      "http://green.darrigo.com/DBCWebService/DBCWebService.asmx";
  static String webHost = "green.darrigo.com";
  static int indexOfServerSelected = 1;
  static int defaultDistrict = 0;
  static int language = 0;
  static String versionNumber = 'temp_versionNumber';
  static String buildNumber = 'buildNumber';

  static bool isFirstTime = false;

  static List<String> _webHosts = [
    "vmsqltest",
    "green.darrigo.com",
    "vmiis",
  ];
  static List<String> _webUrls = [
    "http://vmsqltest/DBCWebService/DBCWebService.asmx",
    "http://green.darrigo.com/DBCWebService/DBCWebService.asmx",
    "http://vmiis/DBCWebService/DBCWebService.asmx",
  ];

  static void updateWebUrlHost(bool value) {
    webUrl = value
        ? "http://green.darrigo.com/DBCWebService/DBCWebService.asmx"
        : "http://vmsqltest/DBCWebService/DBCWebService.asmx";
    webHost = value ? "green.darrigo.com" : "vmsqltest";
  }

  static Future<void> changeWebUrlHost(int index) async {
    webUrl = _webUrls[index];
    webHost = _webHosts[index];
    indexOfServerSelected = index;
    //"Updating to webUrl: $webUrl - webHost: $webHost");
  }

  static Future<String> getWorkerName() async {
    final prefs = await SharedPreferences.getInstance();
    String tempUserID = prefs.getString('userID');
    tempUserID = tempUserID.replaceAll('.', ' ');
    tempUserID = tempUserID
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    return tempUserID;
  }

  static Future<String> getID() async {
    final prefs = await SharedPreferences.getInstance();
    String tempEmail = prefs.getString('email');
    String tempUserID = prefs.getString('userID');
    if (tempEmail != null) {
      currentEmail = tempEmail;
    }
    if (tempUserID != null) {
      currentUserID = tempUserID;
    }
    return currentUserID;
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String tempEmail = prefs.getString('email');
    String tempUserID = prefs.getString('userID');
    if (tempEmail != null) {
      currentEmail = tempEmail;
    }
    if (tempUserID != null) {
      currentUserID = tempUserID;
    }
    return currentEmail;
  }

  static Future savePreferences(String userEmail, String userID, int language,
      String versionNumber, String buildNumber) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', userEmail);
    prefs.setString('userID', userID);
    prefs.setInt('language', language);
    prefs.setBool("hasLoggedIn", true);
    saveColor(preferredColor.red, preferredColor.green, preferredColor.blue,
        preferredColor.opacity);
    prefs.setBool('production', false);
    currentEmail = userEmail;
    currentUserID = userID;
    prefs.setString('versionNumber', versionNumber);
    prefs.setString('buildNumber', buildNumber);
    // language = prefs.getInt('language');
  }

  static Future<bool> emailExists() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("email"))
      return false;
    else {
      if (prefs.getString("email") == "temp_id") return false;
    }
    return true;
  }

  static Future getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String tempEmail = prefs.getString('email');
    String tempUserID = prefs.getString('userID');
    int tempDefaultDistrict = prefs.getInt("defaultDistrict");
    if (tempEmail != null) {
      currentEmail = tempEmail;
    }
    if (tempUserID != null) {
      currentUserID = tempUserID;
    }

    defaultDistrict = tempDefaultDistrict == null ? 0 : tempDefaultDistrict;
    getColor();
    production = prefs.getBool('production');
    language = prefs.getInt('language');
    versionNumber = prefs.getString('versionNumber');
    buildNumber = prefs.getString('buildNumber');
  }

  static Future saveDefaultDistrict(int selectedDistrict) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("defaultDistrict", selectedDistrict);
  }

  static Future saveColor(int r, int g, int b, double o) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('r', r);
    prefs.setInt('g', g);
    prefs.setInt('b', b);
    prefs.setDouble('o', o);
  }

  static Future getColor() async {
    final prefs = await SharedPreferences.getInstance();
    final r = prefs.getInt('r');
    final g = prefs.getInt('g');
    final b = prefs.getInt('b');
    final o = prefs.getDouble('o');
    if (r != null && g != null && b != null && o != null) {
      preferredColor = Color.fromRGBO(r, g, b, o);
    }
  }

  static Future clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', "temp_id");
    prefs.setString('userID', "temp_user");
    prefs.setString('versionNumber', "temp_versionNumber");
    prefs.setString('buildNumber', "temp_buildNumber");
    saveColor(Colors.blue.red, Colors.blue.green, Colors.blue.blue,
        Colors.blue.opacity);
    currentEmail = "temp_id";
    currentUserID = "temp_user";
  }
}
