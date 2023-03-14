// Drag and Drop Tab To Do's
/*
 * Create a new endpoint to make the getPlanting webservice call more efficient
 * Implement a function to return the earliest planting for a block
 * Implement functionality to prohibit the user from dragging the multi-employee assign icon if no employees are selected
 * Implement logic to the color on the multi-employee assign icon
 * √ Add the grey colorway for awareness work orders 
 * Update the setState function for the filter dialogue / Will this functionality be removed? 
 */

import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:prodwo_timesheet/models/assigned_work_order.dart';
import 'package:prodwo_timesheet/models/assignee.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/planting.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/providers/farming_group_provider.dart';
import 'package:prodwo_timesheet/services/webservices/get_current_plantings.dart';
import 'package:prodwo_timesheet/services/webservices/get_work_orders_by_employee.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:prodwo_timesheet/tools/localizations.dart';
import 'package:prodwo_timesheet/widgtes/drag_and_drop_tab_widgets/expansion_tile.dart';

import 'package:recase/recase.dart';

import 'package:prodwo_timesheet/services/webservices/get_current_work_orders.dart';
import 'package:prodwo_timesheet/services/webservices/get_by_farming_group.dart';
import 'package:prodwo_timesheet/services/webservices/get_employees_by_work_order.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sizer/sizer.dart';

class DragAndDropTab extends StatefulWidget {
  const DragAndDropTab(
      {Key key,
      this.title,
      this.currentFarmingGroup,
      this.employees,
      this.workOrders,
      this.plantings,
      this.assignes,
      this.assignedWorkOrders})
      : super(key: key);

  final String title;
  final String currentFarmingGroup;
  final List<Employee> employees;
  final List<WorkOrder> workOrders;
  final Map<String, List<Assignee>> assignes;
  final Map<String, List<AssignedWorkOrder>> assignedWorkOrders;
  final Map<String, List<Planting>> plantings;
  @override
  State<DragAndDropTab> createState() => _DragAndDropTabState();
}

class _DragAndDropTabState extends State<DragAndDropTab> {
  TextEditingController textController = TextEditingController();
  //list of text controllers
  /// one for each row
  /// use the multi sleect to add to only teh selected users
  ScrollController workOrderColumnScrollController = ScrollController();
  ScrollController employeeColumnScrollController = ScrollController();
  List<Employee> employees = [];
  List<WorkOrder> workOrders = [];
  Map<String, List<Planting>> plantings = {};
  // ignore this for now
  List<Planting> pOldMethod = [];

  int getRandomNumber() {
    Random random = new Random();

    return random.nextInt(10) + 1;
  }

  bool isRanchOnly(String drb) {
    if (drb.length > 4) {
      return false;
    }
    return true;
  }

  String getEarliestPlantingDate(String block) {
    return '';
  }

  int getRandomShortNumber() {
    Random random = new Random();
    return random.nextInt(3) + 1;
  }

  Future<void> getPlantings() async {
    pOldMethod = await GetCurrentPlantingsWS().GetAllCurrentPlantings();
    return;
  }

  Future<void> getWorkers() async {
    employees = await GetByFarmingGroupsWS()
        .getEmployeesByFarmingGroup(FarmingGroupNotifier.currentValue());
    return;
  }

  Future<void> getWorkOrders() async {
    workOrders = await GetWorkOrderWS()
        .getCurrentWorkOrders(FarmingGroupNotifier.currentValue(), false);
    workOrders.sort(
        (a, b) => a.dbfarmingfunctionsname.compareTo(b.dbfarmingfunctionsname));
    setState(() {
      totalWorkOrderHours = getTotalWorkOrderHours();
    });
    return;
  }

  Future<void> getPlantingsByFarmingGroup() async {
    plantings = await GetByFarmingGroupsWS()
        .getCurrentPlantingsByFarmingGroup(FarmingGroupNotifier.currentValue());
    return;
  }

  Future<void> getPlantingsByWorkOrders() async {
    plantings = await GetByFarmingGroupsWS()
        .getCurrentPlantingsByWorkOrders(getWorkOrderDRBs());
    return;
  }

  List<String> getWorkOrderDRBs() {
    List<String> result = [];
    for (WorkOrder wo in workOrders) {
      result.add(wo.RANCHBLK);
    }

    return result;
  }

  // left column
  Future<List<Assignee>> getAssigneesByWorkOrder(String workOrderNumber) async {
    List<Assignee> assigneeList = [];
    assigneeList = await EmployeesToWorkOrdersWS()
        .getEmployeesbyWorkOrderID(workOrderNumber);

    return assigneeList;
  }

  Map<String, List<Assignee>> assigneeList = {};
  Future<Map<String, List<Assignee>>> iterateAssignees() async {
    for (var c in workOrders) {
      List temp = await getAssigneesByWorkOrder(c.DB_PRODWO);
      assigneeList.putIfAbsent(c.DB_PRODWO, () {
        return temp;
      });
    }
    return assigneeList;
  }

  Future<void> updateWorkOrderHours(
      String completed, String dexRowID, double dbchrs) async {
    print('in updateFunction');
    print(completed);
    print(dexRowID);
    print(dbchrs);
    await EmployeesToWorkOrdersWS()
        .updateWorkOrderHours(completed, dexRowID, dbchrs);
    return;
  }

  // right column
  Future<List<AssignedWorkOrder>> getWorkOrdersByEmployeeID(
      String employeeID) async {
    return await WorkOrdersToEmployeeWS().getWorkOrdersByEmployeeID(employeeID);
  }

