import 'package:equatable/equatable.dart';

import '../preferences/server_settings_preferences.dart';
import 'employee.dart';

///WorkOrder class for adding work orders, the stored proc populates null values
///to the correct info
class WorkOrder {
  String DB_PRODWO;
  String WOName;
  String RANCHBLK;
  String DATE1;
  String DBFarmingFunctionsID;
  String DBFarmingFunctionsDescID;
  String DB_Farming_GroupID;
  int DB_Completed;
  int DB_Assigned;
  int DB_FarmingActivity;
  String USERID;
  List<Employee> assignedEmployees;
  String DB_Original_Date;
  String DBCTOTHR;
  String DEX_ROW_ID;
  String dbfarmingfunctionsname;

  WorkOrder(
      String DB_PRODWO,
      String WOName,
      String RANCHBLK,
      String DATE1,
      String DBFarmingFunctionsID,
      String DBFarmingFunctionsDescID,
      String DB_Farming_GroupID,
      int DB_Completed,
      int DB_Assigned,
      int DB_FarmingActivity,
      String USERID,
      List<Employee> assignedEmployees,
      String DBCTOTHR,
      String DEX_ROW_ID,
      String dbfarmingfunctionsname) {
    this.DB_PRODWO = DB_PRODWO;
    this.WOName = WOName;
    this.RANCHBLK = RANCHBLK;
    this.DATE1 = DATE1;
    this.DBFarmingFunctionsID = DBFarmingFunctionsID;
    this.DBFarmingFunctionsDescID = DBFarmingFunctionsDescID;
    this.DB_Farming_GroupID = DB_Farming_GroupID;
    this.DB_Completed = DB_Completed;
    this.DB_Assigned = DB_Assigned;
    this.DB_FarmingActivity = DB_FarmingActivity;
    this.USERID = ServerSettingsPreferences.currentUserID;
    this.assignedEmployees = assignedEmployees;
    this.DB_Original_Date = DATE1;
    this.DBCTOTHR = DBCTOTHR;
    this.DEX_ROW_ID = DEX_ROW_ID;
    this.dbfarmingfunctionsname = dbfarmingfunctionsname;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        "DB_PRODWO": DB_PRODWO,
        "RANCHBLK": RANCHBLK,
        "DATE1": DATE1,
        "DBFarmingFunctionsID": DBFarmingFunctionsID,
        "DBFarmingFunctionsDescID": DBFarmingFunctionsDescID,
        "DB_Farming_GroupID": DB_Farming_GroupID,
        "DB_Completed": DB_Completed,
        "DB_Assigned": DB_Assigned,
        "USERID": USERID,
        "assignedEmployees": assignedEmployees,
        "DB_Original_Date": DATE1,
        "DBCTOTHR": DBCTOTHR,
        "DEX_ROW_ID": DEX_ROW_ID,
        "dbfarmingfunctionsname": dbfarmingfunctionsname
      };

  @override
  String toString() {
    return 'WorkOrder(DB_PRODWO: $DB_PRODWO, WOName: $WOName, RANCHBLK: $RANCHBLK, DATE1: $DATE1, DBFarmingFunctionsID: $DBFarmingFunctionsID, DBFarmingFunctionsDescID: $DBFarmingFunctionsDescID, DB_Farming_GroupID: $DB_Farming_GroupID, DB_Completed: $DB_Completed,  DB_Assigned: $DB_Assigned, USERID: $USERID, assignedEmployees: $assignedEmployees, DB_Original_Date: $DB_Original_Date, DBCTOTHR: $DBCTOTHR, DEX_ROW_ID: $DEX_ROW_ID, dbfarmingfunctionsname: $dbfarmingfunctionsname)';
  }
}

/// Data that is returned from the stored proc DBR_GetWorkOrdersByDate in the
/// Home Screen is then added to a list with the following Object as its content
class WorkOrdersData extends Equatable {
  ///Siteacres of the block
  double siteacres;

  ///Commodity of the ranch and block, no block work orders will be empty
  Map<String, dynamic> description;

  ///Current season of the ranch and block
  String season;

  ///Ranch block as a string, e.g. 010111, 0105, etc.
  String ranchBlock;

  ///User ID that added the work order.
  String userID;

  ///Unique Dex Row ID, used as an identifier to update and delete work orders
  int dexrowid;

  ///Whether the work order is completed, 0 is uncompleted, 1 is completed
  int dbCompleted;

  ///Farming Activity type, different numbers can represent farm group, centralized
  ///service, or awareness work orders
  int dbFarmingActvity;

