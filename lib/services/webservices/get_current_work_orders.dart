import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prodwo_timesheet/models/employee.dart';

import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';
import 'package:prodwo_timesheet/providers/location_provider.dart';
import 'package:prodwo_timesheet/services/webservices/user_blocks.dart';
import 'package:prodwo_timesheet/tools/utilities.dart';

class GetWorkOrderWS {
  Future<dynamic> getCurrentWorkOrders(
      String farmingGroup, bool isSpanish) async {
    var now = new DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    ////'Formated Date: ' + formattedDate);
    // String formattedDate = '2021-11-22';
    print(formattedDate);
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/PRODWO/DBR_GetWorkOrdersByDate?grouporactivity=$farmingGroup&date=$formattedDate 00:00:00.000";
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 45));

      var responseData;
      responseData = json.decode(response.body);
      List<WorkOrder> workOrders = [];

      responseData.forEach((element) {
        //   print(element);
        //   //  DB_PRODWO;
        //   //  RANCHBLK;
        //   //  DATE1;
        //   //  DBFarmingFunctionsID;
        //   //  DBFarmingFunctionsDescID;
        //   //  DB_Farming_GroupID;
        //   // int DB_Completed;
        //   //  USERID;
        //   // List<Employee> assignedEmployees;
        //   //  DB_Original_Date;
        //   //  DBCTOTHR;
        //   print(element['DB_PRODWO']);
        //   print(element['RANCHBLK']);
        //   print(element['DATE1']);
        //   print(element['DBFarmingFunctionsID']);
        //   print(element['DBFarmingFunctionsDescID']);
        //   print(element['DB_Farming_GroupID']);
        //   print(element['DB_Completed'].toString());
        //   print(element['USERID']);
        //   print(element['DB_Original_Date']);
        //   print(element['DBCTOTHR']);
        //   // assign the employees for that work order
        //   // call the other webservice call

        workOrders.add(WorkOrder(
            element['DB_PRODWO'].trim(),
            element['dbfarmingfunctionsdesc'].trim(),
            element['RANCHBLK'].trim(),
            element['DATE1'].trim(),
            element['DBFarmingFunctionsID'].trim(),
            element['DBFarmingFunctionsDescID'].trim(),
            element['DB_Farming_GroupID'].trim(),
            element['DB_Completed'],
            element['DB_Assigned'],
            element['dbfarmingactvity'],
            element['USERID'].trim(),
            [],
            element['DBCTOTHR'].toString(),
            element['DEX_ROW_ID'].toString(),
            element['dbfarmingfunctionsname']));
      });

      // responseData.forEach((element) => //element['RANCHBLK'].trim() +
      //     ': ' +
      //     element['dbfarmingfunctionsname'].trim() +
      //     ' / ' +
      //     element['dbfarmingfunctionsdesc'].trim() +
      //     ' ' +
      //     element["DB_Completed"].toString()));
      // //formattedDate);
      // //result);
      // /
      print(url);
      for (var element in workOrders) {
        print(element.DB_FarmingActivity);
      }
      return workOrders;
    } on TimeoutException catch (e) {
      throw Exception("getMultipleOrdersFDForDrawerByRanchToday Timeout $e");
    }
  }

  Future<bool> updateWorkOrderHours(
      int completed, double dbchrs, int dexRow) async {
    //
    try {
      final String url =
          'http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/updateWorkOrderHours?completed=$completed&dbchrs=$dbchrs&dexrow=$dexRow';
      final http.Response response = await http.post(Uri.parse(url));

      return checkHttpCode(response.statusCode);
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<dynamic> getOrder(String date) async {
    await loadGroup();
    String strGroup = LocationNotifier.selectedLocation
        .toString()
        .substring(1, LocationNotifier.selectedLocation.toString().length - 1);
    String tempranch;
    LocationNotifier.selectedLocation.length > 1 ||
            LocationNotifier.ranch == 'All' ||
            LocationNotifier.ranch == 'Todos'
        ? tempranch = '__'
        : tempranch = LocationNotifier.ranch.trim();

    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/WorkOrderV2/get?date=$date&Group=$strGroup&ranch=$tempranch"))
          .timeout(Duration(seconds: 15));
      var responseData = json.decode(response.body);
      return responseData;
    } on Exception {
      throw Exception("PRODWO GET Timeout");
    }
  }

  Future<List<WorkOrdersData>> DBR_GetWorkOrdersByDate(String date,
      {int assigned}) async {
    try {
      String assignedUrl;
      assigned == null ? assignedUrl = "" : assignedUrl = "&assigned=$assigned";
      if (LocationNotifier.selectedLocation.isEmpty) {
        await loadGroup();
      }

      String strGroup = "?grouporactivity=" +
          LocationNotifier.selectedLocation.toString().substring(
              1, LocationNotifier.selectedLocation.toString().length - 1);
      String tempranch;
      LocationNotifier.selectedLocation.length > 1 ||
              LocationNotifier.ranch == 'All' ||
              LocationNotifier.ranch == 'Todos'
          ? tempranch = ""
          : tempranch = "&ranch=01${LocationNotifier.ranch.trim()}%";

      String dateParam = "&date=$date";
      // print(
      //     "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrdersByDate" +
      //         strGroup +
      //         dateParam +
      //         tempranch +
      //         assignedUrl);
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrdersByDate" +
                  strGroup +
                  dateParam +
                  tempranch +
                  assignedUrl))
          .timeout(Duration(seconds: 15));
      List<WorkOrdersData> workOrderObject = List.empty(growable: true);
      if (json.decode(response.body).isEmpty) {
        return List.empty();
      }
      for (var item in json.decode(utf8.decode(response.bodyBytes))) {
        WorkOrdersData workOrdersData = WorkOrdersData.fromJson(item);
        workOrderObject.add(workOrdersData);
      }

      return workOrderObject;
    } catch (e) {
      // print(e);
      // print("ERRROR ON GETWORKORDERSBYDATE");
      return null;
    }
  }

  Future<dynamic> getWorkOrderReport(String date1, String date2,
      String function, String activity, String ranchblk) async {
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrderReport/?userId=${ServerSettingsPreferences.currentUserID}&dateFrom=$date1&dateTo=$date2&function=$function&activity=$activity&ranchblk=$ranchblk"))
          .timeout(Duration(seconds: 15));
      var responseData = json.decode(response.body);
      print(
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrderReport/?userId=${ServerSettingsPreferences.currentUserID}&dateFrom=$date1&dateTo=$date2&function=$function&activity=$activity&ranchblk=$ranchblk");

      return responseData;
    } on Exception {
      throw Exception("PRODWO SPECIFIC ORDER Timeout");
    }
  }

  Future<List<dynamic>> getRecentWorkOrder(String ranchblk) async {
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/recent?ranchblk=$ranchblk"))
          .timeout(Duration(seconds: 15));
      print(
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/recent?ranchblk=$ranchblk");
      var responseData = json.decode(response.body);
      return responseData;
    } on Exception {
      throw Exception("PRODWO SELECTED FG Ranchs Timeout");
    }
  }

  Future<List<dynamic>> getNextWorkOrder(String ranchblk) async {
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/next?ranchblk=$ranchblk"))
          .timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);

      return responseData;
    } on Exception {
      throw Exception("PRODWO SELECTED FG Ranchs Timeout");
    }
  }

  Future<List<dynamic>> getNoBlockWorkOrders(String ranchblk,
      {int weekselected}) async {
    String ranchblockURL = "?ranchblk=$ranchblk";
    String weekSelectedURL =
        weekselected != null ? "&weekselected=$weekselected" : "";
    print(
        "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/noBlockWorkOrders" +
            ranchblockURL +
            weekSelectedURL);
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/noBlockWorkOrders" +
                  ranchblockURL +
                  weekSelectedURL))
          .timeout(const Duration(seconds: 15));

      List<dynamic> responseData = json.decode(response.body);
      return responseData;
    } on Exception {
      throw Exception("Work Order Last Five Seasons Timeout");
    }
  }

  Future<List<String>> getLastSeasons(String ranchblk) async {
    print("GETLASTSEASONS");
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/lastFiveSeasons?ranchblk=$ranchblk"))
          .timeout(const Duration(seconds: 15));
      print(
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/lastFiveSeasons?ranchblk=$ranchblk");
      List<String> responseData = json.decode(response.body)[0].split(', ');
      return responseData;
    } on Exception {
      throw Exception("Work Order Last Five Seasons Timeout");
    }
  }

  Future<dynamic> recentSeasonWorkOrders(String ranchblk, String season) async {
    print(
        "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/recentSeason?ranchblk=$ranchblk&season=$season");
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/recentSeason?ranchblk=$ranchblk&season=$season"))
          .timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      // print((responseData['main'] as Map)[(responseData['main'] as Map).keys.toList()[0]].length);
      return responseData;
    } on Exception {
      throw Exception("PRODWO SELECTED FG Ranchs Timeout");
    }
  }

  Future<Map<String, dynamic>> getPriorNext(String distranch) async {
    print("Called getPriorNext webservice call");
    try {
      final response = await http
          .get(Uri.parse(
              "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/getPriorNext?distranch=$distranch"))
          .timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      return responseData;
    } on Exception {
      throw Exception("PRODWO SELECTED FG Ranchs Timeout");
    }
  }

  Future<void> loadGroup() async {
    LocationNotifier.selectedLocation = [
      (await getAllFarmGroups(true)).toList().first["groups"]
    ]; //  = [value.toList()[0]]);

    print('object');
    print(LocationNotifier.selectedLocation);
    return;
  }
}
