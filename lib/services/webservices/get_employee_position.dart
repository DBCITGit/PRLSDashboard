import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/position_entry.dart';

class GetEmployeePositionWS {
  Future<dynamic> getEmployeePositionByDate(
      String date, String employeeID) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/Position/getBlockCoords?id=$employeeID&date1=$date";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      var responseData = json.decode(response.body);
      List<PositionEntry> positionEntries = [];

      responseData.forEach((element) {
        var dateF =
            DateFormat("yyyy-MM-ddTHH:mm:ss").parse(element['TIME1'], true);
        var local = dateF.toLocal().toString();

        positionEntries.add(PositionEntry(
            deviceName: 'SM-A135U1',
            deviceID: 'test',
            employID: employeeID.trim(),
            inBlock: element['DBInBlock'].trim(),
            nearBlock: '',
            lat: element['DBSLatitude'],
            lng: element['DBSLongitude'],
            date: getDate(date),
            time: local,
            distance: element['distance'],
            leadDistance: element['leadDistance'],
            battery: element['DB_Battery'],
            accuracy: element['DB_Acc']));
      });

      print(url);

      return positionEntries;
    } on Exception {
      throw Exception("getEmployeePositionByDate Timeout");
    }
  }

  String getDate(String date) {
    return "${date}T00:00:00.000+00:00";
  }
}
