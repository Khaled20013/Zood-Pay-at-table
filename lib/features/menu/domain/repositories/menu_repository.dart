import '../../../table_session/domain/entities/table_session.dart';
import '../entities/product.dart';

/// Throws an `AppException` subtype on failure.
abstract interface class MenuRepository {
  Future<List<Product>> getMenu(TableSession session);
}
