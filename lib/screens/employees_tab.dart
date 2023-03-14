// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:prodwo_timesheet/models/assigned_work_order.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/employee_time.dart';
import 'package:prodwo_timesheet/models/position_entry.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/providers/farming_group_provider.dart';
import 'package:prodwo_timesheet/providers/selected_employee_index_provider.dart';
import 'package:prodwo_timesheet/screens/map_tab.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:prodwo_timesheet/widgtes/drag_and_drop_tab_widgets/expansion_tile.dart';

import 'package:recase/recase.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sizer/sizer.dart';

ValueNotifier<int> _selectedEmployeeIndex;
final ValueNotifier<int> _employeeBioContentIndex = ValueNotifier(0);

class EmployeesTab extends StatefulWidget {
  final List<Employee> employees;
  final Map<String, List<Employee>> attendance;
  final Map<String, List<WorkOrder>> workOrders;
  final Map<Employee, List<EmployeeTime>> employeesTime;
  final Map<Employee, List<PositionEntry>> presentEmployeesPosition;
  final Map<String, List<AssignedWorkOrder>> assignedWorkOrders;

  final int selectedIndex;
  const EmployeesTab({
    Key key,
    this.employees,
    this.attendance,
    this.workOrders,
    this.employeesTime,
    this.selectedIndex,
    this.presentEmployeesPosition,
    this.assignedWorkOrders,
  }) : super(key: key);

