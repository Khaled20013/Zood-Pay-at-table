// ignore_for_file: camel_case_types, avoid_print

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../Constants.dart';
import 'Configs/AppConfig.dart';

enum kLogType { debug, info, warning, error, trace, json, print }

var logger = Logger(
  printer: PrettyPrinter(colors: false, noBoxingByDefault: true),
);

void kLog(Object? msg,
    {String? name, int methodCount = 0, kLogType logType = kLogType.debug}) {
  if (!kDebugMode) {
    return;
  }

  logger = Logger(
    printer: PrettyPrinter(
      methodCount: methodCount,
      colors: false,
      noBoxingByDefault: true,
    ),
  );

  if (logType == kLogType.debug) {
    logger.d(msg);
  } else if (logType == kLogType.info) {
    logger.i(msg);
  } else if (logType == kLogType.warning) {
    logger.w(msg);
  } else if (logType == kLogType.error) {
    logger.e(msg, stackTrace: StackTrace.current);
  } else if (logType == kLogType.trace) {
    logger.t(msg);
  } else if (logType == kLogType.json) {
    log("$msg");
  } else if (logType == kLogType.print) {
    print("print : $msg");
  }
}

void kLogJson(
    {required String cashKey,
    required String url,
    required String body,
    required String response,
    required String requestType}) {
  if (!AppConfig.enableNetworkLogs) return;
  String json = """
 $cashKey
 --------------------------------------
$requestType
 $url
 $body
 --------------------------------------
 ${printResponse ? response : ""}

 """;

  kLog(json, logType: kLogType.json, methodCount: 100);
}

/// Copy of [data] safe to log: card number, CVC and passwords are masked.
Object? sanitizeForLog(Object? data) {
  if (data is List) {
    return [for (final item in data) sanitizeForLog(item)];
  }
  if (data is Map) {
    return {
      for (final entry in data.entries)
        entry.key.toString(): _sanitizeValue(entry.key.toString(), entry.value),
    };
  }
  return data;
}

Object? _sanitizeValue(String key, Object? value) {
  final lower = key.toLowerCase();
  if (value is Map || value is List) return sanitizeForLog(value);
  if (lower == 'cvc' || lower == 'cvv' || lower == 'password') {
    return '•••';
  }
  if (lower == 'number' && value is String) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return '•••• ${digits.substring(digits.length - 4)}';
    }
    return '••••';
  }
  return value;
}