  Map<String, List<AssignedWorkOrder>> assignedWorkOrdersList = {};
  Future<Map<String, List<AssignedWorkOrder>>>
      iterateAssignedWorkOrders() async {
    for (var e in employees) {
      List temp = await getWorkOrdersByEmployeeID(e.employID);
      assignedWorkOrdersList.putIfAbsent(e.employID, () {
        return temp;
      });
    }
    return assignedWorkOrdersList;
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

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String formatName(String name) {
    ReCase rc = ReCase(name);
    return rc.titleCase;
  }

  String formatCrewDesc(String crewDesc) {
    return crewDesc.substring(crewDesc.lastIndexOf(" ") + 1);
  }

  double formatDurationtoDouble(Duration dur) {
    String input = '${dur.inHours}:${dur.inMinutes.remainder(60)}';
    String firstHalf = input.substring(0, input.indexOf(':'));
    String secHalf = input.substring(input.indexOf(':') + 1);

    int hour = int.parse(firstHalf);
    int min = int.parse(secHalf);

    return hour + min / 60;
  }

  String totalWorkOrderHours = '';
  String getTotalWorkOrderHours() {
    double temp = 0;

    for (WorkOrder wo in workOrders) {
      // print(wo.DBCTOTHR);
      temp += double.parse(wo.DBCTOTHR);
    }
    return temp.toString();
  }

  String getWorkOrderStatus(int val) {
    return val == 1 ? '\u2713' : '';
  }

  String getPlantingByBlock(String drb) {
    if (!plantings.containsKey(drb)) {
      return '';
    }
    for (Planting p in plantings[drb]) {
      if (p.ranchBlock.trim() == drb.trim()) {
        return p.commodityDesc;
      }
    }
    return '';
  }

  List<Planting> getPlantingsByBlock(String drb) {
    if (!plantings.containsKey(drb)) {
      return [];
    }
    List v = plantings[drb].toList();
    return v ?? [];
  }

  String getSiteAcresByBlock(String drb) {
    for (Planting p in pOldMethod) {
      if (p.ranchBlock.trim() == drb.trim()) {
        return double.parse(p.siteAcres).toStringAsFixed(2);
      }
    }
    return '';
  }

  String getWorkOrderDexRowID(String workOrderID) {
    for (var w in workOrders) {
      if (w.DB_PRODWO.trim() == workOrderID) {
        return w.DEX_ROW_ID.trim();
      }
    }
    return '';
  }

  String getWorkOrderIsCompleted(String workOrderID) {
    for (var w in workOrders) {
      if (w.DB_PRODWO.trim() == workOrderID) {
        return w.DB_Completed.toString().trim();
      }
    }
    return '';
  }

  String getCrewDescByCrewID(String crewID) {
    return formatCrewDesc(crewDescsByCrewID[crewID.trim()]);
  }

  Map<String, String> crewDescsByCrewID = {};
  Map<String, String> generateCrewDescByCrewID() {
    Map<String, String> result = {};
    for (var e in employees) {
      result.putIfAbsent(e.crewID.trim(), () {
        return e.dscrptn.trim();
      });
    }

    return result;
  }

  double getUpdatedWorkOrderHours(String workOrderID, double newTimeEntry) {
    double result = 0.0;
    for (var w in workOrders) {
      if (w.DB_PRODWO.trim() == workOrderID) {
        return double.parse(w.DBCTOTHR) + newTimeEntry;
      }
    }
    return result;
  }

  Employee getEmployeeByEmployeeID(String employeeID) {
    Employee result;
    for (Employee e in employees) {
      if (e.employID.trim() == employeeID) {
        return e;
      }
    }
    return result;
  }

  WorkOrder getWorkOrderByWorkOrderID(String workOrderID) {
    WorkOrder result;
    for (WorkOrder w in workOrders) {
      if (w.DB_PRODWO.trim() == workOrderID) {
        return w;
      }
    }
    return result;
  }

  void updateDuration(Duration res) {
    setState(() {
      _duration = res;
    });

    return;
  }

  void showAddedEmployeeAnimation() {}
  bool isAssigingHours = false;
  Duration _duration = const Duration(hours: 0, minutes: 0);
  Duration _temp = const Duration(hours: 0, minutes: 0);
  void assignSingleEmployee(
      String employeeID, String workOrderID, int cardIndex, bool employeeToWO) {
    setState(() {
      isAssigingHours = true;
    });

    showModalBottomSheet<void>(
      elevation: 0.0,
      isDismissible: false,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.2),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setModalState) {
        return SizedBox.expand(
            child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                color: scaffoldBackgroundColor),
            height: 580,
            width: 530,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  'Assign',
                  style: TextStyle(fontSize: 35, color: Colors.black),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Container(
                    width: 300,
                    height: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.blue)),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50, left: 0),
                  child: employeeToWO
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Card(
                                color: primaryColor,
                                elevation: 5,
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          getEmployeeByEmployeeID(employeeID)
                                              .employID
                                              .trim(),
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                          formatName(getEmployeeByEmployeeID(
                                                  employeeID)
                                              .fullname
                                              .trim()),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${formatCrewDesc(getEmployeeByEmployeeID(employeeID).dscrptn.trim())}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text(
                                          '${getEmployeeByEmployeeID(employeeID).crewID.trim()}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Card(
                                color: primaryColor,
                                elevation: 5,
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDRB(
                                          getWorkOrderByWorkOrderID(workOrderID)
                                              .RANCHBLK
                                              .trim(),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.task,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                          getWorkOrderByWorkOrderID(workOrderID)
                                              .WOName
                                              .trim(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${getPlantingByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK)}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                          '${getSiteAcresByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK)}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Card(
                                color: primaryColor,
                                elevation: 5,
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDRB(
                                          getWorkOrderByWorkOrderID(workOrderID)
                                              .RANCHBLK
                                              .trim(),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.task,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                          getWorkOrderByWorkOrderID(workOrderID)
                                              .WOName
                                              .trim(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${getPlantingByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK)}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                          '${getSiteAcresByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK)}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Card(
                                color: primaryColor,
                                elevation: 5,
                                child: ListTile(
                                  isThreeLine: true,
                                  leading: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          getEmployeeByEmployeeID(employeeID)
                                              .employID
                                              .trim(),
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                          formatName(getEmployeeByEmployeeID(
                                                  employeeID)
                                              .fullname
                                              .trim()),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${formatCrewDesc(getEmployeeByEmployeeID(employeeID).dscrptn.trim())}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Text(
                                          '${getEmployeeByEmployeeID(employeeID).crewID.trim()}',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 20.0, right: 20),
                            //   child: Card(
                            //     elevation: 5,
                            //     child: ListTile(
                            //       isThreeLine: true,
                            //       leading: Column(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Text(
                            //               "${_duration.inHours}:${_duration.inMinutes.remainder(60)}",
                            //               style: TextStyle(fontSize: 15)),
                            //           Icon(
                            //             Icons.punch_clock,
                            //             color: Colors.blue,
                            //           ),
                            //         ],
                            //       ),
                            //       title: Row(
                            //         children: [
                            //           Text("Time", style: TextStyle(fontSize: 15)),
                            //         ],
                            //       ),
                            //       subtitle: Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           Text(
                            //               '${DateFormat('MM-dd-yyyy').format(DateTime.parse(getWorkOrderByWorkOrderID(workOrderID).DB_Original_Date.trim()))}'),
                            //         ],
                            //       ),
                            //       trailing: Builder(
                            //           builder: (BuildContext context) =>
                            //               FloatingActionButton.small(
                            //                 onPressed: () async {
                            //                   var res = await showDurationPicker(
                            //                     context: context,
                            //                     initialTime:
                            //                         const Duration(seconds: 30),
                            //                     baseUnit: BaseUnit.minute,
                            //                     snapToMins: 5.0,
                            //                   );
                            //                   setModalState(() {
                            //                     if (res != null) {
                            //                       _duration = res;
                            //                     }
                            //                   });
                            //                 },
                            //                 tooltip: 'Popup Duration Picker',
                            //                 child: const Icon(Icons.add),
                            //               )),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: FloatingActionButton.extended(
                    label: Text('Confirm'),
                    onPressed: () async {
                      print(workOrderID);
                      print(employeeID);
                      // print(formatDurationtoDouble(_duration));

                      await EmployeesToWorkOrdersWS()
                          .assignEmployeeToWorkOrder(workOrderID, employeeID,
                              formatDurationtoDouble(_duration))
                          .then((value) => setState(() {
                                updateWorkOrderHours(
                                        getWorkOrderIsCompleted(workOrderID),
                                        getWorkOrderDexRowID(workOrderID),
                                        getUpdatedWorkOrderHours(workOrderID,
                                            formatDurationtoDouble(_duration)))
                                    .then((value) {
                                  getWorkOrders();
                                  getWorkers();
                                  assigneeList.clear();
                                  assignedWorkOrdersList.clear();
                                  _iterateAssignees = iterateAssignees();
                                  _iterateAssignedWorkOrders =
                                      iterateAssignedWorkOrders();
                                  // _iteratePlantings =
                                  //     getPlantingsByWorkOrders();
                                  setState(() {});
                                  Navigator.pop(context);
                                  return null;
                                });
                              }));
                    }),
              ),
            ]),
          ),
        ));
      }),
    ).whenComplete(() => setState(() {
          isAssigingHours = false;
        }));

    return;
  }

  void _showFilterDialog() {
    setState(() {
      isAssigingHours = true;
    });

    showModalBottomSheet<void>(
      elevation: 0.0,
      isDismissible: false,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.2),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setModalState) {
        return SizedBox.expand(
            child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                color: scaffoldBackgroundColor),
            height: 580,
            width: 530,
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(top: 25, bottom: 20),
                child: Text(
                  'Work Orders',
                  style: TextStyle(fontSize: 35, color: labelingColor),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 6, bottom: 6),
              //   child: Container(
              //       width: 300,
              //       height: 5,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(30.0),
              //           color: Colors.blue)),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group By',
                            style: TextStyle(
                              //fontSize: 28,
                              color: labelingColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          // divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: ClipRRect(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                  ),
                                  color: Colors.blue,
                                ),
                                height: 3,
                                width: 200,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.height / 4,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: false,
                            itemCount: 4,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                        width: 2, color: Colors.blue),
                                    checkColor: Colors.white,
                                    value: groupByCheckCircles[index],
                                    shape: CircleBorder(),
                                    onChanged: (value) {
                                      setModalState(() {
                                        setState(() async {
                                          filterByCheckCricles.fillRange(
                                              0,
                                              filterByCheckCricles.length,
                                              false);
                                          groupByCheckCircles.fillRange(
                                              0,
                                              groupByCheckCircles.length,
                                              false);
                                          groupByCheckCircles[index] = value;
                                          currentGroupByParameter =
                                              groupByOptions[index];
                                          filterByCheckCricles =
                                              generateFilterByCheckCricles();
                                          filteredWorkOrders =
                                              await getFilteredWorkOrders();
                                        });
                                      });
                                      return;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      getGroupByOptions()[index],
                                      style: TextStyle(
                                          color: labelingColor, fontSize: 18),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter By',
                            style: TextStyle(
                              //fontSize: 28,
                              color: labelingColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          // divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: ClipRRect(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                  ),
                                  color: Colors.blue,
                                ),
                                height: 3,
                                width: 200,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.height / 4,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: false,
                            itemCount:
                                getFilterByOptions(currentGroupByParameter)
                                    .length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                        width: 2, color: Colors.blue),
                                    checkColor: Colors.white,
                                    value: filterByCheckCricles[index],
                                    shape: CircleBorder(),
                                    onChanged: (value) {
                                      setModalState(() {
                                        setState(() async {
                                          // filterByCheckCricles.fillRange(
                                          //     0,
                                          //     filterByCheckCricles.length,
                                          //     false);
                                          filterByCheckCricles[index] = value;
                                          print(getSelectedFilterParameters());
                                          filteredWorkOrders =
                                              await getFilteredWorkOrders();
                                          for (var f in filteredWorkOrders)
                                            print(f.WOName.trim());
                                        });
                                      });
                                      return;
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      getFilterByOptions(
                                          currentGroupByParameter)[index],
                                      style: TextStyle(
                                          color: labelingColor, fontSize: 18),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  )
                ],
              ),
            ]),
          ),
        ));
      }),
    ).whenComplete(() => setState(() {
          isAssigingHours = false;
        }));

    return;
  }

  bool hasSelectedAtLeastOneEmployee = false;
  bool promptWorkOrderSelection = false;
  bool animateConfirmationButton = false;
  void assignMultipleEmployees(
      List<Employee> _selectedEmployees, String workOrderID, int cardIndex) {
    setState(() {
      isAssigingHours = true;
    });

    showModalBottomSheet<void>(
      elevation: 0.0,
      isDismissible: false,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.2),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setModalState) {
        return SizedBox.expand(
            child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                color: scaffoldBackgroundColor),
            height: 580,
            width: 530,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  'Assign',
                  style: TextStyle(fontSize: 35, color: labelingColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Container(
                    width: 300,
                    height: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.blue)),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 15, left: 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 5),
                        child: Card(
                          color: primaryColor,
                          elevation: 5,
                          child: ListTile(
                            isThreeLine: true,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDRB(
                                      getWorkOrderByWorkOrderID(workOrderID)
                                          .RANCHBLK
                                          .trim()),
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.task,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Text(
                                    getWorkOrderByWorkOrderID(workOrderID)
                                        .WOName
                                        .trim(),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${getPlantingByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                getPlantingsByBlock(getWorkOrderByWorkOrderID(
                                                workOrderID)
                                            .RANCHBLK)
                                        .isEmpty
                                    ? SizedBox()
                                    : (Text(
                                        '${getPlantingsByBlock(getWorkOrderByWorkOrderID(workOrderID).RANCHBLK).first.plantingDetail.currHarvestDate}',
                                        style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: scaffoldBackgroundColor,
                        height: 300,
                        child: ListView.builder(
                            //physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _selectedEmployees.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Card(
                                    color: primaryColor,
                                    elevation: 5,
                                    child: ListTile(
                                      isThreeLine: true,
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              _selectedEmployees[index]
                                                  .employID
                                                  .trim(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                              formatName(
                                                  _selectedEmployees[index]
                                                      .fullname
                                                      .trim()),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${formatCrewDesc(_selectedEmployees[index].dscrptn.trim())}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            '${_selectedEmployees[index].crewID.trim()}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: FloatingActionButton.extended(
                    label: Text('Confirm'),
                    onPressed: () async {
                      print(workOrderID);
                      //print(employeeID);
                      // print(formatDurationtoDouble(_duration));
                      for (int i = 0; i < _selectedEmployees.length; i++) {
                        print('adding ' +
                            _selectedEmployees[i].fullname.trim() +
                            ' to ' +
                            workOrderID);
                        await EmployeesToWorkOrdersWS()
                            .assignEmployeeToWorkOrder(
                                workOrderID,
                                _selectedEmployees[i].employID.trim(),
                                formatDurationtoDouble(_duration));
                      }

                      setState(() {
                        updateWorkOrderHours(
                                getWorkOrderIsCompleted(workOrderID),
                                getWorkOrderDexRowID(workOrderID),
                                getUpdatedWorkOrderHours(workOrderID,
                                    formatDurationtoDouble(_duration)))
                            .then((value) {
                          getWorkOrders();
                          getWorkers();
                          assigneeList.clear();
                          assignedWorkOrdersList.clear();
                          _iterateAssignees = iterateAssignees();
                          _iterateAssignedWorkOrders =
                              iterateAssignedWorkOrders();
                          //_iteratePlantings = getPlantingsByWorkOrders();
                          setState(() {});
                          showCheckCircle = false;
                          isMultiSelecting = false;
                          promptWorkOrderSelection = false;
                          animateConfirmationButton = false;
                          employeeIsMultiSelected.fillRange(
                              0, employeeIsMultiSelected.length, false);
                          Navigator.pop(context);
                          return null;
                        });
                      });
                    }),
              ),
            ]),
          ),
        ));
      }),
    ).whenComplete(() => setState(() {
          isAssigingHours = false;
        }));

    return;
  }

  int getEmployeeIndexBeingDragged() {
    return employeeIndexBeingDragged;
  }

  bool isDraggingEmployee = false;
  int employeeIndexBeingDragged = -1;

  int getWorkOrderIndexBeingDragged() {
    return workOrderIndexBeingDragged;
  }

  bool isDraggingWorkOrder = false;
  int workOrderIndexBeingDragged = -1;

  final _workOrderListViewKey = GlobalKey();
  final _employeeListViewKey = GlobalKey();

  List<GlobalKey<AppExpansionTileState>> expansionTileKeys = [];
  List<GlobalKey<AppExpansionTileState>> generateExpansionTileKeys(
      int numOfWorkOrders) {
    return new List<GlobalKey<AppExpansionTileState>>.generate(
        numOfWorkOrders, (i) => new GlobalKey());
  }

  List<TextEditingController> rowCallStartTimeControllers = [];
  List<TextEditingController> generateRowCallStartTimeControllers(int numRows) {
    return new List<TextEditingController>.generate(
        numRows, (i) => new TextEditingController());
  }

  List<TextEditingController> rowCallShiftScheduleControllers = [];
  List<TextEditingController> generateRowCallShiftScheduleControllers(
      int numRows) {
    return List<TextEditingController>.generate(
        numRows, (i) => TextEditingController());
  }

  void expandWorkOrderCards() {
    print('------------------------------------------------------');
    print(workOrders.length);
    print(expansionTileKeys.length);
    for (var c in expansionTileKeys) {
      setState(() {
        print(c.currentContext);
      });
    }
    return;
  }

  Map<String, double> dataMap = {
    "Flutter": 5,
    "React": 3,
    "Xamarin": 2,
    "Ionic": 2,
  };

  List<String> getAllUniqueCrews() {
    List<String> result = [];
    for (var e in employees) {
      if (!result.contains(e.crewID.trim())) result.add(e.crewID.trim());
    }
    return result;
  }

  List<Employee> getEmployeesByCrewNumber(String crewNum) {
    List<Employee> result = [];
    for (Employee e in employees) {
      if (e.crewID.trim() == crewNum.trim()) {
        result.add(e);
      }
    }
    return result;
  }

  Map<String, List> employeeCrewMap = {};
  Map<String, List> generateEmployeeCrewMap() {
    Map<String, List> result = {};
    var uniqueCrews = getAllUniqueCrews();
    //print(getAllUniqueCrews());
    for (int i = 0; i < uniqueCrews.length; i++) {
      result.putIfAbsent(uniqueCrews[i], () {
        return getEmployeesByCrewNumber(uniqueCrews[i]);
      });
    }

    return result;
  }

  String encodeWorkOrders() {
    return jsonEncode(workOrders);
  }

  bool isChecked = false;
  bool showCheckCircle = false;
  bool isMultiSelecting = false;
  List<bool> employeeIsMultiSelected = [];
  List<bool> generateEmployeeIsMultiSelected(int numRows) {
    return List<bool>.generate(numRows, (i) => false);
  }

  List<Employee> getEmployeesSelected() {
    List<Employee> result = [];

    for (int i = 0; i < employeeIsMultiSelected.length; i++) {
      if (employeeIsMultiSelected[i] == true) {
        result.add(employees[i]);
      }
    }

    for (var e in result) {
      print(e.fullname);
    }
    return result;
  }

  List<WorkOrder> filterWorkOrderListByFunction(String filter) {
    List<WorkOrder> result = [];

    for (var w in workOrders) {
      if (w.dbfarmingfunctionsname.trim() == filter) {
        result.add(w);
      }
    }
    result.sort(
        (a, b) => a.dbfarmingfunctionsname.compareTo(b.dbfarmingfunctionsname));
    return result;
  }

  bool showFilterDialog = false;
  List<String> getUniqueFunctionNames() {
    List<String> result = [];
    for (var w in workOrders) {
      if (!result.contains(w.dbfarmingfunctionsname.trim())) {
        result.add(w.dbfarmingfunctionsname.trim());
      }
    }
    return result;
  }

  String currentGroupByParameter = 'Function';
  List<String> groupByOptions = [];
  List<String> getGroupByOptions() {
    List<String> result = [];
    result.add('Function');
    result.add('Activity');
    result.add('Completion');
    result.add('Ranch');

    return result;
  }

  List<bool> groupByCheckCircles = [];
  List<bool> generateGroupByCheckCircles() {
    var result = List.generate(4, (index) => false);
    result[0] = true;
    return result;
  }

  List<String> filterByOptions = [];
  List<String> getFilterByOptions(String groupByParam) {
    if (groupByParam == 'Function') {
      return getFunctionOptions();
    } else if (groupByParam == 'Activity') {
      return getActivityOptions();
    } else if (groupByParam == 'Completion') {
      return getCompletionOptions();
    } else if (groupByParam == 'Ranch') {
      return getRanchOptions();
    }
    return [];
  }

  List<bool> filterByCheckCricles = [];
  List<bool> generateFilterByCheckCricles() {
    var result = List.generate(
        getFilterByOptions(currentGroupByParameter).length, (index) => true);
    //result[0] = true;
    return result;
  }

  List<String> getFunctionOptions() {
    List<String> result = [];
    for (var w in workOrders) {
      if (!result.contains(w.dbfarmingfunctionsname.trim())) {
        result.add(w.dbfarmingfunctionsname.trim());
      }
    }

    workOrders.sort(
        (a, b) => a.dbfarmingfunctionsname.compareTo(b.dbfarmingfunctionsname));
    return result;
  }

  List<String> getActivityOptions() {
    print('GET ACTIVITY OPTIONS');
    List<String> result = [];
    for (var w in workOrders) {
      if (!result.contains(w.WOName.trim())) {
        result.add(w.WOName.trim());
      }
    }
    workOrders.sort((a, b) => a.WOName.compareTo(b.WOName));
    result.sort();
    print(result);
    return result;
  }

  List<String> getCompletionOptions() {
    List<String> result = [];
    // for (var w in workOrders) {
    //   if (!result.contains(w.DB_Completed.toString())) {
    //     result.add(w.DB_Completed.toString());
    //   }
    // }
    result.add('Completed');
    result.add('Uncompleted');
    workOrders.sort((a, b) => a.DB_Completed.compareTo(b.DB_Completed));
    return result;
  }

  List<String> getRanchOptions() {
    List<String> result = [];
    for (var w in workOrders) {
      if (!result.contains(w.RANCHBLK.trim().substring(2, 4))) {
        result.add(w.RANCHBLK.trim().substring(2, 4));
      }
    }
    workOrders.sort((a, b) => a.RANCHBLK.compareTo(b.RANCHBLK));
    return result;
  }

  List<String> getSelectedFilterParameters() {
    // check to see what filter options are true
    List<String> filteredOptions = [];

    for (int i = 0; i < filterByCheckCricles.length; i++) {
      if (filterByCheckCricles[i] == true) {
        filteredOptions
            .add(getFilterByOptions(currentGroupByParameter)[i].trim());
      }
    }

    return filteredOptions;
  }

  String getDBCompletedHeader(String value) {
    return value == '0' ? 'Uncompleted' : 'Completed';
  }

  List<WorkOrder> filteredWorkOrders = [];
  Future<List<WorkOrder>> getFilteredWorkOrders() async {
    List<WorkOrder> filteredWorkOrders = [];
    if (currentGroupByParameter == 'Function') {
      for (var w in workOrders) {
        if (getSelectedFilterParameters()
            .contains(w.dbfarmingfunctionsname.trim())) {
          filteredWorkOrders.add(w);
        }
      }
      print(filteredWorkOrders.length);
      return filteredWorkOrders;
    } else if (currentGroupByParameter == 'Activity') {
      for (var w in workOrders) {
        if (getSelectedFilterParameters().contains(w.WOName.trim())) {
          filteredWorkOrders.add(w);
        }
      }
      print(filteredWorkOrders.length);
      return filteredWorkOrders;
    } else if (currentGroupByParameter == 'Completion') {
      for (var w in workOrders) {
        String param = '';
        if (w.DB_Completed.toString() == '0') {
          param = 'Uncompleted';
          if (getSelectedFilterParameters().contains(param)) {
            filteredWorkOrders.add(w);
          }
        } else if (w.DB_Completed.toString() == '1') {
          param = 'Completed';
          if (getSelectedFilterParameters().contains(param)) {
            filteredWorkOrders.add(w);
          }
        }

        // if (getSelectedFilterParameters().contains(w.DB_Completed.toString())) {
        //   filteredWorkOrders.add(w);
        // }
      }
      print(filteredWorkOrders.length);
      return filteredWorkOrders;
    } else if (currentGroupByParameter == 'Ranch') {
      for (var w in workOrders) {
        if (getSelectedFilterParameters()
            .contains(w.RANCHBLK.substring(2, 4))) {
          filteredWorkOrders.add(w);
        }
      }
      print(filteredWorkOrders.length);
      return filteredWorkOrders;
    } else if (currentGroupByParameter == 'Ranch - Block') {}
    return [];
  }

  String formatDate(String input) {
    var outputFormat = DateFormat('MM/dd/yyyy');
    if (outputFormat
        .format(DateTime.parse(input))
        .toString()
        .contains('1900')) {
      return '';
    }
    return outputFormat.format(DateTime.parse(input));
  }

  Widget HorizontalFilterList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 5.w,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (BuildContext context, int index) => SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Card(
                  child: Center(child: Text('FilterOption')),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isMultiEmployeeSelected() {
    return employeeIsMultiSelected.isNotEmpty ? true : false;
  }

  List<bool> isRowSelected = [];
  List<bool> isAbsent = [];
  bool isAllSelectedEnabled = false;
  bool isShowingCheckBoxColumn = false;

  void assignEmployeeStartTime(
      List<Employee> selectedEmployees, int cardIndex) {
    showModalBottomSheet<void>(
      elevation: 0.0,
      isDismissible: false,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.2),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setStartTimeState) {
        return SizedBox.expand(
            child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                color: Theme.of(context).cardColor),
            height: 580,
            width: 530,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  'Assign Start Time',
                  style: TextStyle(fontSize: 35),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Container(
                    width: 300,
                    height: 5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey)),
              ),
              Flexible(
                flex: 1,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: false,
                    itemCount: selectedEmployees.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                formatName(selectedEmployees[index].fullname)
                                    .trim(),
                                style: TextStyle(fontSize: 15)),
                            Text(
                              "${_duration.inHours}:${_duration.inMinutes.remainder(60)}",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.end,
                            ),
                            Builder(
                                builder: (BuildContext context) =>
                                    FloatingActionButton.small(
                                      onPressed: () async {
                                        var res = await showDurationPicker(
                                          context: context,
                                          initialTime:
                                              const Duration(seconds: 30),
                                          baseUnit: BaseUnit.minute,
                                          snapToMins: 5.0,
                                        );
                                        setStartTimeState(() {
                                          if (res != null) {
                                            _duration = res;
                                          }
                                        });
                                      },
                                      tooltip: 'Popup Duration Picker',
                                      child: const Icon(Icons.add),
                                    )),
                          ],
                        ),
                      );
                    }),
              ),
              FloatingActionButton.extended(
                  label: Text('Confirm'),
                  onPressed: () async {
                    // print(workOrderID);
                    // print(employeeID);
                    //   print(formatDurationtoDouble(_duration));
                    //   await EmployeesToWorkOrdersWS()
                    //       .assignEmployeeToWorkOrder(workOrderID, employeeID,
                    //           formatDurationtoDouble(_duration))
                    //       .then((value) => setState(() {
                    //             assigneeList.clear();
                    //             assignedWorkOrdersList.clear();
                    //             _iterateAssignees = iterateAssignees();
                    //             _iterateAssignedWorkOrders =
                    //                 iterateAssignedWorkOrders();
                    //             setState(() {});
                    //             Navigator.pop(context);
                    //           }));
                  }),
            ]),
          ),
        ));
      }),
    );
    return;
  }

  List<Employee> getSelectedRowsEmployeeIDs() {
    List<Employee> result = [];
    for (int i = 0; i < isRowSelected.length; i++) {
      if (isRowSelected[i] == true && isRowSelected[i] != null) {
        result.add(employees[i]);
      }
    }

    return result;
  }

  void _showShiftSchedulePicker(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  List<Widget> schedules = [
    Text("5 Hour Day"),
    Text("8 Hour Day"),
    Text("10 Hour Day"),
    Text("10-12 Hour Day w/ Waived Lunch"),
    Text("10-12 Hour Day No Waiver"),
  ];
  Widget RollCallTab() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: DataTable2(
          headingRowHeight: 32.0,
          dataRowHeight: 75.0,
          columnSpacing: 12,
          horizontalMargin: 12,
          dividerThickness: 10,
          bottomMargin: 10,
          minWidth: 900,
          showCheckboxColumn: isShowingCheckBoxColumn,
          sortArrowIcon: Icons.keyboard_arrow_up, // cust
          onSelectAll: (bool value) {
            // print('Pressed onSelectAll $value');
            setState(() {
              isAllSelectedEnabled = !isAllSelectedEnabled;
              isRowSelected.fillRange(
                  0, isRowSelected.length, isAllSelectedEnabled);
            });
          },
          columns: [
            DataColumn2(
                label: Text('Employee Name'), size: ColumnSize.S, numeric: false
                // example of fixed 1st row

                // onSort: (columnIndex, ascending) =>
                //     _sort<String>((d) => d.name, columnIndex, ascending),
                ),
            DataColumn2(
              label: Text('Employee ID'),
              size: ColumnSize.S,
              numeric: false,
              fixedWidth: 150,
              // onSort: (columnIndex, ascending) =>
              //     _sort<num>((d) => d.calories, columnIndex, ascending),
            ),
            DataColumn2(
              label: Text(
                'Start Time',
              ),
              size: ColumnSize.S,
              numeric: true,
              fixedWidth: 225,
              // onSort: (columnIndex, ascending) =>
              //     _sort<num>((d) => d.fat, columnIndex, ascending),
            ),
            DataColumn2(
              label: Text('Shift Schedule'),
              size: ColumnSize.S,
              numeric: true,
              fixedWidth: 275,
              // onSort: (columnIndex, ascending) =>
              //     _sort<num>((d) => d.carbs, columnIndex, ascending),
            ),
            DataColumn2(
              label: Text('Absent'),
              size: ColumnSize.S,
              numeric: true,
              fixedWidth: 100,
              // onSort: (columnIndex, ascending) =>
              //     _sort<num>((d) => d.protein, columnIndex, ascending),
            ),
          ],
          rows: List<DataRow>.generate(
              employees.length,
              (index) => DataRow(
                    color: isAbsent[index]
                        ? MaterialStateProperty.all(
                            (Colors.red.withOpacity(.1)))
                        : isRowSelected[index]
                            ? MaterialStateProperty.all(
                                (Colors.blue[500]).withOpacity(.1))
                            : MaterialStateProperty.all((Colors.white)),
                    cells: [
                      DataCell(InkWell(
                          onLongPress: () => setState(() {
                                isShowingCheckBoxColumn =
                                    !isShowingCheckBoxColumn;
                              }),
                          child: Text(
                              formatName(employees[index].fullname.trim())))),
                      DataCell(Text(
                        employees[index].employID,
                      )),
                      DataCell(TextFormField(
                        controller: rowCallStartTimeControllers[index],
                        readOnly: true,
                        onTap: () async {
                          setState(() {
                            isRowSelected[index] = true;
                          });

                          // assignEmployeeStartTime(
                          //     getSelectedRowsEmployeeIDs(), index);

                          TimeOfDay picked = await showTimePicker(
                            initialTime: TimeOfDay.now(),
                            context: context,
                            builder: (BuildContext context, Widget child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: false),
                                child: child,
                              );
                            },
                          ).whenComplete(() => null);

                          // print('Selected ' + picked.toString());
                          for (int i = 0; i < isRowSelected.length; i++) {
                            if (isRowSelected[i]) {
                              rowCallStartTimeControllers[i].text =
                                  picked.format(context);
                              setState(() {
                                isRowSelected[i] = false;
                              });
                            }
                          }

                          return;
                        },
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        //style: TextStyle(color: Colors.white, fontSize: 30),
                        decoration: InputDecoration(
                            //labelText: "Enter password",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              //  when the TextFormField in unfocused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              //  when the TextFormField in focused
                            ),
                            border: UnderlineInputBorder()),
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      )),
                      DataCell(TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        autofocus: false,
                        readOnly: true,
                        textAlign: TextAlign.right,
                        controller: rowCallShiftScheduleControllers[index],
                        onTap: () {
                          setState(() {
                            isRowSelected[index] = true;
                          });
                          showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 216,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  // The Bottom margin is provided to align the popup above the system navigation bar.
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  // Provide a background color for the popup.
                                  color: CupertinoColors.systemBackground
                                      .resolveFrom(context),
                                  // Use a SafeArea widget to avoid system overlaps.
                                  child: CupertinoPicker(
                                    children: schedules,
                                    onSelectedItemChanged: (value) {
                                      for (int i = 0;
                                          i < isRowSelected.length;
                                          i++) {
                                        if (isRowSelected[i]) {
                                          Text text = schedules[value];
                                          rowCallShiftScheduleControllers[i]
                                              .text = text.data.toString();
                                        }
                                      }
                                    },
                                    itemExtent: 25,
                                  ),
                                );
                              }).whenComplete(() {
                            // reset selection back to normal
                            setState(() {
                              isRowSelected.replaceRange(
                                  0,
                                  isRowSelected.length,
                                  isRowSelected.map((element) => false));
                            });
                          });
                        },
                        decoration: InputDecoration(
                            //labelText: "Enter password",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              //  when the TextFormField in unfocused
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              //  when the TextFormField in focused
                            ),
                            border: UnderlineInputBorder()),
                        maxLines: 1,
                      )),
                      DataCell(CheckboxListTile(
                        activeColor: Colors.red,
                        value: isAbsent[index],
                        onChanged: (newValue) {
                          setState(() {
                            isAbsent[index] = newValue;
                            if (isAbsent[index] == true) {
                              rowCallStartTimeControllers[index].clear();
                              rowCallShiftScheduleControllers[index].clear();
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .trailing, //  <-- leading Checkbox
                      )),
                    ],
                    selected: isRowSelected[index],
                    onSelectChanged: (value) {
                      // print('selected ' + employees[index].fullname);
                      setState(() {
                        isRowSelected[index] = value;
                      });
                      for (int i = 0; i < isRowSelected.length; i++) {
                        print('$i ${isRowSelected[i]}');
                      }
                    },
                  )),
        ));
  }

  bool isSuccessful = false;

  // futures to rebuild the screen when a farming group changes
  List<WorkOrder> currentFarmingGroupWorkOrders = [];
  Map<String, List<Planting>> currentFarmingGroupPlantings = {};
  Future<List<Employee>> _getWorkersByCurrentFarmingGroup() async {
    return await GetByFarmingGroupsWS()
        .getEmployeesByFarmingGroup(FarmingGroupNotifier.currentValue());
  }

  Future<List<WorkOrder>> _getWorkOrdersByCurrentFarmingGroup() async {
    currentFarmingGroupWorkOrders = await GetWorkOrderWS()
        .getCurrentWorkOrders(FarmingGroupNotifier.currentValue(), false);

    currentFarmingGroupPlantings = await _getPlantingsByWorkOrders(
        getCurrentWorkOrderDRBs(currentFarmingGroupWorkOrders));
    return currentFarmingGroupWorkOrders;
  }

  Future<Map<String, List<Planting>>> _getPlantingsByWorkOrders(
      List<String> workOrderDRBs) async {
    return await GetByFarmingGroupsWS()
        .getCurrentPlantingsByWorkOrders(workOrderDRBs);
  }

  List<String> getCurrentWorkOrderDRBs(
      List<WorkOrder> currentFarmingGroupWorkOrder) {
    List<String> result = [];
    for (WorkOrder wo in currentFarmingGroupWorkOrder) {
      result.add(wo.RANCHBLK);
    }

    return result;
  }

  @override
  void dispose() {
    workOrderColumnScrollController.dispose();
    employeeColumnScrollController.dispose();
    super.dispose();
  }

  Future _iterateAssignees;
  Future _iterateAssignedWorkOrders;
  Future _iteratePlantings;
  Widget DragAndDropContent() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 20.0,
            ),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            AppL10N.localStr["workOrders"],
                            style:
                                TextStyle(fontSize: 20, color: labelingColor),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: InkWell(
                              onTap: _showFilterDialog,
                              child: Icon(
                                Icons.sort,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isMultiSelecting == false) {
                                  isMultiSelecting = true;
                                } else {
                                  isMultiSelecting = false;
                                  promptWorkOrderSelection = false;
                                  hasSelectedAtLeastOneEmployee = false;
                                  animateConfirmationButton = false;
                                  employeeIsMultiSelected.fillRange(
                                      0, employeeIsMultiSelected.length, false);
                                }
                                showCheckCircle = !showCheckCircle;
                                print(showCheckCircle);
                                //getEmployeesSelected();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: AnimatedSwitcher(
                                  transitionBuilder: ((child, animation) =>
                                      ScaleTransition(
                                          child: child, scale: animation)),
                                  duration: const Duration(milliseconds: 500),
                                  child: showCheckCircle == true
                                      ? Draggable(
                                          dragAnchorStrategy:
                                              (Draggable<Object> _,
                                                      BuildContext __,
                                                      Offset ___) =>
                                                  const Offset(20, 20),
                                          data:
                                              '${getEmployeesSelected.toString()}E',
                                          child: Container(
                                              height: 31,
                                              width: 31,
                                              child: FloatingActionButton(
                                                mini: false,
                                                backgroundColor:
                                                    !hasSelectedAtLeastOneEmployee
                                                        ? Colors.grey.shade900
                                                        : Colors.blue.shade900,
                                                splashColor: Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    if (isMultiSelecting ==
                                                        false) {
                                                      isMultiSelecting = true;
                                                    } else {
                                                      isMultiSelecting = false;
                                                      promptWorkOrderSelection =
                                                          false;
                                                      hasSelectedAtLeastOneEmployee =
                                                          false;
                                                      animateConfirmationButton =
                                                          false;
                                                      employeeIsMultiSelected
                                                          .fillRange(
                                                              0,
                                                              employeeIsMultiSelected
                                                                  .length,
                                                              false);
                                                    }
                                                    showCheckCircle =
                                                        !showCheckCircle;
                                                    print(showCheckCircle);
                                                    //getEmployeesSelected();
                                                  });
                                                },
                                                hoverElevation: 1.5,
                                                shape: StadiumBorder(
                                                    side: BorderSide(
                                                        color:
                                                            !hasSelectedAtLeastOneEmployee
                                                                ? Colors.grey
                                                                : Colors.blue,
                                                        width: 4)),
                                                elevation: 1.5,
                                                child: Icon(
                                                  Icons.group_add,
                                                  size: 5.sp,

                                                  //color: _foregroundColor,
                                                ),
                                              )
                                              // Icon(
                                              //   Icons.person,
                                              //   color:
                                              //       draggableColor,
                                              // )
                                              ),
                                          feedback: FloatingActionButton(
                                            mini: false,
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            splashColor: Colors.black,
                                            onPressed: () {
                                              // logOutDialog(context);
                                            },
                                            hoverElevation: 1.5,
                                            shape: StadiumBorder(
                                                side: BorderSide(
                                                    color: Colors.blue,
                                                    width: 4)),
                                            elevation: 1.5,
                                            child: Icon(
                                              Icons.group_add,
                                              size: 10.sp,

                                              //color: _foregroundColor,
                                            ),
                                          ),
                                          onDragStarted: () {
                                            setState(() {
                                              isDraggingEmployee = true;
                                              // employeeIndexBeingDragged = index;
                                            });
                                          },
                                          onDragEnd: (details) {
                                            setState(() {
                                              isDraggingEmployee = false;
                                              employeeIndexBeingDragged = -1;
                                            });
                                          },
                                          onDragCompleted: () {
                                            setState(() {
                                              isDraggingEmployee = false;
                                              employeeIndexBeingDragged = -1;
                                            });
                                          },
                                          childWhenDragging: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  '',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          Colors.transparent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Icon(Icons.group_add,
                                          color: Colors.blue)),
                            ),
                          ),
                          Text(AppL10N.localStr["employees"],
                              style: TextStyle(
                                  fontSize: 20, color: labelingColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 20,
                  thickness: 2,
                  indent: 00,
                  endIndent: 0,
                  color: Colors.blue,
                ),
                //HorizontalFilterList(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Left Column
                        Expanded(
                            child: GroupedListView<dynamic, String>(
                          elements: workOrders,
                          groupBy: (element) =>
                              currentGroupByParameter == 'Function'
                                  ? element.dbfarmingfunctionsname.trim()
                                  : currentGroupByParameter == 'Activity'
                                      ? element.WOName.trim()
                                      : currentGroupByParameter == 'Completion'
                                          ? getDBCompletedHeader(
                                              element.DB_Completed.toString())
                                          : element.RANCHBLK.substring(2, 4),
                          controller: workOrderColumnScrollController,
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
                                      currentGroupByParameter == 'Ranch'
                                          ? 'Ranch $value'
                                          : value,
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
                              child: DragTarget(
                                onWillAccept: (data) {
                                  print(data.substring(data.length - 1));
                                  if (data.substring(data.length - 1) == 'E') {
                                    return true;
                                  }
                                  return false;
                                },
                                onAccept: (data) {
                                  setState(() {
                                    if (showCheckCircle) {
                                      assignMultipleEmployees(
                                          getEmployeesSelected(),
                                          element.DB_PRODWO.trim(),
                                          index);
                                    } else {
                                      assignSingleEmployee(
                                          data.substring(0, data.length - 1),
                                          element.DB_PRODWO.trim(),
                                          index,
                                          true);
                                      isSuccessful = true;
                                    }
                                  });
                                },
                                builder: (context, List<String> candidateData,
                                    rejectedData) {
                                  return Card(
                                    color: element.DB_FarmingActivity == 2
                                        ? Color.fromARGB(255, 255, 211, 238)
                                        : isRanchOnly(element.RANCHBLK) == true
                                            ? Color.fromARGB(255, 255, 251, 211)
                                            : element.DB_FarmingActivity == 4
                                                ? Colors.transparent
                                                : Color.fromARGB(
                                                    255, 221, 255, 213),
                                    elevation: isDraggingWorkOrder
                                        ? index ==
                                                getWorkOrderIndexBeingDragged()
                                            ? 5
                                            : 1
                                        : 3,
                                    shape: candidateData.isNotEmpty
                                        ? RoundedRectangleBorder(
                                            side: new BorderSide(
                                                color: Colors.blue, width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(4.0))
                                        : null,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: AppExpansionTile(
                                            initiallyExpanded: false,
                                            leading: Listener(
                                              onPointerMove:
                                                  (PointerMoveEvent event) {
                                                setState(() {
                                                  RenderBox render =
                                                      _workOrderListViewKey
                                                              .currentContext
                                                              ?.findRenderObject()
                                                          as RenderBox;

                                                  Offset position =
                                                      render.localToGlobal(
                                                          Offset.zero);
                                                  double topY = position.dy;
                                                  double bottomY =
                                                      topY + render.size.height;

                                                  // I/flutter ( 4972): x: 80.0, y: 80.0, height: 560.0, width: 360.0
                                                  const detectedRange = 25;
                                                  const moveDistance = 6;

                                                  if (event.position.dy <
                                                      topY + detectedRange) {
                                                    var to =
                                                        workOrderColumnScrollController
                                                                .offset -
                                                            moveDistance;
                                                    to = (to < 0) ? 0 : to;
                                                    workOrderColumnScrollController
                                                        .jumpTo(to);
                                                  }
                                                  if (event.position.dy >
                                                      bottomY - detectedRange) {
                                                    workOrderColumnScrollController
                                                        .jumpTo(
                                                            workOrderColumnScrollController
                                                                    .offset +
                                                                moveDistance);
                                                  }
                                                });
                                              },
                                              child: Draggable(
                                                data:
                                                    '${element.DB_PRODWO.trim()}W',
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.5),
                                                  child: Container(
                                                      height: 31,
                                                      width: 31,
                                                      child:
                                                          FloatingActionButton(
                                                        mini: false,
                                                        backgroundColor: Colors
                                                            .blue.shade900,
                                                        splashColor:
                                                            Colors.black,
                                                        hoverElevation: 1.5,
                                                        shape: StadiumBorder(
                                                            side: BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 4)),
                                                        elevation: 1.5,
                                                        child: Icon(
                                                          Icons.task,
                                                          size: 6.sp,
                                                        ),
                                                      )),
                                                ),
                                                feedback: FloatingActionButton(
                                                  mini: false,
                                                  backgroundColor:
                                                      Colors.blue.shade900,
                                                  splashColor: Colors.black,
                                                  onPressed: () {
                                                    // logOutDialog(context);
                                                  },
                                                  hoverElevation: 1.5,
                                                  shape: StadiumBorder(
                                                      side: BorderSide(
                                                          color: Colors.blue,
                                                          width: 4)),
                                                  elevation: 1.5,
                                                  child: Icon(
                                                    Icons.task,
                                                    size: 10.sp,

                                                    //color: _foregroundColor,
                                                  ),
                                                ),
                                                onDragStarted: () {
                                                  setState(() {
                                                    isDraggingWorkOrder = true;
                                                    workOrderIndexBeingDragged =
                                                        index;
                                                  });
                                                },
                                                onDragEnd: (details) {
                                                  setState(() {
                                                    isDraggingWorkOrder = false;
                                                    workOrderIndexBeingDragged =
                                                        -1;
                                                  });
                                                },
                                                onDragCompleted: () {
                                                  setState(() {
                                                    isDraggingWorkOrder = false;
                                                    workOrderIndexBeingDragged =
                                                        -1;
                                                  });
                                                },
                                                childWhenDragging: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        '',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .transparent),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${element.WOName.trim()} ',
                                                    style: TextStyle(
                                                        color: labelingColor)),
                                                // Text(
                                                //     '${workOrders[index].WOName.trim()} '),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    '${formatDRB(element.RANCHBLK.trim())}',
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: labelingColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            subtitle: getPlantingsByBlock(
                                                        workOrders[index]
                                                            .RANCHBLK)
                                                    .isEmpty
                                                ? SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          '${getPlantingByBlock(workOrders[index].RANCHBLK)}'),
                                                      Text('First Planting Date: ' +
                                                          formatDate(getPlantingsByBlock(
                                                                  workOrders[
                                                                          index]
                                                                      .RANCHBLK)
                                                              .first
                                                              .plantingDetail
                                                              .plantingDate)),
                                                      Text('Estimated Harvest Date: ' +
                                                          formatDate(getPlantingsByBlock(
                                                                  workOrders[
                                                                          index]
                                                                      .RANCHBLK)
                                                              .first
                                                              .plantingDetail
                                                              .currHarvestDate)),
                                                    ],
                                                  ),
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 45.0,
                                                    right: 45.0,
                                                    bottom: 5.0),
                                                child: ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount: assigneeList[
                                                            element.DB_PRODWO]
                                                        .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index2) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Text(
                                                                    '${formatName(assigneeList[element.DB_PRODWO][index2].fullname.trim())} ',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                    '(${assigneeList[element.DB_PRODWO][index2].DBCHRS} hrs)',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        BackdropFilter(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(200)),
                                          ),
                                          filter: ImageFilter.blur(
                                            sigmaX: isDraggingWorkOrder
                                                ? index ==
                                                        getWorkOrderIndexBeingDragged()
                                                    ? 0
                                                    : 3
                                                : 0.0,
                                            sigmaY: isDraggingWorkOrder
                                                ? index ==
                                                        getWorkOrderIndexBeingDragged()
                                                    ? 0
                                                    : 3
                                                : 0.0,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )),

                        // Right Column
                        Expanded(
                            child: GroupedListView<dynamic, String>(
                          elements: employees,
                          groupBy: (element) => element.crewID,
                          //key: _employeeListViewKey,
                          controller: employeeColumnScrollController,

                          useStickyGroupSeparators: true,
                          stickyHeaderBackgroundColor: scaffoldBackgroundColor,
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
                              child: DragTarget(
                                builder: (context, List<String> candidateData,
                                    rejectedData) {
                                  return Card(
                                    color: employees[index]
                                                .crewID
                                                .contains('145') ==
                                            true
                                        ? Colors.lightBlueAccent
                                        : Colors.brown,
                                    elevation: employeeIsMultiSelected[index] ==
                                            true
                                        ? 5
                                        : isDraggingEmployee
                                            ? index ==
                                                    getEmployeeIndexBeingDragged()
                                                ? 5
                                                : 1
                                            : 2,
                                    shape: candidateData.isNotEmpty
                                        ? RoundedRectangleBorder(
                                            side: new BorderSide(
                                                color: Colors.blue, width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(4.0))
                                        : null,
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: AppExpansionTile(
                                            initiallyExpanded: false,
                                            leading: AnimatedSwitcher(
                                              transitionBuilder:
                                                  ((child, animation) =>
                                                      ScaleTransition(
                                                          child: child,
                                                          scale: animation)),
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              child: showCheckCircle
                                                  ? Checkbox(
                                                      side: BorderSide(
                                                          width: 2,
                                                          color: accentColor),
                                                      checkColor: Colors.white,
                                                      value:
                                                          employeeIsMultiSelected[
                                                              index],
                                                      shape: CircleBorder(),
                                                      onChanged: (bool value) {
                                                        print(
                                                            'SELECTED $index to $value ${employeeIsMultiSelected.length}');
                                                        setState(() {
                                                          employeeIsMultiSelected[
                                                              index] = value;
                                                          isChecked = value;
                                                          if (value == true) {
                                                            setState(() {
                                                              hasSelectedAtLeastOneEmployee =
                                                                  true;
                                                            });
                                                          }
                                                        });
                                                      },
                                                    )
                                                  : Listener(
                                                      onPointerMove:
                                                          (PointerMoveEvent
                                                              event) {
                                                        setState(() {
                                                          RenderBox render =
                                                              _workOrderListViewKey
                                                                      .currentContext
                                                                      ?.findRenderObject()
                                                                  as RenderBox;

                                                          Offset position = render
                                                              .localToGlobal(
                                                                  Offset.zero);
                                                          double topY =
                                                              position.dy;
                                                          double bottomY =
                                                              topY +
                                                                  render.size
                                                                      .height;

                                                          // I/flutter ( 4972): x: 80.0, y: 80.0, height: 560.0, width: 360.0
                                                          const detectedRange =
                                                              25;
                                                          const moveDistance =
                                                              6;

                                                          if (event
                                                                  .position.dy <
                                                              topY +
                                                                  detectedRange) {
                                                            var to =
                                                                workOrderColumnScrollController
                                                                        .offset -
                                                                    moveDistance;
                                                            to = (to < 0)
                                                                ? 0
                                                                : to;
                                                            workOrderColumnScrollController
                                                                .jumpTo(to);
                                                          }
                                                          if (event
                                                                  .position.dy >
                                                              bottomY -
                                                                  detectedRange) {
                                                            workOrderColumnScrollController.jumpTo(
                                                                workOrderColumnScrollController
                                                                        .offset +
                                                                    moveDistance);
                                                          }
                                                        });
                                                      },
                                                      child: Draggable(
                                                        data:
                                                            '${employees[index].employID.trim()}E',
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.5),
                                                          child: Container(
                                                              height: 31,
                                                              width: 31,
                                                              child:
                                                                  FloatingActionButton(
                                                                mini: false,
                                                                backgroundColor:
                                                                    Colors.blue
                                                                        .shade900,
                                                                splashColor:
                                                                    Colors
                                                                        .black,
                                                                hoverElevation:
                                                                    1.5,
                                                                shape: StadiumBorder(
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .blue,
                                                                        width:
                                                                            4)),
                                                                elevation: 1.5,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 6.sp,
                                                                ),
                                                              )),
                                                        ),
                                                        feedback:
                                                            FloatingActionButton(
                                                          mini: false,
                                                          backgroundColor:
                                                              Colors.blue
                                                                  .shade900,
                                                          splashColor:
                                                              Colors.black,
                                                          onPressed: () {
                                                            // logOutDialog(context);
                                                          },
                                                          hoverElevation: 1.5,
                                                          shape: StadiumBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 4)),
                                                          elevation: 1.5,
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 10.sp,

                                                            //color: _foregroundColor,
                                                          ),
                                                        ),
                                                        onDragStarted: () {
                                                          setState(() {
                                                            isDraggingEmployee =
                                                                true;
                                                            employeeIndexBeingDragged =
                                                                index;
                                                          });
                                                        },
                                                        onDragEnd: (details) {
                                                          setState(() {
                                                            isDraggingEmployee =
                                                                false;
                                                            employeeIndexBeingDragged =
                                                                -1;
                                                          });
                                                        },
                                                        onDragCompleted: () {
                                                          setState(() {
                                                            isDraggingEmployee =
                                                                false;
                                                            employeeIndexBeingDragged =
                                                                -1;
                                                          });
                                                        },
                                                        childWhenDragging:
                                                            Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                '',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .transparent),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${formatName(employees[index].fullname.trim())}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: employees[index]
                                                                  .crewID
                                                                  .contains(
                                                                      '145') ==
                                                              true
                                                          ? Colors.black
                                                          : Colors.white,
                                                    )),
                                                Text(
                                                    '${employees[index].employID.trim()}',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: employees[index]
                                                                    .crewID
                                                                    .contains(
                                                                        '145') ==
                                                                true
                                                            ? Colors.black
                                                            : Colors.white)),
                                              ],
                                            ),
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 45.0,
                                                    right: 45.0,
                                                    bottom: 5.0),
                                                child: ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        assignedWorkOrdersList[
                                                                employees[index]
                                                                    .employID]
                                                            .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index2) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                text: TextSpan(
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  text:
                                                                      '${assignedWorkOrdersList[employees[index].employID][index2].DBFarmingFunctionsDesc.trim()}',
                                                                  children: <
                                                                      TextSpan>[
                                                                    TextSpan(
                                                                        text: getWorkOrderStatus(assignedWorkOrdersList[employees[index].employID][index2]
                                                                            .DB_Completed),
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          color:
                                                                              Colors.green,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    '${formatDRB(getWorkOrderByWorkOrderID(assignedWorkOrdersList[employees[index].employID][index2].DB_PRODWO.trim()).RANCHBLK.trim())}',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                text: TextSpan(
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  text:
                                                                      '(${assignedWorkOrdersList[employees[index].employID][index2].DBCHRS} hrs) ',
                                                                  children: <
                                                                      TextSpan>[
                                                                    TextSpan(
                                                                        text: getWorkOrderStatus(assignedWorkOrdersList[employees[index].employID][index2]
                                                                            .DB_Completed),
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          color:
                                                                              Colors.green,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        BackdropFilter(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(200)),
                                          ),
                                          filter: ImageFilter.blur(
                                            sigmaX: isDraggingEmployee
                                                ? index == getEmployeeIndexBeingDragged() ||
                                                        employeeIsMultiSelected[
                                                                index] ==
                                                            true
                                                    ? 0
                                                    : 3
                                                : 0.0,
                                            sigmaY: isDraggingEmployee
                                                ? index == getEmployeeIndexBeingDragged() ||
                                                        employeeIsMultiSelected[
                                                                index] ==
                                                            true
                                                    ? 0
                                                    : 3
                                                : 0.0,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                onWillAccept: (data) {
                                  print(data.substring(data.length - 1));
                                  if (data.substring(data.length - 1) == 'W') {
                                    return true;
                                  }
                                  return false;
                                },
                                onAccept: (data) {
                                  setState(() {
                                    assignSingleEmployee(
                                        employees[index].employID.trim(),
                                        data.substring(0, data.length - 1),
                                        index,
                                        false);

                                    print(data.substring(0, data.length - 1) +
                                        ' dropped to ' +
                                        '${employees[index].employID.trim()}');

                                    isSuccessful = true;
                                  });
                                },
                              ),
                            );
                          },
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
              width: MediaQuery.of(context).size.width,
              height:
                  !showFilterDialog ? 0.0 : MediaQuery.of(context).size.height,
              top: showFilterDialog ? 0.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.fastOutSlowIn,
              //duration: const Duration(milliseconds: 100),
              child: ClipRRect(
                child: Container(
                  //width: MediaQuery.of(context).size.width / 2,
                  child: BackdropFilter(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.0),
                          borderRadius: BorderRadius.circular(1)),
                    ),
                    filter: ImageFilter.blur(
                      sigmaX: 10.0,
                      sigmaY: 10.0,
                    ),
                  ),
                ),
              )),
          AnimatedPositioned(
            width: MediaQuery.of(context).size.width,
            height:
                !showFilterDialog ? 0.0 : MediaQuery.of(context).size.height,
            top: showFilterDialog ? 0.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastOutSlowIn,
            //duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group By',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: ClipRRect(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0),
                                ),
                                color: Colors.black,
                              ),
                              height: 3,
                              width: 150,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        // divider
                        Padding(
                          padding: EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: ClipRRect(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0),
                                ),
                                color: Colors.black,
                              ),
                              height: 3,
                              width: 150,
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width / 4,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: false,
                              itemCount:
                                  getFilterByOptions(currentGroupByParameter)
                                      .length,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  children: [
                                    Checkbox(
                                      side: BorderSide(
                                          width: 2, color: Colors.blue),
                                      checkColor: Colors.white,
                                      activeColor: Colors.blue,
                                      value: filterByCheckCricles[index],
                                      shape: CircleBorder(),
                                      onChanged: (value) {
                                        setState(() async {
                                          // filterByCheckCricles.fillRange(
                                          //     0,
                                          //     filterByCheckCricles.length,
                                          //     false);
                                          filterByCheckCricles[index] = value;
                                          print(getSelectedFilterParameters());

                                          filteredWorkOrders =
                                              await getFilteredWorkOrders();
                                          for (var f in filteredWorkOrders)
                                            print(f.WOName.trim());
                                        });

                                        return;
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          getFilterByOptions(
                                              currentGroupByParameter)[index],
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                );
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    workOrders = widget.workOrders;
    employees = widget.employees;
    plantings = widget.plantings;
    assigneeList = widget.assignes;
    assignedWorkOrdersList = widget.assignedWorkOrders;

    groupByOptions = getGroupByOptions();
    groupByCheckCircles = generateGroupByCheckCircles();
    filterByCheckCricles = generateFilterByCheckCricles();
    // _iterateAssignees = iterateAssignees();
    // _iterateAssignedWorkOrders = iterateAssignedWorkOrders();
    isRowSelected = List.generate(employees.length, (index) => false);
    isAbsent = List.generate(employees.length, (index) => false);
    expansionTileKeys = generateExpansionTileKeys(workOrders.length);
    rowCallStartTimeControllers =
        generateRowCallStartTimeControllers(employees.length);
    rowCallShiftScheduleControllers =
        generateRowCallShiftScheduleControllers(employees.length);
    employeeCrewMap = generateEmployeeCrewMap();
    crewDescsByCrewID = generateCrewDescByCrewID();
    employeeIsMultiSelected = generateEmployeeIsMultiSelected(employees.length);
  }

  int currentPageIndex = 0;
  String appTitle = 'Employee Timekeeping';
  bool isNavigationButtonExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: ValueListenableBuilder(
        //     valueListenable: _farmingGroupNotifier,
        //     builder: (BuildContext context, String value, Widget child) {
        //       buildScreen();
        //       return DragAndDropContent2();
        //     })
        body: Padding(
      padding: EdgeInsets.only(left: 10.0.w),
      child: DragAndDropContent(),
    ));
  }
}
// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables
