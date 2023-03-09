import 'dart:async';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:prodwo_timesheet/preferences/server_settings_preferences.dart';
import 'package:prodwo_timesheet/providers/location_provider.dart';
import 'package:prodwo_timesheet/services/webservices/get_current_work_orders.dart';
import 'package:prodwo_timesheet/services/webservices/webservice_helper/ws_helper.dart';
import 'package:prodwo_timesheet/tools/localizations.dart';

class farmGroupBlocks {
  final String ranch;
  final List<dynamic> blocks;
  final String group;

  farmGroupBlocks({
    this.ranch,
    this.blocks,
    this.group,
  });
}

class UserBlocks {
  String groupBlock;
  int block;
  int group;
  UserBlocks({this.groupBlock, this.block, this.group});
  List<dynamic> listData;

  Future<void> setData() async {
    String userID = await getUserID();
    String blockGroupStr, blockStr, groupStr;
    groupBlock != null
        ? blockGroupStr = '&blockGroup=' + groupBlock
        : blockGroupStr = '';
    block != null ? blockStr = '&block=' + block.toString() : blockStr = '';
    group != null ? groupStr = '&group=' + group.toString() : groupStr = '';
    print(
        "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrderGroupBlocks?userID=$userID" +
            blockGroupStr +
            blockStr +
            groupStr);
    try {
      String url =
          "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrderGroupBlocks?userID=$userID" +
              blockGroupStr +
              blockStr +
              groupStr;
      final response = await httpWrapper(
        http.get(Uri.parse(url)),
      );
      var responseData = json.decode(response.body);
      listData = responseData;
    } catch (e) {
      print(e);
    }
  }

  List<dynamic> getData() => listData;
}

Future<String> getUserID() async => ServerSettingsPreferences.currentUserID;

Future<List<farmGroupBlocks>> onlyFarmBlocks() async {
  String name = await getUserID();

  String url = //to get user ranches
      "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/FarmGroupRanchBlocks/get?userID=$name";
  final response = await http.get(Uri.parse(url)).timeout(
        const Duration(
          seconds: 15,
        ),
      );
  var responseData = json.decode(response.body);
  List<farmGroupBlocks> groupBlocks = [];
  for (var single in responseData) {
    if (single['Group'].trim() == LocationNotifier.selectedLocation) {
      // List<dynamic> blks = await getAllBlocks("01" + single["block"]);
      List<dynamic> blks = await getActiveBlocks("01", single["block"]);
      farmGroupBlocks block =
          farmGroupBlocks(ranch: single["block"], blocks: blks);
      groupBlocks.add(block);
    }
  }

  return groupBlocks;
}

Future<List<dynamic>> genericGet(
    {String blockGroup, int block, int group}) async {
  String userID = await getUserID();
  String blockGroupStr, blockStr, groupStr;
  blockGroup != null
      ? blockGroupStr = '&blockGroup=' + blockGroup
      : blockGroupStr = '';
  block != null ? blockStr = '&block=' + block.toString() : blockStr = '';
  group != null ? groupStr = '&group=' + group.toString() : groupStr = '';

  String url = //to get user ranches
      "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/DBR_GetWorkOrderGroupBlocks?userID=$userID" +
          blockGroupStr +
          blockStr +
          groupStr;
  final response = await http.get(Uri.parse(url)).timeout(
        Duration(
          seconds: 15,
        ),
      );
  var responseData = json.decode(response.body);
  return responseData;
}

Future<List<farmGroupBlocks>> farmBlocksByGroup(String location) async {
  UserBlocks userBlocks = UserBlocks(groupBlock: location, block: 0);
  await userBlocks.setData();

  List<farmGroupBlocks> groupBlocks = [];
  for (var item in userBlocks.getData()) {
    // List<dynamic> blks = await getAllBlocks("01" + item['blocks'].trim());
    List<dynamic> blks = await getActiveBlocks("01", item['blocks'].trim());

    farmGroupBlocks block =
        farmGroupBlocks(ranch: item['blocks'].trim(), blocks: blks);
    groupBlocks.add(block);
  }

  return groupBlocks;
}

