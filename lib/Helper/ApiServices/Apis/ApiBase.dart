import 'dart:async';
import 'dart:developer';

import '../../../Constants.dart';
import '../../connection/http_client.dart';
import '../Base/ApiRequest.dart';
import '../Base/KApiResponse.dart';

class ApiBase {
  static final HttpClientHelper _httpClientHelper = HttpClientHelper();

  /// Every Pay at Table endpoint is public, so there is no auth check.
  static void requestApi(ApiRequest request,
      {final Function(KApiResponse)? onResult}) async {
    var key = request.cashKey;

    try {
      _httpClientHelper.requestUrl(
        request.url,
        request.type,
        headers: request.header,
        body: request.body,
        query: request.query,
        isCaching: request.isCaching,
        returnCaching: request.returnCaching,
        inCachReturnNewData: request.inCachReturnNewData,
        cashKey: key,
        onResult: onResult,
      );
    } catch (e) {
      log("Error in $key  $e");
      onResult!(KApiResponse(null, 500, false));
    }
  }

  /// [requestApi] as a future; completes with the first result (the cached
  /// one when [ApiRequest.returnCaching] is on).
  static Future<KApiResponse> requestAsync(ApiRequest request) {
    final completer = Completer<KApiResponse>();
    requestApi(request, onResult: (response) {
      if (!completer.isCompleted) completer.complete(response);
    });
    return completer.future;
  }

  /// Only CORS-safelisted headers (plus `Content-Type` on writes), so the
  /// web build doesn't need extra preflight permissions.
  Map<String, String> getHeader({bool hasBody = false}) {
    return {
      'Accept': 'application/json',
      'Accept-Language': lang == 'ar' ? 'ar' : 'en',
      if (hasBody) 'Content-Type': 'application/json; charset=utf-8',
    };
  }
}
