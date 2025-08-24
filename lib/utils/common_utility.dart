import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

extension HexToColor on String {
  Color hexToColor() {
    try {
      return Color(int.parse(replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.transparent;
    }
  }
}

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
}
