import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/audit.dart';
import 'package:prodwo_timesheet/preferences/preferences.dart';
import 'package:prodwo_timesheet/services/webservices/webservice.dart';

import 'package:xml/xml.dart' as xml;

class MobileLoginWS {
  MobileLoginWS();

  Future<dynamic> checkVersion() async {
    try {
      String url =
          "http://${Preferences.webHost}:8080/DBCWebService/PRODWO/WorkOrder/getVersion";
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      return responseData;
    } on Exception {
      throw Exception("Timeout");
    }
  }

  Future<String> call(
      String email, String password, bool usedBiometrics) async {
    try {
      //PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //packageInfo.version.substring(0, packageInfo.version.length - 1));
      var _envelope =
          "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><MobileLogin xmlns=\"http://tempuri.org/\"><inEmail>$email</inEmail><inPassword>$password</inPassword></MobileLogin></soap:Body></soap:Envelope>";
      Webservice().auditApp(Audit(
          Preferences.currentUserID,
          "Dahsboard App 0.0.${Preferences.buildNumber}",
          usedBiometrics
              ? "Mobile Login with Biometrics"
              : "Mobile Login w/o Biometrics"));
      http.Response response = await http.post(Uri.parse(Preferences.webUrl),
          headers: {
            "Content-Type": "text/xml; charset=utf-8",
            "SOAPAction": "http://tempuri.org/MobileLogin",
            "Host": Preferences.webHost
          },
          body: _envelope);

      var _response = response.body;
      return await _parsing(_response);
    } on Exception catch (e) {
      throw Exception("MobileLoginWS Login Timeout $e");
    }
  }

  Future<String> _parsing(var _response) async {
    var _document = xml.parse(_response);
    var val = _getValue(_document.findAllElements('MobileLoginResult'));
    return val;
  }

  _getValue(Iterable<xml.XmlElement> items) {
    var textValue;
    items.map(
      (xml.XmlElement node) {
        textValue = node.text;
      },
    ).toList();
    return textValue;
  }
}
