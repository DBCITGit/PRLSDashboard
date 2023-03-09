import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/assigned_work_order.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';

class WorkOrdersToEmployeeWS {
  Future<dynamic> getWorkOrdersByEmployeeID(String employeeID) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/PRODWO/getIndividualDetailBreakdown?employid=" +
              employeeID;
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      List<AssignedWorkOrder> assignedWorkOrdersList = [];

      responseData.forEach((element) {
        // print(element['DB_Completed']);
        // print(element['EMPLOYID']);
        // print(element['DBFarmingFunctionsName']);
        // print(element['DB_PRODWO']);
        // print(element['DBFarmingFunctionsDesc']);
        // print(element['DBCHRS'].toString());
        assignedWorkOrdersList.add(AssignedWorkOrder(
            element['DB_Completed'],
            element['EMPLOYID'],
            element['DBFarmingFunctionsName'],
            element['DB_PRODWO'],
            element['DBFarmingFunctionsDesc'],
            element['DBCHRS'].toString()));
      });
      print("Work Orders for $employeeID");
      for (var w in assignedWorkOrdersList) {
        print(w.DBFarmingFunctionsDesc);
      }
      return assignedWorkOrdersList;
    } on Exception {
      throw Exception("Function Timeout");
    }
  }
}