  @override
  _EmployeesTabState createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<EmployeesTab> {
  Widget _employeeContentWidget;
  Widget _employeeBioContentWidget;
  // ignore: prefer_final_fields
  Widget _verticalDivider = VerticalDivider(
    color: primaryColor,
    thickness: 1.sp,
  );

  Widget statusIndicator(int status) {
    Color statusColor;

    if (status == 0) {
      statusColor = Colors.red;
    } else if (status == 1) {
      statusColor = Colors.green;
    } else if (status == 2) {
      statusColor = Colors.yellow;
    } else if (status == 3) {
      statusColor = Colors.blue;
    }
    return Text(
      "\u2022 ",
      style: TextStyle(color: statusColor, fontSize: 14.sp),
    );
  }

  Color getStatusIndicatorColor(int status) {
    Color statusColor;

    if (status == 0) {
      statusColor = Colors.red;
    } else if (status == 1) {
      statusColor = Colors.green;
    } else if (status == 2) {
      statusColor = Colors.yellow;
    } else if (status == 3) {
      statusColor = Colors.blue;
    }
    return statusColor;
  }

  int getStatus(Employee employee) {
    if (widget.attendance["Absent"].contains(employee)) {
      return 0;
    } else if (widget.attendance["Shift Completed"].contains(employee)) {
      return 3;
    } else if (isOnMealPeriod(employee, widget.attendance)) {
      return 2;
    }
    return 1;
  }

  bool isOnMealPeriod(
      Employee employee, Map<String, List<Employee>> attendance) {
    if (attendance['Meal Period'].contains(employee)) {
      print(employee.fullname + ' is on meal period');
      return true;
    }
    print(employee.fullname + ' is not on meal period');
    return false;
  }

  List<Employee> sortedEmployeeList = [];
  List<Employee> generateSortedEmployeeList() {
    List<Employee> result = [];
    // widget.attendance.forEach((key, value) {
    //   result.addAll(value);
    // });

    return widget.employees;
  }

  List<bool> selectedIndexList = [];
  List<bool> generateSelectedIndexList() {
    List<bool> result =
        List<bool>.generate(generateSortedEmployeeList().length, (index) {
      return false;
    });
    result.first = true;
    return result;
  }

  void updateEmployeeBioContentWidget(int index) {
    _employeeBioContentIndex.value = index;
  }

  int employeeBioContentIndex = 0;
  Widget employeeBio(Employee employee) {
    return Column(
      children: [
        Container(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _employeeContentWidget = employeeHub(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)]);
                  });
                },
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Employee Bio',
                        style:
                            TextStyle(color: labelingColor, fontSize: 8.sp))))
          ],
        )),
        Divider(
          color: Colors.blue,
          thickness: 1.sp,
        ),
        employeeBioInfo(employee)
        // ToggleSwitch(
        //   inactiveBgColor: Colors.lightBlueAccent,
        //   minWidth: 15.h,
        //   initialLabelIndex: 0,
        //   totalSwitches: 2,
        //   // ignore: prefer_const_literals_to_create_immutables
        //   labels: [
        //     'Info',
        //     'Location',
        //   ],
        //   onToggle: (index) {
        //     setState(() {
        //       updateEmployeeBioContentWidget(index);
        //     });
        //   },
        // ),
        // ValueListenableBuilder(
        //   valueListenable: _employeeBioContentIndex,
        //   builder: (context, value, child) {
        //     if (value == 0) {
        //       _employeeBioContentWidget = employeeBioInfo(employee);
        //     } else if (value == 1) {
        //       // _employeeBioContentWidget = MapTab(
        //       //   presentEmployeesPosition: presentEmployeesPosition,
        //       //   attendanceList: widget.attendance,
        //       // );
        //       _employeeBioContentWidget = employeeCurrentPositionMap(employee);
        //       //
        //     }
        //     return Flexible(
        //         child: employeeBioContent(_employeeBioContentWidget));
        //   },
        // ),
      ],
    );
  }

  Widget employeeLocationContent(Employee employee) {
    return Column(
      children: [
        Container(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _employeeContentWidget = employeeHub(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)]);
                  });
                },
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Employee Location',
                        style:
                            TextStyle(color: labelingColor, fontSize: 8.sp))))
          ],
        )),
        Divider(
          color: Colors.blue,
          thickness: 1.sp,
        ),
        Flexible(child: employeeCurrentPositionMap(employee))
      ],
    );
  }

  Widget employeeBioContent(Widget content) {
    return content;
  }

  Widget employeeBioInfo(Employee employee) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ListTile(
          title: Text('Full Name',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text(employee.fullname,
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
        ListTile(
          title: Text('Employee ID',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text(employee.employID,
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
        ListTile(
          title: Text('Attendance Status',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text('Absent',
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
        ListTile(
          title: Text('Employee Description',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text(employee.dscrptn,
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
        ListTile(
          title: Text('Assigned Foreman',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text(employee.foreman,
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
        ListTile(
          title: Text('Currently Working On',
              style: TextStyle(color: labelingColor, fontSize: 5.sp)),
          subtitle: Text('*Work Order Card Here*',
              style: TextStyle(color: labelingColor, fontSize: 8.sp)),
        ),
      ],
    );
  }

  Widget employeeCurrentPositionMap(Employee employee) {
    return Padding(
      padding: EdgeInsets.only(top: 2.0.w),
      child: Container(
        decoration: BoxDecoration(
            color: primaryColor,
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        // height: 27.w,
        // width: 18.h,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: MapTab(
            presentEmployeesPosition: presentEmployeesPosition,
            attendanceList: widget.attendance,
          ),
        ),
      ),
    );
  }

  bool isRanchOnly(String drb) {
    if (drb.length > 4) {
      return false;
    }
    return true;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String formatDRB(String drb) {
    if (!isNumeric(drb)) {
      return drb;
    }
    if (drb.isEmpty) {
      return '';
    }

    if (drb.length < 5) {
      return drb.substring(2);
    }
    String pre = drb.substring(2, 4);
    String post = drb.substring(4);

    ////'in format' + result);
    return pre + '-' + post;
  }

  List<WorkOrder> getEmployeesWorkOrders(String employeeID) {
    List<WorkOrder> result = [];
    List<AssignedWorkOrder> assignedWorkOrders =
        widget.assignedWorkOrders[employeeID];
    widget.workOrders.forEach((key, value) {
      for (AssignedWorkOrder aw in assignedWorkOrders) {
        for (WorkOrder w in value) {
          if (w.DB_PRODWO.trim() == aw.DB_PRODWO.trim()) {
            result.add(w);
          }
        }
      }
    });
    print('getEmployeesWorkOrders');
    print(result);
    return result;
  }

  Widget employeeWorkOrdersContent(
      Employee employee, List<WorkOrder> workOrders) {
    return Column(
      children: [
        Container(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _employeeContentWidget = employeeHub(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)]);
                  });
                },
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Employee Work Orders',
                        style:
                            TextStyle(color: labelingColor, fontSize: 8.sp))))
          ],
        )),
        Divider(
          color: Colors.blue,
          thickness: 1.sp,
        ),
        Expanded(
            child: GroupedListView<dynamic, String>(
          elements: workOrders,
          groupBy: (element) => element.dbfarmingfunctionsname.trim(),

          //controller: workOrderColumnScrollController,
          useStickyGroupSeparators: true,
          stickyHeaderBackgroundColor: scaffoldBackgroundColor,
          floatingHeader: false,
          groupSeparatorBuilder: (String value) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: labelingColor,
                      ),
                    )),
              ],
            ),
          ),
          indexedItemBuilder: (c, element, int index) {
            return ClipRRect(
                child: Card(
              color: element.DB_FarmingActivity == 2
                  ? Color.fromARGB(255, 255, 211, 238)
                  : isRanchOnly(element.RANCHBLK) == true
                      ? Color.fromARGB(255, 255, 251, 211)
                      : element.DB_FarmingActivity == 4
                          ? Colors.transparent
                          : Color.fromARGB(255, 221, 255, 213),
              elevation: 3,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: AppExpansionTile(
                      initiallyExpanded: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.5),
                        child: Container(
                            height: 31,
                            width: 31,
                            child: FloatingActionButton(
                              mini: false,
                              backgroundColor: Colors.blue.shade900,
                              splashColor: Colors.black,
                              hoverElevation: 1.5,
                              shape: StadiumBorder(
                                  side:
                                      BorderSide(color: Colors.blue, width: 4)),
                              elevation: 1.5,
                              child: Icon(
                                Icons.task,
                                size: 6.sp,
                              ),
                            )),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${element.WOName.trim()} ',
                              style: TextStyle(color: labelingColor)),
                          // Text(
                          //     '${workOrders[index].WOName.trim()} '),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${formatDRB(element.RANCHBLK.trim())}',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: labelingColor),
                            ),
                          ),
                        ],
                      ),
                      // subtitle: getPlantingsByBlock(workOrders[index].RANCHBLK)
                      //         .isEmpty
                      //     ? SizedBox(
                      //         height: 0,
                      //         width: 0,
                      //       )
                      //     : Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //               '${getPlantingByBlock(workOrders[index].RANCHBLK)}'),
                      //           Text('First Planting Date: ' +
                      //               formatDate(getPlantingsByBlock(
                      //                       workOrders[index].RANCHBLK)
                      //                   .first
                      //                   .plantingDetail
                      //                   .plantingDate)),
                      //           Text('Estimated Harvest Date: ' +
                      //               formatDate(getPlantingsByBlock(
                      //                       workOrders[index].RANCHBLK)
                      //                   .first
                      //                   .plantingDetail
                      //                   .currHarvestDate)),
                      //         ],
                      //       ),
                      children: <Widget>[
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       left: 45.0, right: 45.0, bottom: 5.0),
                        //   child: ListView.builder(
                        //       physics: NeverScrollableScrollPhysics(),
                        //       scrollDirection: Axis.vertical,
                        //       shrinkWrap: true,
                        //       itemCount: assigneeList[element.DB_PRODWO].length,
                        //       itemBuilder: (BuildContext context, int index2) {
                        //         return Padding(
                        //           padding: const EdgeInsets.all(4.0),
                        //           child: Row(
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.spaceBetween,
                        //             children: [
                        //               Column(
                        //                 children: [
                        //                   Text(
                        //                       '${formatName(assigneeList[element.DB_PRODWO][index2].fullname.trim())} ',
                        //                       textAlign: TextAlign.start,
                        //                       style: TextStyle(
                        //                           color: Colors.black)),
                        //                 ],
                        //               ),
                        //               Column(
                        //                 children: [
                        //                   Text(
                        //                       '(${assigneeList[element.DB_PRODWO][index2].DBCHRS} hrs)',
                        //                       textAlign: TextAlign.end,
                        //                       style: TextStyle(
                        //                           color: Colors.black)),
                        //                 ],
                        //               )
                        //             ],
                        //           ),
                        //         );
                        //       }),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
          },
        )),
      ],
    );
  }

  Widget employeeTimesheet(Employee employee) {
    return Column(
      children: [
        Container(
            child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _employeeContentWidget = employeeHub(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)]);
                  });
                },
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.center,
                    child: Text('Employee Timesheet',
                        style:
                            TextStyle(color: labelingColor, fontSize: 8.sp))))
          ],
        )),
        Divider(
          color: Colors.blue,
          thickness: 1.sp,
        ),
      ],
    );
  }

  Widget employeeProfile(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3.0.w),
          child: Container(
              height: 25.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: primaryColor,
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50.sp,
                      //color: getStatusIndicatorColor(getStatus(employee)),
                      color: accentColor,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${employee.fullname}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: labelingColor, fontSize: 8.sp),
                    ),
                  ),
                  Divider(
                    color: Colors.blue,
                    thickness: 1.sp,
                  )
                ],
              )),
        )
      ],
    );
  }

  String getEmployeeClockInTime(Employee employee) {
    for (EmployeeTime t in widget.employeesTime[employee]) {
      if (t.DBType == 'STRTEND') {
        return t.strtTime;
      }
    }
    return '';
  }

  String getEmployeeClockOutTime(Employee employee) {
    for (EmployeeTime t in widget.employeesTime[employee]) {
      if (t.DBType == 'STRTEND' && t.endTime != '12:00:00 AM') {
        return t.endTime;
      }
    }
    return '';
  }

  int getSelectedIndex(List<bool> indexList) {
    for (int i = 0; i < indexList.length; i++) {
      var v = indexList[i];
      if (v == true) {
        return i;
      }
    }
  }

  String formatName(String name) {
    ReCase rc = ReCase(name);
    return rc.titleCase;
  }

  Map<String, String> crewDescsByCrewID = {};
  Map<String, String> generateCrewDescByCrewID() {
    Map<String, String> result = {};
    for (var e in widget.employees) {
      result.putIfAbsent(e.crewID.trim(), () {
        return e.dscrptn.trim();
      });
    }

    return result;
  }

  String getCrewDescByCrewID(String crewID) {
    return formatCrewDesc(crewDescsByCrewID[crewID.trim()]);
  }

  String formatCrewDesc(String crewDesc) {
    return crewDesc.substring(crewDesc.lastIndexOf(" ") + 1);
  }

  Widget employeeContent(Widget content) {
    return Container(child: content);
  }

  Widget employeeHub(Employee employee) {
    return Column(
      children: [
        Container(
            child: sortedEmployeeList.isNotEmpty
                ? employeeProfile(employee)
                : SizedBox()),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Container(
              child: ListView(
            physics: NeverScrollableScrollPhysics(),
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    _employeeContentWidget = employeeBio(employee);
                  });
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                iconColor: labelingColor,
                title: Text(
                  'Employee Bio',
                  style: TextStyle(color: labelingColor),
                ),
              ),
              Divider(
                color: Colors.blue,
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _employeeContentWidget = employeeWorkOrdersContent(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)],
                        getEmployeesWorkOrders(employee.employID));
                  });
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                iconColor: labelingColor,
                title: Text(
                  'Work Orders',
                  style: TextStyle(color: labelingColor),
                ),
              ),
              Divider(
                color: Colors.blue,
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _employeeContentWidget = employeeTimesheet(
                        generateSortedEmployeeList()[selectedIndexList
                            .indexWhere((element) => element == true)]);
                  });
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                iconColor: labelingColor,
                title: Text(
                  'Timesheet',
                  style: TextStyle(color: labelingColor),
                ),
              ),
              Divider(
                color: Colors.blue,
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _employeeContentWidget = employeeLocationContent(employee);
                  });
                },
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                iconColor: labelingColor,
                title: Text(
                  'Location',
                  style: TextStyle(color: labelingColor),
                ),
              ),
              Divider(
                color: Colors.blue,
              ),
            ],
          )),
        )),
      ],
    );
  }

  Map<Employee, List<PositionEntry>> presentEmployeesPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    presentEmployeesPosition = widget.presentEmployeesPosition;
    crewDescsByCrewID = generateCrewDescByCrewID();
    sortedEmployeeList = generateSortedEmployeeList();
    if (sortedEmployeeList.isNotEmpty) {
      selectedIndexList = generateSelectedIndexList();
    }

    _selectedEmployeeIndex = SelectedEmployeeNotifier.ret(0);
    SelectedEmployeeNotifier.notify(0);
    _employeeContentWidget = employeeHub(generateSortedEmployeeList()[
        selectedIndexList.indexWhere((element) => element == true)]);
    _employeeBioContentWidget = employeeBioInfo(generateSortedEmployeeList()[
        selectedIndexList.indexWhere((element) => element == true)]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 3.0.w, bottom: 3.w, left: 10.h, right: 2.h),
      child: Container(
        width: 100.h,
        height: 90.w,
        child: ValueListenableBuilder(
            valueListenable: _selectedEmployeeIndex,
            builder: (BuildContext context, int value, Widget child) {
              print('inside _selectedEmployeeIndex value notifier');

              //setState(() {
              sortedEmployeeList = generateSortedEmployeeList();
              if (sortedEmployeeList.isNotEmpty) {
                selectedIndexList = generateSelectedIndexList();
                print(selectedIndexList.length);
                selectedIndexList.fillRange(0, selectedIndexList.length, false);
                selectedIndexList[value] = true;
              }

              // });

              return sortedEmployeeList.isEmpty
                  ? Center(
                      child: Text(
                          'No Employees for ${FarmingGroupNotifier.currentValue()}'),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.h,
                          child: GroupedListView<dynamic, String>(
                            elements: widget.employees,
                            groupBy: (element) => element.crewID,
                            //key: _employeeListViewKey,
                            //controller: employeeColumnScrollController,

                            useStickyGroupSeparators: true,
                            stickyHeaderBackgroundColor:
                                scaffoldBackgroundColor,
                            floatingHeader: false,
                            groupSeparatorBuilder: (String value) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getCrewDescByCrewID(value),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: labelingColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      value,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: labelingColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            indexedItemBuilder: (c, element, int index) {
                              return ClipRRect(
                                  child: Card(
                                color: widget.employees[index].crewID
                                            .contains('145') ==
                                        true
                                    ? Colors.lightBlueAccent
                                    : Colors.brown,
                                elevation: 2,
                                shape: selectedIndexList[index] == true
                                    //                       ? Colors.blue
                                    ? RoundedRectangleBorder(
                                        side: new BorderSide(
                                            color: Colors.blue, width: 2.0),
                                        borderRadius:
                                            BorderRadius.circular(4.0))
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: ListTile(
                                    selected: selectedIndexList[index],
                                    onTap: () {
                                      setState(() {
                                        updateEmployeeBioContentWidget(0);
                                        selectedIndexList.fillRange(
                                            0, selectedIndexList.length, false);
                                        selectedIndexList[index] = true;
                                        SelectedEmployeeNotifier.notify(
                                            getSelectedIndex(
                                                selectedIndexList));
                                        _employeeContentWidget = employeeHub(
                                            generateSortedEmployeeList()[
                                                selectedIndexList.indexWhere(
                                                    (element) =>
                                                        element == true)]);
                                      });
                                    },
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.5),
                                      child: Container(
                                          height: 31,
                                          width: 31,
                                          child: FloatingActionButton(
                                            mini: false,
                                            backgroundColor:
                                                selectedIndexList[index] == true
                                                    ? Colors.white
                                                    : Colors.blue.shade900,
                                            splashColor: Colors.black,
                                            hoverElevation: 1.5,
                                            shape: StadiumBorder(
                                                side: BorderSide(
                                                    color: selectedIndexList[
                                                                index] ==
                                                            true
                                                        ? Colors.blue.shade900
                                                        : Colors.blue,
                                                    width: 4)),
                                            elevation: 1.5,
                                            child: Icon(
                                              Icons.person,
                                              size: 6.sp,
                                              color: selectedIndexList[index] ==
                                                      true
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                          )),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${formatName(widget.employees[index].fullname.trim())}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: widget.employees[index]
                                                          .crewID
                                                          .contains('145') ==
                                                      true
                                                  ? Colors.black
                                                  : Colors.white,
                                            )),
                                        Text(
                                            '${widget.employees[index].employID.trim()}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: widget.employees[index]
                                                            .crewID
                                                            .contains('145') ==
                                                        true
                                                    ? Colors.black
                                                    : Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                            },
                          ),
                        ),
                        _verticalDivider,
                        Expanded(
                          child: AnimatedSwitcher(
                            transitionBuilder: ((child, animation) =>
                                ScaleTransition(
                                    child: child, scale: animation)),
                            duration: const Duration(milliseconds: 500),
                            child: _employeeContentWidget,
                          ),
                        )
                        //employeeHub()
                      ],
                    );
            }),
      ),
    );
  }
}

class EmployeeListViewItem extends StatefulWidget {
  final Widget child;
  const EmployeeListViewItem({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  _EmployeeListViewItemState createState() => _EmployeeListViewItemState();
}

class _EmployeeListViewItemState extends State<EmployeeListViewItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => throw UnimplementedError();
}
