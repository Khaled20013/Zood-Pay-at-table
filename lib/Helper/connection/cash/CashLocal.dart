import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import 'model/local_data.dart';

// late final SharedPreferences? instance;
const String cashPrimaryKey =
    "primary"; // use this start with key and will not deleted with clear cash

class CashLocal {
  // static CashLocal get instance {
  //   _instance = CashLocal._init();

  //   return _instance!;
  // }

  // static CashLocal? _instance;
  // CashLocal._init();

  // static late SharedPreferences sharedPreferences;

  // static init() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  // }

  static SharedPreferences? instance;

  static Future<SharedPreferences> get _instance async =>
      instance ??= await SharedPreferences.getInstance();

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    instance = await _instance;
    return instance!;
  }

  // ================ ================ ================ ================ ================

  static Future<bool> _writeModelInJson(dynamic body, String url,
      {Duration duration = const Duration(hours: 0)}) async {
    try {
      BaseLocal local =
          BaseLocal(model: body, time: DateTime.now().add(duration));
      final json = jsonEncode(local.toJson());
      if (body != null && json.isNotEmpty) {
        var prefs = await _instance;
        return await prefs.setString(url, json);
      }
    } catch (e) {
      log("_writeModelInJson: $e");
    }
    return false;
  }

  static Future<String> _getModelString(String url) async {
    try {
      // var perf = CashLocal.instance;
      var prefs = await _instance;
      final jsonString = prefs.getString(url);
      if (jsonString != null) {
        final jsonModel = jsonDecode(jsonString);

        return BaseLocal.fromJson(jsonModel).model ?? "";
      }
    } catch (e) {
      log("_getModelString : $e");
    }
    return "";
  }

  static Future<bool> _removeAllLocalData(String url) async {
    try {
      // var prefs = await _instance;

      instance!.getKeys().removeWhere((element) => element.contains(url));
    } catch (e) {
      log("_removeAllLocalData : $e");
    }
    return true;
  }

  static Future<bool> removeAll() async {
    try {
      var prefs = await _instance;
      final listKeys = prefs.getKeys().toList();
      for (var element in listKeys) {
        if (element.startsWith(cashPrimaryKey) == false) {
          final removed = await prefs.remove(element);
          log("Clear cash key:$element -> $removed");
        }
      }
      return true;
    } catch (e) {
      log("removeAll error : $e");
      return false;
    }
  }

  static Future<bool> _removeModel(String url) async {
    try {
      // var prefs = await _instance;

      return await instance!.remove(url);
    } catch (e) {
      log("$e");
      return false;
    }
  }

  // ================ ================ ================ ================ ================

  static Future<String> getString(String key) async {
    // var perf = CashLocal.instance;

    return _getModelString(key);
  }

  static Future<bool> removeCacheContains(String key) async {
    // var perf = CashLocal.instance;

    return await _removeAllLocalData(key);
  }

  static Future<bool> removeCache(String key) async {
    // var perf = CashLocal.instance;
    return await _removeModel(key);
  }

  static Future<bool> saveCash(String key, Object model,
      {Duration duration = const Duration(hours: 0)}) async {
    // var perf = CashLocal.instance;

    return await _writeModelInJson(model, key, duration: duration);
  }

  static Future<bool> save(String key, Map<String, dynamic> model,
      {Duration duration = const Duration(hours: 0)}) async {
    String jsonStr = json.encode(model);

    return await _writeModelInJson(jsonStr, key, duration: duration);
  }

  static Future<Map<String, dynamic>> get(String key) async {
    String jsonStr = await _getModelString(key);
    Map<String, dynamic> map = json.decode(jsonStr);

    return map;
  }
}
