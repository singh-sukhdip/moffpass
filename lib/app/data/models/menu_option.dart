import 'package:flutter/material.dart';

class MenuOptionModel {
  IconData? iconData;
  String value;
  VoidCallback? onTap;

  MenuOptionModel(
      {this.iconData = Icons.home, required this.value, this.onTap});
}
