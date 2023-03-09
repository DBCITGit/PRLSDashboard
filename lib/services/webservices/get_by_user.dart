// change web url here
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';
import 'package:prodwo_timesheet/tools/format.dart';

class GetByUserWS {
  List<String> getAllFarmingGroupsByRanch(var responseData, String ranch) {
    List<String> farmingGroupsByRanch = [];
    responseData.forEach((element) {
      if (element['Group'] == ranch) {
        farmingGroupsByRanch.add(element['block'].trim());
      }
    });
    return farmingGroupsByRanch;
  }

  Future<Map<String, List<String>>> getFarmingGroupsAndBlocksByUser(
      String userID) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/PRODWO/FarmGroupRanchBlocks/get?userID=$userID";
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      Map<String, List<String>> farmingGroups = {};

      responseData.forEach((element) {
        List<String> farmingGroupsByRanch = [];
        farmingGroups.putIfAbsent(element['Group'].trim(),
            () => getAllFarmingGroupsByRanch(responseData, element['Group']));
        // element['block'].trim();
        // element['Group'].trim();
      });
      // ws call print
      // print(url);
      // print('getEmployeesByFarmingGroup: Success');

      //for (var w in employeeList) print(w.fullname);

      return farmingGroups;
    } catch (e, stacktrace) {
      throw Exception('getFarmingGroupsByUser: ${e.toString()} | $stacktrace');
    }
  }
}
