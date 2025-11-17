import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'anime_data_source_network.dart';

part 'anime_statistics_provider.g.dart';

@riverpod
class AnimeStatisticsProvider extends _$AnimeStatisticsProvider {
  static const String tag = '+++AnimeStatisticsProvider';
  final _animeDataSource = getIt<AnimeDataSourceNetwork>();
  CancelToken? _cancelToken;

  @override
  FutureOr<AnimeStatistics?> build() => null;

  Future<void> fetchAnimeStatisticsById(int? id) async {
    print('+++ id = $id');
    if (id == null) return;

    _cancelToken?.cancel("Cancel by user");
    _cancelToken = CancelToken();

    state = const AsyncLoading();

    print('+++ get anime by id = ${id}');
    final result = await _animeDataSource.getAnimeStatisticsById(
      id: id,
      cancelToken: _cancelToken,
    );

    print('+++ anime statistics fetched ${result}');

    _cancelToken = null;

    result.when(
      success: (data) {
        data.data;
        state = AsyncData(data.data);
      },
      error: (error) {
        state = AsyncError(error, StackTrace.current);
      },
    );
  }
}
