import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/order_models.dart';

part 'orders_api.g.dart';

@RestApi()
abstract class OrdersApi {
  factory OrdersApi(Dio dio, {String? baseUrl}) = _OrdersApi;

  /// Charges the card and creates the order in one call.
  @POST(ApiEndpoints.orders)
  Future<OrderResponse> placeOrder(@Body() OrderRequestModel body);
}
