import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'anime_data_source_network.dart';

part 'anime_by_id_provider.g.dart';

@riverpod
class AnimeByIdProvider extends _$AnimeByIdProvider {
  static const String tag = '+++AnimeByIdProvider';
  final _animeDataSource = getIt<AnimeDataSourceNetwork>();
  CancelToken? _cancelToken;
  bool _isLoading = false;
  bool _hasError = false;
  Anime? _anime;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  Anime? get anime => _anime;

  @override
  FutureOr<void> build(int? id) {}

  Future<void> setInitialAnime(Anime? anime) async {
    _anime = anime;
    state = AsyncData(null);
  }

  Future<void> fetchAnimeById(int? id) async {
    print('+++ id = $id');
    if (id == null) return;
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;

    _cancelToken?.cancel("Cancel by user");
    _cancelToken = CancelToken();

    state = const AsyncLoading();

    print('+++ get anime by id = ${id}');
    final result = await _animeDataSource.getAnimeById(
      id: id,
      cancelToken: _cancelToken,
    );

    print('+++ anime fetched ${result}');

    _isLoading = false;
    _cancelToken = null;

    result.when(
      success: (data) {
        _anime = data.data;
        print('+++ _anime = ${_anime?.malId}');
        state = AsyncData(null);
      },
      error: (error) {
        _hasError = true;
        state = AsyncError(error, StackTrace.current);
      },
    );
  }
}
