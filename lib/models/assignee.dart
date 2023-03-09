// ignore_for_file: non_constant_identifier_names

class Assignee {
  String fullname;
  String CREWID;
  String DB_PRODWO;
  String EMPLOYID;
  String LASTNAME;
  String DBCHRS;
  String DBCTOHR;

  Assignee(
    String fullname,
    String CREWID,
    String DB_PRODWO,
    String EMPLOYID,
    String LASTNAME,
    String DBCHRS,
    String DBCTOHR,
  ) {
    this.fullname = fullname;
    this.DB_PRODWO = DB_PRODWO;
    this.EMPLOYID = EMPLOYID;
    this.CREWID = CREWID;
    this.LASTNAME = LASTNAME;
    this.DBCHRS = DBCHRS;
    this.DBCTOHR = DBCTOHR;
  }
}
