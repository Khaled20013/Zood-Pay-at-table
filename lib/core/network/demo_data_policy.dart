import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';

/// Maps a non-2xx response to the endpoint's specific failure, or null to
/// fall back to [ServerException].
typedef StatusMapper = AppException? Function(int status, String? message);

/// Decides whether a repository call goes to the API or serves the bundled
/// demo data, and maps transport failures to [AppException]s.
class DemoDataPolicy {
  const DemoDataPolicy({
    required this.useDummyData,
    this.fallbackToDummyOnNetworkError = kDebugMode,
    this.simulatedLatency = const Duration(milliseconds: 700),
  });

  final bool useDummyData;

  /// Lets demos keep working when the API host is unreachable.
  final bool fallbackToDummyOnNetworkError;
  final Duration simulatedLatency;

  /// [allowDummyFallback] must be false for calls with side effects (the
  /// order charges a card), so a network error never fakes a success.
  Future<T> run<T>({
    required Future<T> Function() remote,
    required T Function() dummy,
    StatusMapper? onStatus,
    bool allowDummyFallback = true,
  }) async {
    if (useDummyData) {
      if (simulatedLatency > Duration.zero) {
        await Future<void>.delayed(simulatedLatency);
      }
      return dummy();
    }
    try {
      return await remote();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null) {
        if (isMissingRoute(status, e.response?.data)) {
          debugPrint(
            'DemoDataPolicy: ${e.requestOptions.path} is not deployed.',
          );
          throw const ServiceUnavailableException();
        }
        final message = serverMessageOf(e.response?.data);
        throw onStatus?.call(status, message) ?? ServerException(message);
      }
      if (allowDummyFallback &&
          fallbackToDummyOnNetworkError &&
          _isConnectivityError(e)) {
        debugPrint('DemoDataPolicy: API unreachable, serving demo data.');
        return dummy();
      }
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('DemoDataPolicy: unexpected error $e');
      throw const UnexpectedException();
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

  bool _isConnectivityError(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.unknown => true,
    _ => false,
  };
}
