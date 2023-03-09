// @dart=2.9
// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables

// make it a webservice call

import 'package:flutter/material.dart';
import 'package:prodwo_timesheet/models/assigned_work_order.dart';
import 'package:prodwo_timesheet/models/assignee.dart';
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/employee_time.dart';
import 'package:prodwo_timesheet/models/planting.dart';
import 'package:prodwo_timesheet/models/position_entry.dart';
import 'package:prodwo_timesheet/models/work_order.dart';
import 'package:prodwo_timesheet/preferences/preferences.dart';
import 'package:prodwo_timesheet/providers/farming_group_provider.dart';
import 'package:prodwo_timesheet/providers/selected_employee_index_provider.dart';
import 'package:prodwo_timesheet/screens/drag_and_drop_tab.dart';
import 'package:prodwo_timesheet/screens/employees_tab.dart';
import 'package:prodwo_timesheet/screens/home_tab.dart';
import 'package:prodwo_timesheet/screens/login_screen.dart';
import 'package:prodwo_timesheet/screens/map_tab.dart';
import 'package:prodwo_timesheet/screens/work_orders_tab.dart';
import 'package:prodwo_timesheet/services/serivce_locator.dart';
import 'package:prodwo_timesheet/services/webservices/get_by_user.dart';
import 'package:prodwo_timesheet/services/webservices/get_current_work_orders.dart';
import 'package:prodwo_timesheet/services/webservices/get_employee_position.dart';
import 'package:prodwo_timesheet/services/webservices/get_employee_time.dart';
import 'package:prodwo_timesheet/services/webservices/get_by_farming_group.dart';
import 'package:prodwo_timesheet/services/webservices/get_employees_by_work_order.dart';
import 'package:prodwo_timesheet/services/webservices/get_work_orders_by_employee.dart';
import 'package:prodwo_timesheet/tools/colors.dart';
import 'package:prodwo_timesheet/tools/globals.dart';
import 'package:prodwo_timesheet/tools/localizations.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toggle_switch/toggle_switch.dart';

String pageTitle;
String _currentFarmingGroup;
ValueNotifier<String> _farmingGroupNotifier;
ValueNotifier<int> _selectedEmployeeIndex;
bool light = true;

void main() {
  pageTitle = AppL10N.localStr["home"];
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(LoginScreen());
}

class MyApp extends StatefulWidget {
  final Map<String, List<String>> farmingGroups;
  MyApp({Key key, this.farmingGroups}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) => setState(() => _locale = locale);
  final _controller = SidebarXController(
    selectedIndex: 0,
    extended: false,
  );

  final _key = GlobalKey<ScaffoldState>();

  void updatePageTitle(int index) {
    pageTitle = _getPageTitle(index);
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Map';
      case 2:
        return 'Drag & Drop';
      case 3:
        return 'Employees';
      case 4:
        return 'Custom iconWidget';
      case 5:
        return 'Profile';
      case 6:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems(List<String> menu) {
    print('Calling buildDropdownMenuItems');
    print(menu);
    List<DropdownMenuItem<String>> items = List();
    for (String li in menu) {
      items.add(
        DropdownMenuItem(
          value: li,
          child: Text(
            li,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            //overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return items;
  }

  @override
  void initState() {
    _currentFarmingGroup = widget.farmingGroups.keys.first;
    _farmingGroupNotifier = FarmingGroupNotifier.ret(_currentFarmingGroup);
    _selectedEmployeeIndex = SelectedEmployeeNotifier.ret(0);
    AppL10N().load();
    // TODO: implement initState
    super.initState();
    pageTitle = AppL10N.localStr["home"];
    print(Preferences.currentUserID);
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'PRLS Companion',
        locale: _locale,
        supportedLocales: [const Locale("en", "US"), const Locale("es", "MX")],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor,
          canvasColor: canvasColor,
          scaffoldBackgroundColor: scaffoldBackgroundColor,
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              key: _key,
              appBar: AppBar(
                backgroundColor: canvasColor,
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      // light = !light;
                      // print(light);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (route) => false);
                    },
                  )
                ],
                title: DropdownButton(
                  alignment: AlignmentDirectional.center,
                  value: _currentFarmingGroup,
                  items: buildDropdownMenuItems(
                      widget.farmingGroups.keys.toList()),
                  underline: SizedBox(
                    height: 0,
                  ),
                  //underline: SizedBox(),
                  onChanged: (value) {
                    setState(() {
                      _currentFarmingGroup = value;
                      print('changed farming group to $_currentFarmingGroup');
                      FarmingGroupNotifier.notify(_currentFarmingGroup);
                      refresh();
                      _farmingGroupNotifier.value = _currentFarmingGroup;
                      if (_controller.selectedIndex == 3) {
                        // reset the selected index value in the list
                        SelectedEmployeeNotifier.reset();
                      }
                    });
                    setState(() {});
                  },
                ),
                centerTitle: true,
                leadingWidth: 0,
              ),
              body: Stack(
                children: [
                  Center(
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(left: 0.0.w),
                        child: ValueListenableBuilder(
                            valueListenable: _farmingGroupNotifier,
                            builder: (BuildContext context, String value,
                                Widget child) {
                              return _DisplayTab(
                                controller: _controller,
                                currentFarmingGroup: _currentFarmingGroup,
                                farmingGroups: widget.farmingGroups,
                              );
                            }),
                      ),
                    ),
                  ),
                  NavigationSideBar(
                      controller: _controller, notifyParent: refresh),
                ],
              ),
            );
          },
        ),
        //home: LoginScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => MyApp(),
        },
      );
    });
  }
}