  ///Farming functions ID, represented as a three digit number
  String dbFarmingFunctionsID;

  ///Farming activities ID, represented as a three digit number
  String dbFarmingFunctionsDescID;

  ///Farming activity name, represented as a map to support language change
  Map<dynamic, dynamic> dbFarmingFunctionsDesc;

  ///Farming functions name, not used in home screen but still important
  Map<dynamic, dynamic> dbFarmingFunctionsName;

  ///Work order number which can be unique, PAOs will use a different format
  ///than farming group or centralized service
  String dbProdWo;

  ///Line Item Sequence, used to have a hierachy when dragging and dropping
  int lnitmseq;

  ///Farming Group ID, which is the farming group name the work order belongs to
  ///.Based on district ranch
  String dbFarmingGroupID;

  ///If the work order is assigned then the value is 1, otherwise 0
  int dbAssigned;

  ///Assigned employee ID
  String employid;

  ///Assigned employee full name
  String fullname;

  ///Make of the assigned equipment for that work order
  String dbomake;

  ///Model of the assigned equipment for that work order
  String dbomodel;

  ///Rolling date of the work order, if uncompleted will keep moving forward
  String date1;

  ///Originally created date of the work order
  String dbOriginalDate;

  ///Originally created date of the work order
  String creatddt;

  ///Originally created time of the work order
  String createtime;

  List<String> seasons;

  double dbctothr;

  WorkOrdersData(
      this.siteacres,
      this.description,
      this.season,
      this.ranchBlock,
      this.userID,
      this.dexrowid,
      this.dbCompleted,
      this.dbFarmingActvity,
      this.dbFarmingFunctionsID,
      this.dbFarmingFunctionsDescID,
      this.dbFarmingFunctionsDesc,
      this.dbFarmingFunctionsName,
      this.dbProdWo,
      this.lnitmseq,
      this.dbFarmingGroupID,
      this.dbAssigned,
      this.employid,
      this.fullname,
      this.dbomake,
      this.dbomodel,
      this.date1,
      this.dbOriginalDate,
      this.creatddt,
      this.createtime,
      this.seasons,
      this.dbctothr);

  ///Constructor that creates the object from the date in DBR_GetWorkOrdersByDate
  factory WorkOrdersData.fromJson(final Map<String, dynamic> json) =>
      WorkOrdersData(
        json['siteacres'] as double,
        <String, dynamic>{
          'description': (json['description'] ?? '').trim(),
          'spdescription': (json['spdescription'] ?? '').trim(),
        },
        json['season'].trim() as String,
        json['RANCHBLK'].trim() as String,
        json['USERID'].trim() as String,
        json['DEX_ROW_ID'] as int,
        json['DB_Completed'] as int,
        json['dbfarmingactvity'] as int,
        json['DBFarmingFunctionsID'].trim() as String,
        json['DBFarmingFunctionsDescID'].trim() as String,
        <String, dynamic>{
          'dbfarmingfunctionsdesc': json['dbfarmingfunctionsdesc'].trim(),
          'dbfarmingfunctionsspdesc': json['dbfarmingfunctionsspdesc'].trim(),
        },
        <String, dynamic>{
          'dbfarmingfunctionsname': json['dbfarmingfunctionsname'].trim(),
          'dbfarmingfunctionsspname': json['dbfarmingfunctionsspname'].trim(),
        },
        json['DB_PRODWO'].trim() as String,
        json['LNITMSEQ'] as int,
        json['DB_Farming_GroupID'].trim() as String,
        json['DB_Assigned'] as int,
        json['employid'].trim() as String,
        json['fullname'].trim() as String,
        json['dbomake'].trim() as String,
        json['dbomodel'].trim() as String,
        json['DATE1'].trim() as String,
        json['DB_Original_Date'].trim() as String,
        json['CREATDDT'].trim() as String,
        json['CREATETIME'].trim() as String,
        json['Seasons']?.split(',') as List<String>,
        json['DBCTOTHR'],
      );

  @override
  List<Object> get props => [
        siteacres,
        description,
        season,
        ranchBlock,
        userID,
        dexrowid,
        dbCompleted,
        dbFarmingActvity,
        dbFarmingFunctionsID,
        dbFarmingFunctionsDescID,
        dbFarmingFunctionsDesc,
        dbFarmingFunctionsName,
        dbProdWo,
        lnitmseq,
        dbFarmingGroupID,
        dbAssigned,
        employid,
        fullname,
        dbomake,
        dbomodel,
        date1,
        dbOriginalDate,
        creatddt,
        createtime,
        seasons,
        dbctothr
      ];
}
