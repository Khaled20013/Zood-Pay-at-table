import 'package:flutter/foundation.dart';

import '../../Configs/AppConfig.dart';
import '../../Errors/AppException.dart';
import '../Apis/ApiBase.dart';
import 'ApiRequest.dart';
import 'KApiResponse.dart';

/// Maps a non-2xx response to the endpoint's specific failure, or null to
/// fall back to [ServerException].
typedef StatusMapper = AppException? Function(int status, String? message);

/// Decides whether a request goes to the API or serves the bundled demo
/// data, and turns failures into [KApiResponse.error].
abstract final class DemoDataPolicy {
  static bool useDummyData = AppConfig.useDummyData;

  /// Lets demos keep working when the API host is unreachable.
  static bool fallbackToDummyOnNetworkError = kDebugMode;
  static Duration simulatedLatency = const Duration(milliseconds: 700);

  /// [allowDummyFallback] must be false for calls with side effects (the
  /// order charges a card), so a network error never fakes a success.
  /// [dummy] may throw an [AppException] to simulate a failure.
  static Future<KApiResponse> run({
    required ApiRequest request,
    required Map<String, dynamic> Function() dummy,
    StatusMapper? onStatus,
    bool allowDummyFallback = true,
  }) async {
    if (useDummyData) {
      if (simulatedLatency > Duration.zero) {
        await Future<void>.delayed(simulatedLatency);
      }
      return _dummy(dummy);
    }
    try {
      final response = await ApiBase.requestAsync(request);
      if (response.success) return response;
      if (response.connectionFailed) {
        if (allowDummyFallback && fallbackToDummyOnNetworkError) {
          debugPrint('DemoDataPolicy: API unreachable, serving demo data.');
          return _dummy(dummy);
        }
        return response..error = const NetworkException();
      }
      final status = response.statusCode;
      final body = response.responseMap;
      if (isMissingRoute(status, body)) {
        debugPrint('DemoDataPolicy: ${request.url} is not deployed.');
        return response..error = const ServiceUnavailableException();
      }
      final message = serverMessageOf(body);
      return response
        ..error = onStatus?.call(status, message) ?? ServerException(message);
    } catch (e) {
      debugPrint('DemoDataPolicy: unexpected error $e');
      return KApiResponse.failure(const UnexpectedException());
    }
  }

  static KApiResponse _dummy(Map<String, dynamic> Function() dummy) {
    try {
      return KApiResponse.fromJson(dummy());
    } on AppException catch (e) {
      return KApiResponse.failure(e);
    }
  }

  /// Laravel's unknown-route `404` (`"The route ... could not be found."`),
  /// which lacks the contract's `success` field.
  static bool isMissingRoute(int status, Object? body) {
    if (status != 404 || body is! Map || body.containsKey('success')) {
      return false;
    }
    final message = serverMessageOf(body) ?? '';
    return message.startsWith('The route ') &&
        message.endsWith('could not be found.');
  }

  /// The `message` of `{ "success": false, "message": "...", "errors": {...} }`.
  static String? serverMessageOf(Object? body) {
    if (body is! Map) return null;
    final message = body['message'];
    if (message is! String) return null;
    final trimmed = message.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