class NavigationSideBar extends StatefulWidget {
  final String appBarTitle;
  final Function() notifyParent;
  const NavigationSideBar({
    Key key,
    SidebarXController controller,
    this.appBarTitle,
    this.notifyParent,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  State<NavigationSideBar> createState() => _NavigationSideBarState();
}

class _NavigationSideBarState extends State<NavigationSideBar> {
  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget._controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 50,
          // child: Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Image.asset('assets/images/avatar.png'),
          // ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: AppL10N.localStr["home"],
          onTap: () {
            Globals.changeInteger(0);
            setState(() {
              pageTitle = AppL10N.localStr["home"];
            });
            widget.notifyParent();
          },
        ),
        SidebarXItem(
          icon: Icons.location_history,
          label: AppL10N.localStr["map"],
          onTap: () {
            Globals.changeInteger(1);
            setState(() {
              pageTitle = AppL10N.localStr["map"];
            });
            widget.notifyParent();
          },
        ),
        SidebarXItem(
            icon: Icons.list,
            label: AppL10N.localStr["assignment"],
            onTap: (() {
              setState(() {
                pageTitle = AppL10N.localStr["assignment"];
              });
              widget.notifyParent();
            })),
        SidebarXItem(
          icon: Icons.people,
          label: AppL10N.localStr["employees"],
          onTap: () {
            setState(() {
              pageTitle = AppL10N.localStr["employees"];
            });
            widget.notifyParent();
          },
        ),
        SidebarXItem(
          icon: Icons.agriculture,
          label: AppL10N.localStr["workOrders"],
          onTap: () {
            setState(() {
              pageTitle = AppL10N.localStr["workOrders"];
            });
            widget.notifyParent();
          },
        ),

        // const SidebarXItem(
        //   iconWidget: FlutterLogo(size: 20),
        //   label: 'Flutter',
        // ),
      ],
    );
  }
}

