// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/employee_time.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/providers/farming_group_provider.dart';
import 'package:prodwo_timesheet/providers/selected_employee_index_provider.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:prodwo_timesheet/tools/format.dart';
import 'package:prodwo_timesheet/widgtes/drag_and_drop_tab_widgets/expansion_tile.dart';
import 'package:recase/recase.dart';
import 'package:sizer/sizer.dart';

ValueNotifier<int> _selectedEmployeeIndex;

class EmployeesTab extends StatefulWidget {
  final List<Employee> employees;
  final Map<String, List<Employee>> attendance;
  final Map<String, List<WorkOrder>> workOrders;
  final Map<Employee, List<EmployeeTime>> employeesTime;
  final int selectedIndex;
  const EmployeesTab({
    Key key,
    this.employees,
    this.attendance,
    this.workOrders,
    this.employeesTime,
    this.selectedIndex,
  }) : super(key: key);

  @override
  _EmployeesTabState createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<EmployeesTab> {
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
    widget.attendance.forEach((key, value) {
      result.addAll(value);
    });
    // selectedIndexList.clear();
    // selectedIndexList = List<bool>.generate(result.length, (index) {
    //   return false;
    // });
    // selectedIndexList.first = true;

    return result;
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

  Widget employeeBio(Employee employee) {
    return Column(
      children: [
        Text(employee.employID, style: TextStyle(color: Colors.white)),
        Text(employee.crewID, style: TextStyle(color: Colors.white)),
        Text(employee.dscrptn, style: TextStyle(color: Colors.white))
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    crewDescsByCrewID = generateCrewDescByCrewID();
    sortedEmployeeList = generateSortedEmployeeList();
    if (sortedEmployeeList.isNotEmpty) {
      selectedIndexList = generateSelectedIndexList();
    }

    _selectedEmployeeIndex = SelectedEmployeeNotifier.ret(0);
    SelectedEmployeeNotifier.notify(0);
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
                          width: 55.h,
                          child: Expanded(
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
                                        selectedIndexList.fillRange(
                                            0, selectedIndexList.length, false);
                                        selectedIndexList[index] = true;
                                        SelectedEmployeeNotifier.notify(
                                            getSelectedIndex(
                                                selectedIndexList));
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
                          )),

                          // child: ListView.builder(
                          //     addAutomaticKeepAlives: true,
                          //     itemCount: generateSortedEmployeeList().length,
                          //     itemBuilder: (BuildContext context,
                          //             int index) =>
                          //         Padding(
                          //           padding: EdgeInsets.only(bottom: 1.w),
                          //           child: ListTile(
                          //             shape: RoundedRectangleBorder(
                          //               side: BorderSide(
                          //                   color: selectedIndexList[index] ==
                          //                           true
                          //                       ? Colors.blue
                          //                       : Colors.transparent,
                          //                   width: 1),
                          //               borderRadius:
                          //                   BorderRadius.circular(10),
                          //             ),
                          //             tileColor: primaryColor,
                          //             // leading: statusIndicator(
                          //             //     getStatus(sortedEmployeeList[index])),
                          //             trailing: const Icon(
                          //               Icons.arrow_forward_ios,
                          //             ),
                          //             iconColor: Colors.white,
                          //             title: Row(
                          //               children: [
                          //                 // statusIndicator(getStatus(
                          //                 //   sortedEmployeeList[index],
                          //                 // )),
                          //                 Text(
                          //                   '${generateSortedEmployeeList()[index].fullname.toTitleCase()}',
                          //                   style: TextStyle(
                          //                       color: selectedIndexList[
                          //                                   index] ==
                          //                               true
                          //                           ? Colors.blue
                          //                           : Colors.white),
                          //                 ),
                          //               ],
                          //             ),
                          //             // subtitle: Row(
                          //             //     mainAxisAlignment:
                          //             //         MainAxisAlignment.spaceBetween,
                          //             //     children: [
                          //             //       Visibility(
                          //             //         visible: getEmployeeClockInTime(widget
                          //             //             .employeesTime.keys
                          //             //             .firstWhere((element) =>
                          //             //                 element.employID ==
                          //             //                 sortedEmployeeList[index]
                          //             //                     .employID)).isNotEmpty,
                          //             //         child: Text(
                          //             //           'Clocked In: ${getEmployeeClockInTime(widget.employeesTime.keys.firstWhere((element) => element.employID == sortedEmployeeList[index].employID))}',
                          //             //           style: TextStyle(
                          //             //               color:
                          //             //                   selectedIndexList[index] == true
                          //             //                       ? Colors.blue
                          //             //                       : Colors.white),
                          //             //         ),
                          //             //       ),
                          //             //       Visibility(
                          //             //         visible: getEmployeeClockOutTime(widget
                          //             //             .employeesTime.keys
                          //             //             .firstWhere((element) =>
                          //             //                 element.employID ==
                          //             //                 sortedEmployeeList[index]
                          //             //                     .employID)).isNotEmpty,
                          //             //         child: Text(
                          //             //           'Clocked Out: ${getEmployeeClockOutTime(widget.employeesTime.keys.firstWhere((element) => element.employID == sortedEmployeeList[index].employID))}',
                          //             //           style: TextStyle(
                          //             //               color:
                          //             //                   selectedIndexList[index] == true
                          //             //                       ? Colors.blue
                          //             //                       : Colors.white),
                          //             //         ),
                          //             //       )
                          //             //     ]),
                          //             selected: selectedIndexList[index],
                          //             onTap: () {
                          //               setState(() {
                          //                 selectedIndexList.fillRange(
                          //                     0,
                          //                     selectedIndexList.length,
                          //                     false);
                          //                 selectedIndexList[index] = true;
                          //                 SelectedEmployeeNotifier.notify(
                          //                     getSelectedIndex(
                          //                         selectedIndexList));
                          //               });
                          //               // print(selectedIndexList
                          //               //     .indexWhere((element) => element == false));
                          //               // print(selectedIndexList[index]);
                          //             },
                          //           ),
                          //         ))
                        ),
                        _verticalDivider,
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                  child: sortedEmployeeList.isNotEmpty
                                      ? employeeProfile(
                                          generateSortedEmployeeList()[
                                              selectedIndexList.indexWhere(
                                                  (element) =>
                                                      element == true)])
                                      : SizedBox()),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Container(
                                    child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    const ListTile(
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
                                  ],
                                )),
                              )),
                            ],
                          ),
                        )
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
