class AssignedWorkOrder {
  int DB_Completed;
  String EmployID;
  String DBFarmingFunctionsName;
  String DB_PRODWO;
  String DBFarmingFunctionsDesc;
  String DBCHRS;

  AssignedWorkOrder(
    int DB_Completed,
    String EmployID,
    String DBFarmingFunctionsName,
    String DB_PRODWO,
    String DBFarmingFunctionsDesc,
    String DBCHRS,
  ) {
    this.DB_Completed = DB_Completed;
    this.EmployID = EmployID;
    this.DBFarmingFunctionsName = DBFarmingFunctionsName;
    this.DB_PRODWO = DB_PRODWO;
    this.DBFarmingFunctionsDesc = DBFarmingFunctionsDesc;
    this.DBCHRS = DBCHRS;
  }
}
