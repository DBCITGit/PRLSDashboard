import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/audit.dart';
import 'package:prodwo_timesheet/preferences/preferences.dart';
import 'package:prodwo_timesheet/services/webservices/webservice.dart';

import 'package:xml/xml.dart' as xml;

class MobilePasswordResetWS {
  MobilePasswordResetWS();

  Future<String> call(String email) async {
    var _envelope =
        "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><MobilePasswordReset xmlns=\"http://tempuri.org/\"><inEmail>$email</inEmail></MobilePasswordReset></soap:Body></soap:Envelope>";
    Webservice().auditApp(new Audit(Preferences.currentUserID,
        "RanchMaps 0.0.${Preferences.buildNumber}", "Reset Password"));
    //"mobile_password_reset " + Preferences.webUrl);
    http.Response response = await http.post(Uri.parse(Preferences.webUrl),
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "SOAPAction": "http://tempuri.org/MobilePasswordReset",
          "Host": Preferences.webHost
        },
        body: _envelope);

    var _response = response.body;
    return await _parsing(_response);
  }

  Future<String> _parsing(var _response) async {
    var _document = xml.parse(_response);
    var val = _getValue(_document.findAllElements('MobilePasswordResetResult'));
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
