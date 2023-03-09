// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, duplicate_ignore

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/employee_time.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';

import 'package:intl/intl.dart' as intl;

class GetEmployeeTimeWS {
  Future<dynamic> getEmployeeTimeByDate(String date, String employeeID) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/Position/getBreaksLunches?employid=$employeeID";
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      List<EmployeeTime> employeeTimeList = [];

      responseData.forEach((element) {
        var strtdate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss")
            .parse(element['STRTDATE'], true);
        var localStartDate = strtdate.toLocal().toString();

        var localStartTime = intl.DateFormat.jms()
            .format(DateTime.parse(element['STRTTIME']).toLocal());
        //var localStartTime = strtTime.toLocal().toString();

        var enddate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss")
            .parse(element['ENDDATE'], true);
        var localEndDate = enddate.toLocal().toString();

        var localEndTime = intl.DateFormat.jms()
            .format(DateTime.parse(element['ENDTIME']).toLocal());

        if (date == localStartDate)
          // ignore: curly_braces_in_flow_control_structures
          employeeTimeList.add(EmployeeTime(
              employID: element['EMPLOYID'].trim(),
              strtDate: localStartDate,
              strtTime: localStartTime,
              endDate: localEndDate,
              endTime: localEndTime,
              DBType: element['DBType'].trim(),
              DBConcurrent: element['DBConcurrent'],
              DBEdited: element['DBEdited']));
      });
      // ws call print
      // print(url);
      // print('getEmployeeTimeByDate: Success');
      employeeTimeList.sort((a, b) {
        return (DateFormat('yyyy-MM-dd hh:mm:ss a')
            .parse('1900-01-01 ' + a.strtTime)
            .compareTo(DateFormat('yyyy-MM-dd hh:mm:ss a')
                .parse('1900-01-01 ' + b.strtTime)));
      });

      return employeeTimeList;
    } catch (e, stacktrace) {
      throw Exception('getEmployeeTimeByDate: ${e.toString()} | $stacktrace');
    }
  }
}
