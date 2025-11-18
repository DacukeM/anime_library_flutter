import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'anime_data_source_network.dart';

part 'anime_recommendations_provider.g.dart';

@riverpod
class AnimeRecommendationsProvider extends _$AnimeRecommendationsProvider {
  static const String tag = '+++AnimeRecommendationsProvider';
  final _animeDataSource = getIt<AnimeDataSourceNetwork>();
  CancelToken? _cancelToken;

  @override
  FutureOr<List<AnimeRecommendation>?> build(int? id) => null;

  Future<void> fetchAnimePicturesById(int? id) async {
    print('+++ id = $id');
    if (id == null) return;

    _cancelToken?.cancel("Cancel by user");
    _cancelToken = CancelToken();

    state = const AsyncLoading();

    print('+++ get anime by id = ${id}');
    try {
      final result = await _animeDataSource.getAnimeRecommendationsById(
        id: id,
        cancelToken: _cancelToken,
      );

      print('+++ anime recommendations fetched ${result}');

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
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
