import 'package:flutter/material.dart';

//? Tato funkce přidává novou metodu třídě Color pro převod na Hex kód:
extension HexColor on Color {
  String toHex({bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${(a * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
        '${r.round().toRadixString(16).padLeft(2, '0')}'
        '${g.round().toRadixString(16).padLeft(2, '0')}'
        '${b.round().toRadixString(16).padLeft(2, '0')}';
  }
}
