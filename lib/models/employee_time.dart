// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class EmployeeTime {
  String employID;
  String strtDate;
  String strtTime;
  String endDate;
  String endTime;
  String DBType;
  int DBEdited;
  int DBConcurrent;
  EmployeeTime({
    this.employID,
    this.strtDate,
    this.strtTime,
    this.endDate,
    this.endTime,
    this.DBType,
    this.DBEdited,
    this.DBConcurrent,
  });

  @override
  String toString() {
    return 'EmployeeTime(employID: $employID, strtDate: $strtDate, strtTime: $strtTime, endDate: $endDate, endTime: $endTime, DBType: $DBType, DBEdited: $DBEdited, DBConcurrent: $DBConcurrent)';
  }
}
