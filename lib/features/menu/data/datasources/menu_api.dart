import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';

part 'menu_api.g.dart';

@RestApi()
abstract class MenuApi {
  factory MenuApi(Dio dio, {String? baseUrl}) = _MenuApi;

  @GET(ApiEndpoints.categories)
  Future<CategoriesResponse> getCategories(
    @Query('business_reference') String businessReference,
  );

  @GET(ApiEndpoints.products)
  Future<ProductsResponse> getProducts(
    @Query('business_reference') String businessReference,
  );

  @GET(ApiEndpoints.modifiers)
  Future<ModifiersResponse> getModifiers(
    @Query('business_reference') String businessReference,
  );
}