Future<List<farmGroupBlocks>> uniqueFarmBlocks() async {
  UserBlocks userBlocks = UserBlocks(block: 0);
  await userBlocks.setData();

  List<farmGroupBlocks> groupBlocks = [];
  for (var single in userBlocks.getData()) {
    // List<dynamic> blks = await getAllBlocks("01" + single["blocks"]);
    List<dynamic> blks = await getActiveBlocks("01", single["blocks"]);
    groupBlocks
        .add(farmGroupBlocks(ranch: single["blocks"].trim(), blocks: blks));
  }
  return groupBlocks;
}

Future<List<dynamic>> myBlocks() async {
  try {
    UserBlocks userBlocks = UserBlocks();
    await userBlocks.setData();
    if (LocationNotifier.selectedLocation.isEmpty) {
      await GetWorkOrderWS().loadGroup();
    }
    Set groupBlocks = {};
    if (LocationNotifier.selectedLocation.length > 1) {
      for (var item in userBlocks.getData()) {
        groupBlocks.add(item);
      }
    } else {
      for (var item in userBlocks.getData()) {
        if (item['groups'].trim() == LocationNotifier.selectedLocation[0]) {
          groupBlocks.add(item);
        }
      }
    }
    groupBlocks = LinkedHashSet.from(SplayTreeSet.of(
        groupBlocks, (a, b) => a["blocks"].compareTo(b["blocks"])));
    List<dynamic> tempList = groupBlocks.toList();
    tempList.insert(0, {
      "blocks": AppL10N.localStr['all'],
      "DBFarmingActvity": tempList[0]["DBFarmingActvity"],
      "groups": AppL10N.localStr['all']
    });

    return tempList;
  } catch (e) {
    return List<dynamic>.empty();
  }
}

Future<List> getAllBlocks(String input) async {
  String url = //to get user ranches
      "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/RanchBlockPop/get?nums=$input";
  final response = await http.get(Uri.parse(url)).timeout(
        const Duration(
          seconds: 15,
        ),
      );

  var responseData = json.decode(response.body);
  List ranchblockPop = [];
  for (String block in responseData) {
    ranchblockPop.add(block);
  }
  return ranchblockPop;
}

Future<List> getActiveBlocks(String locationID, String ranch) async {
  String date =
      DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()).toString();
  String url = //to get user ranches
      "http://${ServerSettingsPreferences.webHost}:8080/DBCWebService/PRODWO/aimsGetRanchBlocksByDate?locationID=$locationID&ranch=$ranch&applyDate=$date";
  final response = await http.get(Uri.parse(url)).timeout(
        const Duration(
          seconds: 15,
        ),
      );

  var responseData = json.decode(response.body);
  List ranchblockPop = [];
  for (var block in responseData) {
    ranchblockPop.add(locationID + ranch + block['Block'].trim());
  }
  return ranchblockPop;
}

Future<List> listBlocks() async {
  //Returns all unique blocks.

  UserBlocks userBlocks = UserBlocks(block: 0);
  await userBlocks.setData();
  List mapEntries = userBlocks.getData();
  return List.generate(mapEntries.length, (i) => mapEntries[i]["blocks"]);
}

Future<List> listSpecificBlocks(String group) async {
  //Returns all blocks an activity or farming group has.

  UserBlocks userBlocks = UserBlocks(groupBlock: group, block: 0);
  await userBlocks.setData();
  List mapEntries = userBlocks.getData();
  return List.generate(mapEntries.length, (i) => mapEntries[i]["blocks"]);
}

Future<List<dynamic>> getAllFarmGroups(bool includeAll) async {
  UserBlocks userBlocks = UserBlocks(group: 0);
  await userBlocks.setData();
  Set<dynamic> farmGroups = {};
  for (var entry in userBlocks.getData()) {
    farmGroups.add(entry);
  }
  farmGroups = sortbyGroups(farmGroups);
  includeAll
      ? farmGroups.length > 1
          ? farmGroups
              .add({"DBFarmingActvity": 5, "groups": AppL10N.localStr['all']})
          : null
      : null;

  return farmGroups.toList();
}

Set sortbyGroups(Set groups) {
  List sortedGroups = List.empty(growable: true);
  sortedGroups = groups.toList();
  sortedGroups.sort((a, b) => a["groups"].compareTo(b["groups"]));
  sortedGroups
      .sort((a, b) => a["DBFarmingActvity"].compareTo(b["DBFarmingActvity"]));
  return sortedGroups.toSet();
}
