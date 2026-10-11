import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/localization/locale_cubit.dart';
import 'core/network/demo_data_policy.dart';
import 'core/network/dio_client.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/checkout/data/datasources/orders_api.dart';
import 'features/checkout/data/repositories/order_repository_impl.dart';
import 'features/checkout/domain/repositories/order_repository.dart';
import 'features/checkout/presentation/cubit/checkout_cubit.dart';
import 'features/menu/data/datasources/menu_api.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/domain/repositories/menu_repository.dart';
import 'features/menu/presentation/cubit/menu_cubit.dart';
import 'features/table_session/data/datasources/table_session_api.dart';
import 'features/table_session/data/repositories/table_session_repository_impl.dart';
import 'features/table_session/domain/repositories/table_session_repository.dart';
import 'features/table_session/presentation/cubit/table_session_cubit.dart';

final GetIt sl = GetIt.instance;

void configureDependencies({SharedPreferences? prefs}) {
  String languageCode() => sl<LocaleCubit>().state.languageCode;

  sl
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(prefs: prefs))
    ..registerLazySingleton<DioClient>(
      () => DioClient(languageCode: languageCode),
    )
    ..registerLazySingleton<DemoDataPolicy>(
      () => const DemoDataPolicy(useDummyData: AppConfig.useDummyData),
    )
    ..registerLazySingleton<TableSessionRepository>(
      () => TableSessionRepositoryImpl(
        api: TableSessionApi(sl<DioClient>().dio),
        policy: sl<DemoDataPolicy>(),
        languageCode: languageCode,
      ),
    )
    ..registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(
        api: MenuApi(sl<DioClient>().dio),
        policy: sl<DemoDataPolicy>(),
        languageCode: languageCode,
      ),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(
        api: OrdersApi(sl<DioClient>().dio),
        policy: sl<DemoDataPolicy>(),
        languageCode: languageCode,
      ),
    )
    // Session, menu and cart outlive individual routes.
    ..registerLazySingleton<TableSessionCubit>(
      () => TableSessionCubit(sl<TableSessionRepository>()),
    )
    ..registerLazySingleton<MenuCubit>(() => MenuCubit(sl<MenuRepository>()))
    ..registerLazySingleton<CartCubit>(CartCubit.new)
    ..registerFactory<CheckoutCubit>(
      () => CheckoutCubit(repository: sl<OrderRepository>()),
    );
}
