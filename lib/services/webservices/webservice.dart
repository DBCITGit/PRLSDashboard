import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/audit.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';

class Webservice {
  int secTimeout = 45;
  Webservice();

  Future<int> fetchLocation(String email) async {
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/DBC/getlocation?email=$email"))
          .timeout(Duration(seconds: secTimeout));
      int index = ["01", "02", "06", "09"].indexOf(response.body);
      if (index == -1) index = 0;
      return index;
    } on Exception {
      throw Exception("fetchLocation Timeout");
    }
  }

  Future<void> auditApp(Audit audit) async {
    try {
      await http
          .post(
            Uri.parse(
                "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/DBC/auditapp"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(audit.toJson()),
          )
          .timeout(
            Duration(
              seconds: 5,
            ),
          );
    } on Exception {
      print(
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/DBC/auditapp");
      throw Exception("Audit Timeout");
    }
  }

  Future<void> updateLocationCode(String locationCode) async {
    try {
      await http.post(
        Uri.parse(
            "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/DBC/updatelocationcode?locationCode=$locationCode&email=${ServerSettingsPreferences.currentEmail}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(
        Duration(
          seconds: 5,
        ),
      );
    } on Exception {
      throw Exception("Location Code Timeout");
    }
  }
}
