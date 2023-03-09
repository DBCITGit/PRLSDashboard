import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/assignee.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';
import 'package:prodwo_timesheet/tools/utilities.dart';

class EmployeesToWorkOrdersWS {
  Future<dynamic> getEmployeesbyWorkOrderID(workOrderNumber) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/PRODWO/DB10401?db_prodwo=" +
              workOrderNumber.trim();
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      Map<String, List<Assignee>> result = {};

      List<Assignee> assigneeList = [];

      responseData.forEach((element) {
        assigneeList.add(Assignee(
            element['fullname'],
            element['CREWID'],
            element['DB_PRODWO'],
            element['EMPLOYID'],
            element['LASTNAME'],
            element['DBCHRS'].toString(),
            element['DBCTOHR']));
      });
      for (var assignee in assigneeList) {
        //print(assignee.fullname + assignee.DB_PRODWO);
      }
      // print('--------');
      // for (var assignee in assigneeList) {
      //   result.putIfAbsent(assignee.DB_PRODWO, () {
      //     List<Assignee> temp = [];
      //     for (var i in assigneeList) {
      //       if (i.DB_PRODWO == assignee.DB_PRODWO) {
      //         temp.add(i);
      //       }
      //     }
      //     return temp;
      //   });
      // }

      // result.forEach((key, value) {
      //   print(key);
      //   for (var i in value) {
      //     print(i);
      //   }
      // });

      return assigneeList;
    } on Exception {
      throw Exception("Function Timeout");
    }
  }

  Future<bool> assignEmployeeToWorkOrder(
      String workOrderID, String employeeID, double dbchrs) async {
    try {
      final String url =
          'http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/insertWorkOrderEmployees?db_prodwo=$workOrderID&employid=$employeeID&dbchrs=$dbchrs';
      print(url);
      final http.Response response = await http.post(Uri.parse(url));

      return checkHttpCode(response.statusCode);
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateWorkOrderHours(
    String completed,
    String dexRowID,
    double dbchrs,
  ) async {
    try {
      final String url =
          'http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/updateWorkOrderHours?completed=$completed&dbchrs=$dbchrs&dexrow=$dexRowID';
      print(url);
      final http.Response response = await http.post(Uri.parse(url));

      return checkHttpCode(response.statusCode);
    } catch (e) {
      print(e);
      return false;
    }
  }
}
