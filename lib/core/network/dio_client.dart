import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'api_endpoints.dart';

/// Builds the [Dio] instance shared by the public Pay at Table services.
/// It carries no auth token and no 401 handling: every endpoint is public.
class DioClient {
  DioClient({
    String baseUrl = AppConfig.apiBaseUrl,
    String Function()? languageCode,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: ApiEndpoints.connectTimeout,
           receiveTimeout: ApiEndpoints.receiveTimeout,
           contentType: Headers.jsonContentType,
           headers: const {Headers.acceptHeader: Headers.jsonContentType},
         ),
       ) {
    dio.interceptors.add(
      _LocaleInterceptor(
        languageCode ?? () => PlatformDispatcher.instance.locale.languageCode,
      ),
    );
    if (kDebugMode && AppConfig.enableNetworkLogs) {
      dio.interceptors.add(
        // Request bodies stay out of the logs: the order request carries
        // card details.
        PrettyDioLogger(requestHeader: true, compact: true),
      );
    }
  }

  final Dio dio;
}

class _LocaleInterceptor extends Interceptor {
  _LocaleInterceptor(this._languageCode);

  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode() == 'ar' ? 'ar' : 'en';
    handler.next(options);
  }
}
