// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prodwo_timesheet/models/employee.dart';
import 'package:prodwo_timesheet/models/planting.dart';
import 'package:prodwo_timesheet/models/planting_detail.dart';
import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';
import 'package:prodwo_timesheet/tools/format.dart';
import 'package:xml/xml.dart' as xml;

class GetByFarmingGroupsWS {
  Future<dynamic> getEmployeesByFarmingGroup(String farmingGroup) async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/PRODWO/DB10401farmGroupEmployees?farmGroup=$farmingGroup";
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData = json.decode(response.body);
      List<Employee> employeeList = [];

      responseData.forEach((element) {
        // "fullname": "JOSE MANUEL AGUIRRE PENA         ",
        // "STRTTIME": null,
        // "CREWID": "145F ",
        // "TOTHRS": 0.00000,
        // "EMPLOYID": "123043         ",
        // "LASTNAME": "AGUIRRE PENA         ",
        // "DSCRIPTN": "Ranch 14-15-22 Irrigation      ",
        // "FOREMAN": "Carlos Rene De Leon            ",
        // "ISFLC": 0,
        // "HoursDT": null
        String name = element['fullname'].trim();
        name = name.toTitleCase();
        employeeList.add(Employee(
            name,
            element['EMPLOYID'].trim(),
            element['CREWID'],
            element['LASTNAME'],
            element['DSCRIPTN'],
            element['FOREMAN']));
      });
      // ws call print
      // print(url);
      // print('getEmployeesByFarmingGroup: Success');

