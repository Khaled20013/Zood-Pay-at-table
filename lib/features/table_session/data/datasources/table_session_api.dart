import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/table_session_model.dart';

part 'table_session_api.g.dart';

@RestApi()
abstract class TableSessionApi {
  factory TableSessionApi(Dio dio, {String? baseUrl}) = _TableSessionApi;

  @GET(ApiEndpoints.qr)
  Future<QrResponse> getQr(@Path('qrId') String qrId);
}
