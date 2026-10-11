import '../../../../core/network/demo_data_policy.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/dummy_menu_data.dart';
import '../datasources/menu_api.dart';
import '../models/menu_mapper.dart';
import '../models/product_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({
    required MenuApi api,
    required DemoDataPolicy policy,
    String Function()? languageCode,
  }) : _api = api,
       _policy = policy,
       _languageCode = languageCode ?? _english;

  final MenuApi _api;
  final DemoDataPolicy _policy;

  /// Current app language, used to pick `name` or `name_localized`.
  final String Function() _languageCode;
  static String _english() => 'en';

  @override
  Future<List<Product>> getMenu(TableSession session) async {
    final ref = session.businessReference;
    final (categories, products, modifiers) = await _policy
        .run<(CategoriesResponse, ProductsResponse, ModifiersResponse)>(
          remote: () async {
            // Rethrows the first DioException as-is, so status codes map.
            final responses = await Future.wait<Object>([
              _api.getCategories(ref),
              _api.getProducts(ref),
              _api.getModifiers(ref),
            ], eagerError: true);
            return (
              responses[0] as CategoriesResponse,
              responses[1] as ProductsResponse,
              responses[2] as ModifiersResponse,
            );
          },
          dummy: () => (
            DummyMenuData.categories(),
            DummyMenuData.products(),
            DummyMenuData.modifiers(),
          ),
        );
    return MenuMapper.toProducts(
      categories: categories.data,
      products: products.data,
      modifiers: modifiers.data,
      languageCode: _languageCode(),
    );
  }
}
