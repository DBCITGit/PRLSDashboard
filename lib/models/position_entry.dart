class PositionEntry {
  String deviceName;
  String deviceID;
  String employID;
  String inBlock;
  String nearBlock;
  double lat;
  double lng;
  String date;
  String time;
  double leadDistance;
  double distance;
  int battery;
  double accuracy;
  PositionEntry({
    this.deviceName,
    this.deviceID,
    this.employID,
    this.inBlock,
    this.nearBlock,
    this.lat,
    this.lng,
    this.date,
    this.time,
    this.leadDistance,
    this.distance,
    this.battery,
    this.accuracy,
  });

  @override
  String toString() {
    return 'PositionEntry(deviceName: $deviceName, deviceID: $deviceID, employID: $employID, inBlock: $inBlock, nearBlock: $nearBlock, lat: $lat, lng: $lng, date: $date, time: $time)';
  }
}
