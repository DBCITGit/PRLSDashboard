import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/preferences/preferences.dart';

import 'package:xml/xml.dart' as xml;

class MobileGetUserIDWS {
  int secTimeout = 45;
  MobileGetUserIDWS();

  Future<String> call(String email) async {
    try {
      var _envelope =
          "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><MobileGetUserID xmlns=\"http://tempuri.org/\"><inEmail>$email</inEmail></MobileGetUserID></soap:Body></soap:Envelope>";
      // try {
      //   Webservice().auditApp(
      //       new Audit(Preferences.currentUserID, "Ranch Maps", "Get User ID"));
      // } on Exception {
      //   throw Exception("Audit Timeout in call");
      // }
      http.Response response = await http
          .post(Uri.parse(Preferences.webUrl),
              headers: {
                "Content-Type": "text/xml; charset=utf-8",
                "SOAPAction": "http://tempuri.org/MobileGetUserID",
                "Host": Preferences.webHost
              },
              body: _envelope)
          .timeout(Duration(seconds: secTimeout));
      var _response = response.body;
      print('call');
      print(await _parsing(_response));
      return await _parsing(_response);
    } on Exception catch (e) {
      throw Exception("MobileGetUserIDWS Login Timeout $e");
    }
  }

  Future<String> _parsing(var _response) async {
    var _document = xml.parse(_response);
    var val = _getValue(_document.findAllElements('MobileGetUserIDResult'));
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
