// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:prodwo_timesheet/tools/format.dart';
import 'package:prodwo_timesheet/tools/localizations.dart';

class HomeTab extends StatefulWidget {
  final SidebarXController controller;
  final List<Employee> employees;
  final Map<String, List<Employee>> attendanceList;
  final Map<String, List<WorkOrder>> workOrdersList;
  final Map<String, List<String>> farmingGroups;
  final String currentFarmingGroup;
  const HomeTab({
    Key key,
    this.employees,
    this.attendanceList,
    this.workOrdersList,
    this.controller,
    this.farmingGroups,
    this.currentFarmingGroup,
  }) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> ranches = [];
  @override
  void initState() {
    // TODO: implement initState
    print(widget.currentFarmingGroup);
    super.initState();
    ranches = widget.farmingGroups[widget.currentFarmingGroup];
    print(widget.farmingGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 3.0.w, bottom: 3.w, left: 13.w, right: 2.h),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OpenWorkOrdersTile(
                  numOfOpenWorkOrders: widget.workOrdersList['Open'].length,
                  controller: widget.controller,
                ),
                CompletedWorkOrdersTile(
                    numOfCompletedWorkOrders:
                        widget.workOrdersList['Completed'].length),
                WorkOrdersPendingAssignmentTile(
                  numOfWorkOrdersPendingAssignment:
                      widget.workOrdersList['Pending'].length,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AttendanceTile(
                  tileName: AppL10N.localStr["attendance"],
                  employees: widget.employees,
                  attendance: widget.attendanceList,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    EquipmentTile(
                      ranches: widget.farmingGroups[widget.currentFarmingGroup],
                      currentFarmingGroup: widget.currentFarmingGroup,
                    ),
                    SizedBox(
                      width: 2.5.h,
                    ),
                    MapTile(
                      controller: widget.controller,
                    ),
                    SizedBox(
                      width: 2.5.h,
                    ),
                    Column(
                      children: [
                        SubmitTimesheetsTile(
                          tileName: AppL10N.localStr["submitTimesheets"],
                        ),
                        SizedBox(
                          height: 5.w,
                        ),
                        SubmitTimesheetsTile(
                          tileName: AppL10N.localStr["addToQueue"],
                        )
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OpenWorkOrdersTile extends StatefulWidget {
  final int numOfOpenWorkOrders;
  final SidebarXController controller;
  const OpenWorkOrdersTile({Key key, this.numOfOpenWorkOrders, this.controller})
      : super(key: key);

  @override
  _OpenWorkOrdersTileState createState() => _OpenWorkOrdersTileState();
}

class _OpenWorkOrdersTileState extends State<OpenWorkOrdersTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        //widget.controller.setExtended(true);
        widget.controller.selectIndex(1);
      },
      child: Container(
        decoration: BoxDecoration(
            color: primaryColor,
            border: Border.all(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        height: 27.w,
        width: 20.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.numOfOpenWorkOrders.toString(),
                style: TextStyle(fontSize: 18.sp, color: Colors.white)),
            SizedBox(
              height: 1.w,
            ),
            Text(
              AppL10N.localStr["openWorkOrders"],
              style: TextStyle(fontSize: 6.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedWorkOrdersTile extends StatefulWidget {
  final int numOfCompletedWorkOrders;
  const CompletedWorkOrdersTile({Key key, this.numOfCompletedWorkOrders})
      : super(key: key);

  @override
  _CompletedWorkOrdersTileState createState() =>
      _CompletedWorkOrdersTileState();
}

class _CompletedWorkOrdersTileState extends State<CompletedWorkOrdersTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 27.w,
      width: 20.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.numOfCompletedWorkOrders.toString(),
              style: TextStyle(fontSize: 18.sp, color: Colors.white)),
          SizedBox(
            height: 1.w,
          ),
          Text(
            AppL10N.localStr["completedWorkOrders"],
            style: TextStyle(fontSize: 6.sp, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WorkOrdersPendingAssignmentTile extends StatefulWidget {
  final int numOfWorkOrdersPendingAssignment;
  const WorkOrdersPendingAssignmentTile(
      {Key key, this.numOfWorkOrdersPendingAssignment})
      : super(key: key);

  @override
  _WorkOrdersPendingAssignmentTileState createState() =>
      _WorkOrdersPendingAssignmentTileState();
}

class _WorkOrdersPendingAssignmentTileState
    extends State<WorkOrdersPendingAssignmentTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 27.w,
      width: 20.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.numOfWorkOrdersPendingAssignment.toString(),
              style: TextStyle(fontSize: 18.sp, color: Colors.white)),
          SizedBox(
            height: 1.w,
          ),
          Text(
            AppL10N.localStr["pendingWorkOrders"],
            style: TextStyle(fontSize: 6.sp, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AttendanceTile extends StatefulWidget {
  final String tileName;
  final List<Employee> employees;
  final Map<String, List<Employee>> attendance;
  const AttendanceTile(
      {Key key, this.tileName, this.employees, this.attendance})
      : super(key: key);

  @override
  _AttendanceTileState createState() => _AttendanceTileState();
}

class _AttendanceTileState extends State<AttendanceTile> {
  // ignore: prefer_final_fields
  Widget _verticalDivider = VerticalDivider(
    color: accentColor,
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
      statusColor = Colors.white;
    }
    return Text(
      "\u2022 ",
      style: TextStyle(color: statusColor, fontSize: 14.sp),
    );
  }

  bool isOnMealPeriod(
      Employee employee, Map<String, List<Employee>> attendance) {
    if (attendance['Meal Period'].contains(employee)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 56.w,
      width: 65.h,
      child: Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tileName,
                    style: TextStyle(fontSize: 8.sp, color: Colors.white)),
              ],
            ),
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    // Active
                    Flexible(
                      child: Container(
                        child: DataTable2(
                            dividerThickness: 0,
                            headingTextStyle:
                                TextStyle(color: Colors.white, fontSize: 6.sp),
                            dataTextStyle: TextStyle(
                                color: Colors.white, fontSize: 4.5.sp),
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            //minWidth: 600,
                            // ignore: prefer_const_literals_to_create_immutables
                            columns: [
                              DataColumn(
                                label: Text(AppL10N.localStr["present"]),
                              ),
                            ],
                            rows: widget.attendance['Active']
                                .map((index) => DataRow(cells: [
                                      DataCell(Row(
                                        children: [
                                          Align(
                                            child: statusIndicator(
                                                !isOnMealPeriod(index,
                                                        widget.attendance)
                                                    ? 1
                                                    : 2),
                                            alignment: Alignment.topCenter,
                                          ),
                                          Flexible(
                                            child: Text(
                                              '${index.fullname.toTitleCase()}',
                                            ),
                                          ),
                                        ],
                                      )),
                                    ]))
                                .toList()),
                      ),
                    ),
                    _verticalDivider,
                    // Meal Period
                    // Flexible(
                    //   child: Container(
                    //     child: DataTable2(
                    //         dividerThickness: 0,
                    //         headingTextStyle:
                    //             TextStyle(color: Colors.white, fontSize: 6.sp),
                    //         dataTextStyle: TextStyle(
                    //             color: Colors.white, fontSize: 4.5.sp),
                    //         columnSpacing: 12,
                    //         horizontalMargin: 12,
                    //         //minWidth: 600,
                    //         // ignore: prefer_const_literals_to_create_immutables
                    //         columns: [
                    //           DataColumn(
                    //             label: Text('Meal Period'),
                    //           ),
                    //         ],
                    //         rows: widget.attendance['Meal Period']
                    //             .map((index) => DataRow(cells: [
                    //                   DataCell(Text(
                    //                       '${index.fullname.toTitleCase()}')),
                    //                 ]))
                    //             .toList()),
                    //   ),
                    // ),
                    // _verticalDivider,
                    // Shift Completed
                    Flexible(
                      child: Container(
                        child: DataTable2(
                            dividerThickness: 0,
                            headingTextStyle:
                                TextStyle(color: Colors.white, fontSize: 6.sp),
                            dataTextStyle: TextStyle(
                                color: Colors.white, fontSize: 4.5.sp),
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            // minWidth: 600,
                            // ignore: prefer_const_literals_to_create_immutables
                            columns: [
                              DataColumn(
                                label: Text(AppL10N.localStr["shiftCompleted"]),
                              ),
                            ],
                            rows: widget.attendance['Shift Completed']
                                .map((index) => DataRow(cells: [
                                      DataCell(Row(
                                        children: [
                                          Align(
                                            child: statusIndicator(3),
                                            alignment: Alignment.topCenter,
                                          ),
                                          Flexible(
                                            child: Text(
                                                '${index.fullname.toTitleCase()}'),
                                          ),
                                        ],
                                      )),
                                    ]))
                                .toList()),
                      ),
                    ),
                    _verticalDivider,
                    // Absent
                    Flexible(
                      child: Container(
                        child: DataTable2(
                            dividerThickness: 0,
                            headingTextStyle:
                                TextStyle(color: Colors.white, fontSize: 6.sp),
                            dataTextStyle: TextStyle(
                                color: Colors.white, fontSize: 4.5.sp),
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            //minWidth: 600,
                            // ignore: prefer_const_literals_to_create_immutables
                            columns: [
                              DataColumn2(
                                label: Text(AppL10N.localStr["absent"]),
                                size: ColumnSize.M,
                              ),
                            ],
                            rows: widget.attendance['Absent']
                                .map((index) => DataRow(cells: [
                                      DataCell(Row(
                                        children: [
                                          Align(
                                            child: statusIndicator(0),
                                            alignment: Alignment.topCenter,
                                          ),
                                          Flexible(
                                            child: Text(
                                                '${index.fullname.toTitleCase()}'),
                                          ),
                                        ],
                                      )),
                                    ]))
                                .toList()),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EquipmentTile extends StatefulWidget {
  final List<String> ranches;
  final String currentFarmingGroup;
  const EquipmentTile({Key key, this.ranches, this.currentFarmingGroup})
      : super(key: key);

  @override
  _EquipmentTileState createState() => _EquipmentTileState();
}

class _EquipmentTileState extends State<EquipmentTile> {
  double dotsIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 27.w,
      width: 30.h,
      child: Container(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10N.localStr["equipment"],
                      style: TextStyle(fontSize: 8.sp, color: Colors.white)),
                ],
              ),
            ),
            Column(
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    enlargeFactor: .5,
                    onPageChanged: (index, reason) {
                      setState(() {
                        dotsIndex = index.toDouble();
                      });
                    },
                  ),
                  itemCount: widget.ranches.length,
                  itemBuilder: (context, i, realIndex) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        //color: Colors.red,
                        //margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 4.75.sp),
                                  child: Text(
                                    '${AppL10N.localStr["ranch"]} ${widget.ranches[i]}',
                                    style: TextStyle(
                                        fontSize: 8.0.sp, color: accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
                ClipRect(
                  child: FittedBox(
                    child: DotsIndicator(
                      dotsCount: widget.ranches.length,
                      position: dotsIndex.toDouble(),
                      decorator: DotsDecorator(
                          color: Colors.grey, // Inactive color
                          activeColor: accentColor,
                          activeSize: Size(5.sp, 5.sp)),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapTile extends StatefulWidget {
  final String mapStyle;
  final SidebarXController controller;
  const MapTile({Key key, this.mapStyle, this.controller}) : super(key: key);

  @override
  _MapTileState createState() => _MapTileState();
}

class _MapTileState extends State<MapTile> {
  GoogleMapController _mapController;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 27.w,
      width: 18.h,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: GoogleMap(
            mapType: MapType.satellite,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              //_mapController.setMapStyle(getMapTheme());
            },
            onLongPress: (argument) {
              setState(() {
                widget.controller.selectIndex(1);
              });
              return;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(36.68581838714097, -121.71202104538678),
              zoom: 10.0,
            )),
      ),
    );
  }
}

class SubmitTimesheetsTile extends StatefulWidget {
  final String tileName;
  const SubmitTimesheetsTile({Key key, this.tileName}) : super(key: key);

  @override
  _SubmitTimesheetsTileState createState() => _SubmitTimesheetsTileState();
}

class _SubmitTimesheetsTileState extends State<SubmitTimesheetsTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      height: 10.w,
      width: 12.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              widget.tileName,
              style: TextStyle(fontSize: 8.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
