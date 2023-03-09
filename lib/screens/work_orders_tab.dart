// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:sizer/sizer.dart';

class WorkOrdersTab extends StatefulWidget {
  final List<Employee> employees;
  final Map<String, List<WorkOrder>> workOrders;
  const WorkOrdersTab({Key key, this.employees, this.workOrders})
      : super(key: key);

  @override
  _WorkOrdersTabState createState() => _WorkOrdersTabState();
}

class _WorkOrdersTabState extends State<WorkOrdersTab> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.workOrders.keys.toList());
    for (var w in widget.workOrders['Completed']) {
      print(w.RANCHBLK);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 3.0.w, bottom: 3.w, left: 10.h, right: 2.h),
      child: Column(children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Work Orders',
              style: TextStyle(fontSize: 20, color: labelingColor),
            )),
        const Divider(
          height: 20,
          thickness: 2,
          indent: 00,
          endIndent: 0,
          color: Colors.blue,
        ),
      ]),
    );
  }
}
