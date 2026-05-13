import 'package:get_it/get_it.dart';
import 'package:inventory_app/core/constants/api_constants.dart';
import 'package:inventory_app/features/stock_in/data/datasource/stock_in_client.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  const String baseUrl = '${ApiConstants.baseUrl}${ApiConstants.prefixApi}';

  getIt.registerLazySingleton<StockInClient>(
    () => StockInClient(baseUrl: baseUrl),
  );

  getIt.registerLazySingleton<StockInRepository>(
    () => StockInRepositoryImpl(getIt<StockInClient>()),
  );
}
