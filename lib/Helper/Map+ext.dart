import 'dart:convert';

extension MapExt on Map {
  String toStringExt() {
    return jsonEncode(this);
  }
}