class _DisplayTab extends StatefulWidget {
  final String currentFarmingGroup;
  final Map<String, List<String>> farmingGroups;
  const _DisplayTab({
    Key key,
    this.controller,
    this.currentFarmingGroup,
    this.farmingGroups,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  State<_DisplayTab> createState() => _DisplayTabState();
}

class _DisplayTabState extends State<_DisplayTab> {
  String todayDate;

  // Login Futures
  // Map<String, List<String>> farmingGroups = {};
  Future<Map<String, List<String>>> getFarmingGroupsByUser(
      String userID) async {
    return await GetByUserWS().getFarmingGroupsAndBlocksByUser(userID);
  }

  // HomeTab Futures
  List<Employee> employees = [];
  Future<List<Employee>> getEmployees() async {
    return await GetByFarmingGroupsWS()
        .getEmployeesByFarmingGroup(widget.currentFarmingGroup);
  }

  Future<Map<String, List<Employee>>> generateAttendanceList(
      Future<List<Employee>> employees, String date) async {
    List<Employee> employeesList = await employees;
    List<Employee> active = [];
    List<Employee> mealPeriod = [];
    List<Employee> shiftCompleted = [];
    List<Employee> absent = [];

    // iterate through each employee in the farming group
    for (Employee e in employeesList) {
      // get the data for today

      List<EmployeeTime> dataForToday =
          await getEmployeesTime(date, e.employID);

      // determine the employees status
      int status = determineEmployeeStatus(dataForToday);

      // active
      if (status == 1) {
        active.add(e);
      }
      // meal period
      else if (status == 2) {
        mealPeriod.add(e);
      }
      // shift completed
      else if (status == 3) {
        shiftCompleted.add(e);
      }
      // absent
      else if (status == 0) {
        absent.add(e);
      }
    }
    active.addAll(mealPeriod);

    // return map
    return {
      'Active': active,
      'Meal Period': mealPeriod,
      'Shift Completed': shiftCompleted,
      'Absent': absent
    };
  }

  Future<List<EmployeeTime>> getEmployeesTime(
      String date, String employeeID) async {
    List<EmployeeTime> employeesTimeList = [];
    employeesTimeList =
        await GetEmployeeTimeWS().getEmployeeTimeByDate(date, employeeID);
    return employeesTimeList;
  }

  int determineEmployeeStatus(List<EmployeeTime> data) {
    // no data means employee is absent
    if (data.isEmpty) {
      return 0;
    } else {
      for (var d in data) {
        // print(d);
      }
      // first check if employee has closed his session
      if (!hasActiveSession(data)) {
        return 3;
      }

      if (hasActiveMealPeriod(data)) {
        return 2;
      }
    }
    return 1;
  }

  bool hasActiveSession(List<EmployeeTime> data) {
    for (EmployeeTime entry in data) {
      // has a startend that has not closed
      if (entry.DBType.contains('STRTEND') &&
          entry.endDate.contains('1900-01-01 00:00:00.000')) {
        return true;
      }
    }
    return false;
  }

  bool hasActiveMealPeriod(List<EmployeeTime> data) {
    for (EmployeeTime entry in data) {
      // has a startend that has not closed
      if ((entry.DBType.contains('BREAK') || entry.DBType.contains('LUNCH')) &&
          entry.endDate.contains('1900-01-01 00:00:00.000')) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, List<WorkOrder>>> getWorkOrders() async {
    List<WorkOrder> workOrders = await GetWorkOrderWS()
        .getCurrentWorkOrders(widget.currentFarmingGroup, false);
    // workOrders.sort(
    //     (a, b) => a.dbfarmingfunctionsname.compareTo(b.dbfarmingfunctionsname));

    // open work orders
    List<WorkOrder> openWorkOrders = [];
    // completed work orders
    List<WorkOrder> completedWorkOrders = [];
    // work orders pending assignment
    List<WorkOrder> pendingAssignmentWorkOrders = [];

    // group by work order state
    for (WorkOrder order in workOrders) {
      if (order.DB_Completed == 0) {
        if (order.DB_Assigned == 0) {
          pendingAssignmentWorkOrders.add(order);
        } else {
          openWorkOrders.add(order);
        }
      } else if (order.DB_Completed == 1) {
        completedWorkOrders.add(order);
      }
    }

    Map<String, List<WorkOrder>> result = {
      'Open': openWorkOrders,
      'Completed': completedWorkOrders,
      'Pending': pendingAssignmentWorkOrders
    };

    result.forEach((key, value) {
      //print(key + ' ${value.length}');
    });

    return result;
  }

  // MapTab Futures
  Future<List<PositionEntry>> getEmployeesPosition(
      String date, String employee) async {
    List<PositionEntry> employeesPositionList = [];
    employeesPositionList =
        await GetEmployeePositionWS().getEmployeePositionByDate(date, employee);
    return employeesPositionList;
  }

  Future<Map<Employee, List<PositionEntry>>> getPresentEmployeesPosition(
      String date, Future<List<Employee>> presentEmployees) async {
    List<Employee> presentEmployeesList = await presentEmployees;
    Map<Employee, List<PositionEntry>> presentEmployeesPositionList = {};

    //print(presentEmployeesList);
    for (Employee e in presentEmployeesList) {
      List<PositionEntry> positions = await GetEmployeePositionWS()
          .getEmployeePositionByDate(date, e.employID.trim());
      presentEmployeesPositionList.putIfAbsent(e, () => positions);
    }

    return presentEmployeesPositionList;
  }

  Future<List<Employee>> getPresentEmployees() async {
    Map<String, List<Employee>> attendanceList =
        await generateAttendanceList(getEmployees(), todayDate);
    return attendanceList['Active'];
  }

  // EmployeeTab Futures
  Map<Employee, List<EmployeeTime>> allEmployeesTimeByDate = {};
  Future<Map<Employee, List<EmployeeTime>>> getAllEmployeesTimeByDate(
      Future<List<Employee>> employees, String date) async {
    Map<Employee, List<EmployeeTime>> result = {};
    List<Employee> employeesList = await employees;

    for (Employee e in employeesList) {
      List<EmployeeTime> dataForToday =
          await getEmployeesTime(date, e.employID);
      result.putIfAbsent(e, () => dataForToday);
    }
    allEmployeesTimeByDate = result;
    //print(result);
    return result;
  }

  List<Employee> sortedEmployeeList = [];
  Future<void> generateSortedEmployeeList() async {
    final attendance = await generateAttendanceList(getEmployees(), todayDate);
    List<Employee> result = [];
    attendance.forEach((key, value) {
      result.addAll(value);
    });
    // selectedIndexList.clear();
    // selectedIndexList = List<bool>.generate(result.length, (index) {
    //   return false;
    // });
    // selectedIndexList.first = true;
    setState(() {
      sortedEmployeeList = result;
      generateSelectedIndexList();
    });

    return;
  }

  List<bool> selectedIndexList = [];
  List<bool> generateSelectedIndexList() {
    List<bool> result = List<bool>.generate(sortedEmployeeList.length, (index) {
      return false;
    });
    result.first = true;
    return result;
  }

  int selectedIndex = 0;

  // Drag and Drop Futures and Variables
  List<WorkOrder> currentFarmingGroupWorkOrders = [];

  Future<List<Employee>> getWorkersByCurrentFarmingGroup() async {
    return await GetByFarmingGroupsWS()
        .getEmployeesByFarmingGroup(FarmingGroupNotifier.currentValue());
  }

  Future<List<WorkOrder>> getWorkOrdersByCurrentFarmingGroup() async {
    currentFarmingGroupWorkOrders = await GetWorkOrderWS()
        .getCurrentWorkOrders(FarmingGroupNotifier.currentValue(), false);

    // currentFarmingGroupPlantings = await getPlantingsByWorkOrders(
    //     getCurrentWorkOrderDRBs(currentFarmingGroupWorkOrders));
    return currentFarmingGroupWorkOrders;
  }

  Map<String, List<Planting>> currentFarmingGroupPlantings = {};
  Future<Map<String, List<Planting>>> getPlantingsByWorkOrders(
      Future<List<String>> _workOrderDRBs) async {
    List<String> workOrderDRBs = await _workOrderDRBs;
    return await GetByFarmingGroupsWS()
        .getCurrentPlantingsByWorkOrders(workOrderDRBs);
  }

  Future<List<String>> getCurrentWorkOrderDRBs() async {
    List<String> result = [];
    List<WorkOrder> currFarmingGroupWorkOrders =
        await getWorkOrdersByCurrentFarmingGroup();
    for (WorkOrder wo in currFarmingGroupWorkOrders) {
      result.add(wo.RANCHBLK);
    }

    return result;
  }

  // Left Side Column
  Future<Map<String, List<Assignee>>> iterateAssignees() async {
    Map<String, List<Assignee>> assigneeList = {};
    List<WorkOrder> currFarmingGroupWorkOrders =
        await getWorkOrdersByCurrentFarmingGroup();
    for (var c in currFarmingGroupWorkOrders) {
      List temp = await getAssigneesByWorkOrder(c.DB_PRODWO);
      assigneeList.putIfAbsent(c.DB_PRODWO, () {
        return temp;
      });
    }
    return assigneeList;
  }

  Future<List<Assignee>> getAssigneesByWorkOrder(String workOrderNumber) async {
    List<Assignee> assigneeList = [];
    assigneeList = await EmployeesToWorkOrdersWS()
        .getEmployeesbyWorkOrderID(workOrderNumber);

    return assigneeList;
  }

  // Right Side Column
  Future<Map<String, List<AssignedWorkOrder>>>
      iterateAssignedWorkOrders() async {
    Map<String, List<AssignedWorkOrder>> assignedWorkOrdersList = {};
    List<Employee> currFarmingGroupEmployees =
        await getWorkersByCurrentFarmingGroup();
    for (var e in currFarmingGroupEmployees) {
      List temp = await getWorkOrdersByEmployeeID(e.employID);
      assignedWorkOrdersList.putIfAbsent(e.employID, () {
        return temp;
      });
    }
    return assignedWorkOrdersList;
  }

  Future<List<AssignedWorkOrder>> getWorkOrdersByEmployeeID(
      String employeeID) async {
    return await WorkOrdersToEmployeeWS().getWorkOrdersByEmployeeID(employeeID);
  }

  Future<void> dummyAsync() async {
    return;
  }

  String sessionUserID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.setExtended(false);
    getWorkOrders();
    todayDate = intl.DateFormat('yyyy-MM-dd')
        .parse(DateTime.now().toString())
        .toLocal()
        .toString();
    getAllEmployeesTimeByDate(getEmployees(), todayDate);
    print('_DisplayTab initState ' + widget.currentFarmingGroup);
    sessionUserID = Preferences.currentUserID;
    //getFarmingGroupsByUser(Preferences.currentUserID);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);
          switch (widget.controller.selectedIndex) {
            case 0:
              return Stack(
                children: [
                  FutureBuilder(
                      future: Future.wait([
                        getEmployees(),
                        generateAttendanceList(getEmployees(), todayDate),
                        getWorkOrders(),
                        getFarmingGroupsByUser(sessionUserID),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        }

                        return HomeTab(
                          controller: widget.controller,
                          employees: snapshot.data[0],
                          attendanceList: snapshot.data[1],
                          workOrdersList: snapshot.data[2],
                          farmingGroups: snapshot.data[3],
                          currentFarmingGroup: _currentFarmingGroup,
                        );
                      }),
                  Visibility(
                    visible: widget.controller.extended,
                    child: Expanded(
                        child: Container(
                      color: Colors.black.withOpacity(.8),
                    )),
                  ),
                ],
              );
            case 1:
              return Stack(
                children: [
                  FutureBuilder(
                      future: Future.wait([
                        getPresentEmployeesPosition(
                          todayDate,
                          getPresentEmployees(),
                        ),
                        generateAttendanceList(getEmployees(), todayDate)
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        return MapTab(
                          presentEmployeesPosition: snapshot.data[0],
                          attendanceList: snapshot.data[1],
                        );
                      }),
                  Visibility(
                    visible: widget.controller.extended,
                    child: Expanded(
                        child: Container(
                      color: Colors.black.withOpacity(.8),
                    )),
                  ),
                ],
              );
            case 2:
              return Stack(
                children: [
                  FutureBuilder(
                      future: Future.wait([
                        getWorkersByCurrentFarmingGroup(),
                        getWorkOrdersByCurrentFarmingGroup(),
                        iterateAssignees(),
                        iterateAssignedWorkOrders(),
                        light == false
                            ? getPlantingsByWorkOrders(
                                getCurrentWorkOrderDRBs())
                            : dummyAsync()
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        }

                        //print('DRAG AND DROP FUTUREBUILDER');
                        //print(snapshot.data[4]);
                        return DragAndDropTab(
                            currentFarmingGroup: widget.currentFarmingGroup,
                            employees: snapshot.data[0],
                            workOrders: snapshot.data[1],
                            assignes: snapshot.data[2],
                            assignedWorkOrders: snapshot.data[3],
                            plantings: light == false ? snapshot.data[4] : {});
                      }),
                  Visibility(
                    visible: widget.controller.extended,
                    child: Expanded(
                        child: Container(
                      color: Colors.black.withOpacity(.8),
                    )),
                  ),
                ],
              );
            case 3:
              return Stack(
                children: [
                  FutureBuilder(
                      future: Future.wait([
                        getEmployees(),
                        generateAttendanceList(getEmployees(), todayDate),
                        getWorkOrders(),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        }

                        return EmployeesTab(
                          employees: snapshot.data[0],
                          attendance: snapshot.data[1],
                          workOrders: snapshot.data[2],
                          employeesTime: allEmployeesTimeByDate,
                          selectedIndex: selectedIndex,
                        );
                      }),
                  Visibility(
                    visible: widget.controller.extended,
                    child: Expanded(
                        child: Container(
                      color: Colors.black.withOpacity(.8),
                    )),
                  ),
                ],
              );
            case 4:
              return Stack(
                children: [
                  FutureBuilder(
                      future: Future.wait([
                        getEmployees(),
                        getWorkOrders(),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        }

                        return WorkOrdersTab(
                          employees: snapshot.data[0],
                          workOrders: snapshot.data[1],
                        );
                      }),
                  Visibility(
                    visible: widget.controller.extended,
                    child: Expanded(
                        child: Container(
                      color: Colors.black.withOpacity(.8),
                    )),
                  ),
                ],
              );
            default:
              return Text(
                pageTitle,
                style: theme.textTheme.headlineSmall,
              );
          }
        },
      ),
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Home';
    case 1:
      return 'Map';
    case 2:
      return 'Drag & Drop';
    case 3:
      return 'Employees';
    case 4:
      return 'Custom iconWidget';
    case 5:
      return 'Profile';
    case 6:
      return 'Settings';
    default:
      return 'Not found page';
  }
}

// const primaryColor = Color(0xFF15202B);
// const canvasColor = Color(0xFF15202B);
// const scaffoldBackgroundColor = Color.fromARGB(255, 13, 20, 27);
// const accentCanvasColor = Color.fromARGB(255, 11, 107, 185);
// const white = Colors.white;
// final actionColor = Colors.white.withOpacity(0.6);
// final divider = Divider(color: white.withOpacity(0.3), height: 1);


