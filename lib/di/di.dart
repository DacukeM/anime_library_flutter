import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../common/repositories/network/top/top_client.dart';
import '../common/repositories/network/top/top_data_source_network.dart';
import '../utils/constants.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerLazySingleton<Dio>(() {
    return Dio(
      BaseOptions(
        baseUrl: Constants.baseUrl,
        connectTimeout: const Duration(seconds: Constants.timeout),
        receiveTimeout: const Duration(seconds: Constants.timeout),
        validateStatus: (status) => true,
      ),
    );
  });

  getIt.registerSingleton<TopClient>(TopClient(getIt.get<Dio>()));

  getIt.registerSingleton<TopDataSourceNetwork>(
    TopDataSourceNetwork(getIt.get<TopClient>()),
  );
}
