import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../common/repositories/network/anime/anime_client.dart';
import '../common/repositories/network/anime/anime_data_source_network.dart';
import '../common/repositories/network/rate_limit_interceptor.dart';
import '../common/repositories/network/top/top_client.dart';
import '../common/repositories/network/top/top_data_source_network.dart';
import '../utils/constants/constants.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Constants.baseUrl,
        connectTimeout: const Duration(seconds: Constants.timeout),
        receiveTimeout: const Duration(seconds: Constants.timeout),
        validateStatus: (status) => true,
      ),
    );
    dio.interceptors.add(RateLimitInterceptor());
    return dio;
  });

  getIt.registerSingleton<TopClient>(TopClient(getIt.get<Dio>()));

  getIt.registerSingleton<AnimeClient>(AnimeClient(getIt.get<Dio>()));

  getIt.registerSingleton<TopDataSourceNetwork>(
    TopDataSourceNetwork(getIt.get<TopClient>()),
  );

  getIt.registerSingleton<AnimeDataSourceNetwork>(
    AnimeDataSourceNetwork(getIt.get<AnimeClient>()),
  );
}