      //for (var w in employeeList) print(w.fullname);
      return employeeList;
    } catch (e, stacktrace) {
      throw Exception(
          'getEmployeesByFarmingGroup: ${e.toString()} | $stacktrace');
    }
  }

  Future<Map> getBlocksByFarmingGroup() async {
    try {
      String url =
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/WhereamI/farmgroupranches";

      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));

      var responseData;
      responseData = json.decode(response.body);

      responseData.keys.forEach((element) {});
      return responseData;
    } on Exception {
      throw Exception("getBlocksByFarmingGroup Timeout");
    }
  }

  Future<Map> getRanchesByFarmingGroup() async {
    try {
      String url =
          "http://green.darrigo.com:8080/DBCWebService/WhereamI/farmgroupranches";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Transfer-Encoding': 'chunked',
          'Vary':
              'Origin,Access-Control-Request-Method,Access-Control-Request-Headers'
        },
      ).timeout(Duration(seconds: 15));

      var responseData;
      responseData = await json.decode(response.body);

      // Create a seperate Map for ranches only
      var result = {};
      // Create a temp list for unique ranches
      List<String> temp = [];

      responseData.forEach((k, v) {
        for (int i = 0; i < v.length; i++) {
          temp.add(v[i].substring(2, 4));
        }
        var temp2 = temp.toSet().toList();
        result.putIfAbsent(k, () => temp2);
        temp.clear();
      });

      return result;
    } on TimeoutException catch (e) {
      throw Exception("getRanchesByFarmingGroup Timeout: $e");
    }
  }

  Future<Map<String, List<Planting>>> getCurrentPlantingsByWorkOrders(
      List<String> ranchBlocks) async {
    print('calling get current plantings by work orders');
    print(ranchBlocks);
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
          .timeout(Duration(seconds: 15));

      return _parseCurrentPlantingsByWorkOrders(
          response.body, ranchBlocks.toSet().toList());
    } on TimeoutException catch (e) {
      throw Exception("getCurrentPlantings Timeout $e");
    }
  }

  Future<Map<String, List<Planting>>> _parseCurrentPlantingsByWorkOrders(
      String response, List<String> ranchBlocks) async {
    print('_parseCurrentPlantingsByWorkOrders for ${ranchBlocks.toString()}');
    var document = xml.parse(response);
    Map<String, List<Planting>> plantingsByBlock = {};

    Iterable<xml.XmlElement> items = document.findAllElements('DBCPlanting');

    for (var element in items) {
      if (ranchBlocks
          .contains(element.getElement("RanchBlock").firstChild.toString())) {
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
        print('_parseCurrentPlantingsByWorkOrders for $ranchBlock');
        List<Planting> blockPlantings =
            await getBlocksPlantings(ranchBlock, response);

        plantingsByBlock.putIfAbsent(ranchBlock, () => blockPlantings);
      }
    }

    return plantingsByBlock;
  }

  Future<Map<String, List<Planting>>> getCurrentPlantingsByFarmingGroup(
      String farmingGroup) async {
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
          .timeout(Duration(seconds: 15));

      return _parseCurrentPlantings(response.body, farmingGroup);
    } on TimeoutException catch (e) {
      throw Exception("getCurrentPlantings Timeout $e");
    }
  }

  Future<Map<String, List<Planting>>> _parseCurrentPlantings(
      String response, String farmingGroup) async {
    var document = xml.parse(response);
    Map<String, List<Planting>> plantingsByBlock = {};

    Iterable<xml.XmlElement> items = document.findAllElements('DBCPlanting');

    for (var element in items) {
      if (element.getElement("Ranch").firstChild.toString() == '05') {
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

        List<Planting> blockPlantings =
            await getBlocksPlantings(ranchBlock, response);

        plantingsByBlock.putIfAbsent(ranchBlock, () => blockPlantings);
      }
    }

    return plantingsByBlock;
  }

  Future<List<Planting>> getBlocksPlantings(String drb, String response) async {
    var document = xml.parse(response);
    List<Planting> models = [];

    Iterable<xml.XmlElement> items = document.findAllElements('DBCPlanting');
    for (var element in items) {
      if (element.getElement("RanchBlock").firstChild.toString().trim() ==
          drb) {
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

        PlantingDetail plantingDetail =
            await getPlantingDetailsByBlock(ranchBlock, season, planting);

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

  Future<PlantingDetail> getPlantingDetailsByBlock(
      String drb, String season, String planting) async {
    try {
      String envelope =
          "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetCurrentPlantingDetails xmlns=\"http://tempuri.org/\"><inRanchBlock>$drb</inRanchBlock><inSeason>$season</inSeason><inPlanting>$planting</inPlanting></GetCurrentPlantingDetails></soap:Body></soap:Envelope>";
      http.Response response = await http
          .post(
            Uri.parse(ServerSettingsPreferences.webUrl),
            headers: {
              "Content-Type": "text/xml; charset=utf-8",
              "SOAPAction": "http://tempuri.org/GetCurrentPlantingDetails",
              "Host": ServerSettingsPreferences.webHost,
            },
            body: envelope,
          )
          .timeout(Duration(seconds: 15));

      return _parsePlantingDetailResponse(response.body);
    } on TimeoutException catch (e) {
      throw Exception("getYieldDataModels Timeout $e");
    }
  }

  PlantingDetail _parsePlantingDetailResponse(String response) {
    var document = xml.parse(response);
    List<PlantingDetail> models = List<PlantingDetail>();

    Iterable<xml.XmlElement> items =
        document.findAllElements('DBCPlantingDetail');
    String plantingDate = "";
    String currHarvestDate = "";
    String wetDate = "";
    String commodity = ""; // comodity desc
    String commoditySp = "";

    items.forEach(
      // ignore: void_checks
      (element) {
        String districtRanchBlockNumber = "";

        String lostAcres = "";
        String planting = "";

        String daysToHarvest = "";
        String variety = "";
        String bedSize = "";
        String plantSpacing = "";
        String lines = "";
        String thinnedSpacing = "";
        String estimatedYield = "";
        String plantedAcres = "";
        String estimatedHarvestDate = "";
        String season = "";
        String wantsDesc = "";
        String netAcres = "";
        String harvestComplete = "";
        String currentWeekEnding = "";
        String currentDaysToHarvest = "";
        String commodityId = "";
        String submitForApproval = "";
        String firstHarvestDate = "";
        String lastHarvestDate = "";
        String actualUnits = "";
        String equivalentUnits = "";
        String actualYield = "";
        String actualEquivYield = "";
        String actualDaysToHarvest = "";
        String origDaysToHarvest = "";
        String curEstDaysToHarvest = "";
        String origDaysDiffActual = "";
        String curEstDaysDiffActual = "";
        String origYield = "";
        String harvestableAcres = "";

        districtRanchBlockNumber =
            element.getElement("RanchBlock").firstChild.toString();
        season = element.getElement("Season").firstChild.toString();
        commodity = element.getElement("CommodityDesc").firstChild.toString();
        commoditySp =
            element.getElement("CommodityDescSpanish").firstChild.toString();
        lostAcres = element.getElement("LostAcres").firstChild.toString();
        planting = element.getElement("Planting").firstChild.toString();
        if (planting == "null") planting = "";
        wetDate = element.getElement("WetDate").firstChild.toString();
        plantingDate = element.getElement("PlantingDate").firstChild.toString();
        currHarvestDate =
            element.getElement("CurrentHarvestDate").firstChild.toString();
        daysToHarvest =
            element.getElement("CurrentDaysToHarvest").firstChild.toString();
        variety = element.getElement("Variety").firstChild.toString();
        if (variety == "null") variety = "";
        bedSize = element.getElement("Bed").firstChild.toString();
        plantSpacing = element.getElement("PlantSpacing").firstChild.toString();
        lines = element.getElement("Lines").firstChild.toString();
        thinnedSpacing =
            element.getElement("ThinnedSpacing").firstChild.toString();
        estimatedYield = element
            .getElement("CartonsPerAcre")
            .firstChild
            .toString(); // est yield is viewed as cartons per acre
        plantedAcres = element.getElement("Acres").firstChild.toString();
        estimatedHarvestDate =
            element.getElement("CurrentHarvestDate").firstChild.toString();

        wantsDesc = element.getElement("WantsDesc").firstChild.toString();
        if (wantsDesc == "null") wantsDesc = "N/A";

        netAcres = element.getElement("NetAcres").firstChild.toString();
        if (netAcres == "null") netAcres = "N/A";

        harvestComplete =
            element.getElement("HarvestComplete").firstChild.toString();
        currentWeekEnding =
            element.getElement("CurrentWeekEnding").firstChild.toString();
        currentDaysToHarvest =
            element.getElement("CurrentDaysToHarvest").firstChild.toString();
        commodityId = element.getElement("CommodityID").firstChild.toString();
        submitForApproval =
            element.getElement("SubmitForApproval").firstChild.toString();
        firstHarvestDate =
            element.getElement("FirstHavestDate").firstChild.toString();
        lastHarvestDate =
            element.getElement("LastHavestDate").firstChild.toString();
        actualUnits = element.getElement("ActualUnits").firstChild.toString();
        equivalentUnits =
            element.getElement("EquivalentUnits").firstChild.toString();
        actualYield = element.getElement("ActualYield").firstChild.toString();
        actualEquivYield =
            element.getElement("ActualEquivYield").firstChild.toString();
        actualDaysToHarvest =
            element.getElement("ActualDaysToHarvest").firstChild.toString();
        origDaysToHarvest =
            element.getElement("OrigDaysToHarvest").firstChild.toString();
        curEstDaysToHarvest =
            element.getElement("CurEstDaysToHarvest").firstChild.toString();
        origDaysDiffActual =
            element.getElement("OrigDaysDiffActual").firstChild.toString();
        curEstDaysDiffActual =
            element.getElement("CurEstDaysDiffActual").firstChild.toString();
        origYield = element.getElement("OrigYield").firstChild.toString();
        harvestableAcres =
            (double.parse(netAcres) - double.parse(lostAcres)).toString();
      },
    );

    return PlantingDetail(
        wetDate: wetDate,
        plantingDate: plantingDate,
        currHarvestDate: currHarvestDate,
        commodityDesc: commodity,
        commodityDescSpanish: commoditySp);
  }
}
