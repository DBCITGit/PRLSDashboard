import 'package:flutter/material.dart';

class SCBottomBarDetails {
  Color backgroundColor;
  double elevation;
  List<Color> circleColors;
  IconThemeData activeIconTheme;
  IconThemeData iconTheme;
  TextStyle activeTitleStyle;
  TextStyle titleStyle;
  List<SCBottomBarItem> items;
  List<SCItem> circleItems;
  SCActionButtonDetails actionButtonDetails;
  double bnbHeight;

  SCBottomBarDetails(
      {this.items,
      this.circleItems,
      this.bnbHeight,
      this.actionButtonDetails,
      this.activeIconTheme,
      this.iconTheme,
      this.activeTitleStyle,
      this.titleStyle,
      this.circleColors,
      this.backgroundColor,
      this.elevation});
}

class SCActionButtonDetails {
  Color color;
  Icon icon;
  double elevation;
  Function onPressed;

  SCActionButtonDetails(
      {this.color, this.icon, this.elevation, this.onPressed});
}

class SCItem {
  Widget icon;
  void Function() onPressed;

  SCItem({this.icon, this.onPressed});
}

class SCBottomBarItem {
  IconData activeIcon;
  IconData icon;
  String title;
  Function onPressed;

  SCBottomBarItem({this.activeIcon, this.icon, this.title, this.onPressed});
}
