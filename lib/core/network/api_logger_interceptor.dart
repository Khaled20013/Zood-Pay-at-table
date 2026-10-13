import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only Dio logger. Plain text (no ANSI): Flutter's console prints
/// escape codes literally. Card secrets are redacted.
class ApiLoggerInterceptor extends Interceptor {
  ApiLoggerInterceptor();

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _printBlock(
      title: 'REQUEST  ${options.method.toUpperCase()}',
      url: options.uri.toString(),
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode ?? 0;
    _printBlock(
      title: 'RESPONSE $status  ${response.requestOptions.method.toUpperCase()}',
      url: response.requestOptions.uri.toString(),
      body: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final label = status == null ? err.type.name : '$status';
    _printBlock(
      title: 'ERROR $label  ${err.requestOptions.method.toUpperCase()}',
      url: err.requestOptions.uri.toString(),
      body: err.response?.data,
      note: err.message,
    );
    handler.next(err);
  }

  Object? _sanitize(Object? data) {
    if (data == null) return null;
    if (data is FormData) {
      return '<multipart: ${data.fields.length} fields, ${data.files.length} files>';
    }
    if (data is List) {
      return [for (final item in data) _sanitize(item)];
    }
    if (data is Map) {
      return {
        for (final entry in data.entries)
          entry.key.toString(): _sanitizeValue(
            entry.key.toString(),
            entry.value,
          ),
      };
    }
    return data;
  }

  Object? _sanitizeValue(String key, Object? value) {
    final lower = key.toLowerCase();
    if (value is Map || value is List) return _sanitize(value);
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

  String _pretty(Object? value) {
    try {
      return _encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  void _printBlock({
    required String title,
    required String url,
    Object? body,
    String? note,
  }) {
    final lines = <String>[
      '┌─ $title',
      '│ $url',
    ];
    if (note != null && note.isNotEmpty) {
      lines.add('│ $note');
    }
    final sanitized = _sanitize(body);
    if (sanitized != null) {
      lines.add('│');
      for (final line in _pretty(sanitized).split('\n')) {
        lines.add('│ $line');
      }
    }
    lines.add('└────────────────────────────────────────');
    for (final line in lines) {
      debugPrint(line);
    }
  }
}
