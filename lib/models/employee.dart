class Employee {
  String fullname;
  String employID;
  String crewID;
  String lastName;
  String dscrptn;
  String foreman;

  Employee(String fullname, String employID, String crewID, String lastName,
      String dscrptn, String foreman) {
    this.fullname = fullname;
    this.employID = employID;
    this.crewID = crewID;
    this.lastName = lastName;
    this.dscrptn = dscrptn;
    this.foreman = foreman;
  }

  @override
  String toString() {
    return 'Employee(fullname: $fullname, employID: $employID, crewID: $crewID, lastName: $lastName, dscrptn: $dscrptn, foreman: $foreman)';
  }
}
