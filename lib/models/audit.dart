class Audit {
  String USERID;
  String DB_App_Name;
  String DSCRIPTN;

  Audit(String USERID, String DB_App_Name, String DSCRIPTN) {
    this.USERID = USERID;
    this.DB_App_Name = DB_App_Name;
    this.DSCRIPTN = DSCRIPTN;
  }

  Map<String, dynamic> toJson() => {
        "USERID": USERID,
        "DB_App_Name": DB_App_Name,
        "DSCRIPTN": DSCRIPTN,
      };
}
