import '../../Constants.dart';
import '../../Helper/ApiServices/Apis/ApiBase.dart';
import '../../Helper/ApiServices/Base/ApiEndpoints.dart';
import '../../Helper/ApiServices/Base/ApiRequest.dart';
import '../../Helper/ApiServices/Base/DemoDataPolicy.dart';
import '../../Helper/ApiServices/Base/KApiResponse.dart';
import '../../Helper/Configs/kcore.dart';
import '../../Helper/Errors/AppException.dart';
import '../CoreBaseModel.dart';
import '../TableSession/TableSessionModel.dart';
import 'DummyMenuData.dart';
import 'ProductModel.dart';

class MenuApi extends CoreBaseModel {
  /// Loads categories, products and modifiers for [session] in parallel and
  /// joins them. On success `data` is a `List<ProductModel>`; otherwise
  /// `error` is the first failure.
  static Future<KApiResponse> getAll({
    required TableSessionModel session,
  }) async {
    final ref = session.businessReference;
    final responses = await Future.wait([
      _get(ApiEndpoints.categories, ref, DummyMenuData.categories),
      _get(ApiEndpoints.products, ref, DummyMenuData.products),
      _get(ApiEndpoints.modifiers, ref, DummyMenuData.modifiers),
    ]);
    for (final response in responses) {
      if (response.error != null) return response;
    }
    final [categories, products, modifiers] = responses;
    try {
      products.data = ProductModel.fromMenuJson(
        categories: categories.responseMap,
        products: products.responseMap,
        modifiers: modifiers.responseMap,
        languageCode: lang,
      );
    } catch (_) {
      products.error = const UnexpectedException();
    }
    return products;
  }

  static Future<KApiResponse> _get(
    String endpoint,
    String businessReference,
    Map<String, dynamic> Function() dummy,
  ) {
    final request = ApiRequest()
      ..url = "${config.url}/$endpoint"
      ..header = ApiBase().getHeader()
      ..type = RequestType.get
      ..query = {'business_reference': businessReference}
      ..cashKey = "pat_${endpoint.split('/').last}_$businessReference";
    return DemoDataPolicy.run(request: request, dummy: dummy);
  }
}
