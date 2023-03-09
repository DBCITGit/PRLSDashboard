// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/planting_detail.dart';
import 'package:xml/xml.dart' as xml;
import 'package:prodwo_timesheet/models/planting.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';

class GetCurrentPlantingsWS {
  Future<dynamic> GetAllCurrentPlantings() async {
    try {
      String envelope =
          "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetCurrentPlantings xmlns=\"http://tempuri.org/\"><inDistrictRanch>01</inDistrictRanch></GetCurrentPlantings></soap:Body></soap:Envelope>";
      http.Response response = await http
          .post(
            Uri.parse(ServerSettingsPreferences.webUrl),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              "SOAPAction": "http://tempuri.org/GetCurrentPlantings",
              "Host": ServerSettingsPreferences.webHost,
            },
            body: envelope,
          )
          .timeout(const Duration(seconds: 45));

      return _parseCurrentPlantings(response.body);
    } on Exception {
      throw Exception("Function Timeout");
    }
  }

  Map<String, List<Planting>> _parseCurrentPlantings(String response) {
    var document = xml.parse(response);
    Map<String, List<Planting>> plantingsByBlock = {};

    Iterable<xml.XmlElement> items = document.findAllElements('DBCPlanting');

    for (var element in items) {
      String ranchBlock = "";
      String district = "";
      String ranch = "";
      String block = "";
      String season = "";
      String planting = "";
      String variety = "";
      String commodity = "";
      String commoditySp = '';
      String siteAcres = '';

      ranchBlock = element.getElement("RanchBlock").firstChild.toString();
      district = element.getElement("District").firstChild.toString();
      ranch = element.getElement("Ranch").firstChild.toString();
      block = element.getElement("Block").firstChild.toString();
      season = element.getElement("Season").firstChild.toString();
      planting = element.getElement("Planting").firstChild.toString();
      if (planting == "null") planting = "";
      variety = element.getElement("Variety").firstChild.toString();
      if (variety == "null") variety = "";
      commodity = element.getElement("CommodityDesc").firstChild.toString();
      commoditySp =
          element.getElement("CommodityDescSpanish").firstChild.toString();
      siteAcres = element.getElement("SiteAcres").firstChild.toString();

      plantingsByBlock.putIfAbsent(
          ranchBlock, () => getBlocksPlantings(ranchBlock, response));
    }

    print(plantingsByBlock);

    return plantingsByBlock;
  }
}

List<Planting> getBlocksPlantings(String drb, String response) {
  var document = xml.parse(response);
  List<Planting> models = [];

  Iterable<xml.XmlElement> items = document.findAllElements('DBCPlanting');
  for (var element in items) {
    if (element.getElement("RanchBlock").firstChild.toString().trim() == drb) {
      String ranchBlock = "";
      String district = "";
      String ranch = "";
      String block = "";
      String season = "";
      String planting = "";
      String variety = "";
      String commodity = "";
      String commoditySp = '';
      String siteAcres = '';

      ranchBlock = element.getElement("RanchBlock").firstChild.toString();
      district = element.getElement("District").firstChild.toString();
      ranch = element.getElement("Ranch").firstChild.toString();
      block = element.getElement("Block").firstChild.toString();
      season = element.getElement("Season").firstChild.toString();
      planting = element.getElement("Planting").firstChild.toString();
      if (planting == "null") planting = "";
      variety = element.getElement("Variety").firstChild.toString();
      if (variety == "null") variety = "";
      commodity = element.getElement("CommodityDesc").firstChild.toString();
      commoditySp =
          element.getElement("CommodityDescSpanish").firstChild.toString();
      siteAcres = element.getElement("SiteAcres").firstChild.toString();

      PlantingDetail plantingDetail;

      models.add(
        Planting(
            ranchBlock: ranchBlock,
            district: district,
            ranch: ranch,
            block: block,
            planting: planting,
            variety: variety,
            commodityDesc: commodity,
            commodityDescSpanish: commoditySp,
            season: season,
            siteAcres: siteAcres,
            plantingDetail: plantingDetail),
      );
    }
  }
  return models;
}
