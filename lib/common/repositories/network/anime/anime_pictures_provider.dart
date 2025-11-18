import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'anime_data_source_network.dart';

part 'anime_pictures_provider.g.dart';

@riverpod
class AnimePicturesProvider extends _$AnimePicturesProvider {
  static const String tag = '+++AnimePicturesProvider';
  final _animeDataSource = getIt<AnimeDataSourceNetwork>();
  CancelToken? _cancelToken;

  @override
  FutureOr<List<Images>?> build(int? id) => null;

  Future<void> fetchAnimePicturesById(int? id) async {
    print('+++ id = $id');
    if (id == null) return;

    _cancelToken?.cancel("Cancel by user");
    _cancelToken = CancelToken();

    state = const AsyncLoading();

    print('+++ get anime by id = ${id}');
    final result = await _animeDataSource.getAnimePicturesById(
      id: id,
      cancelToken: _cancelToken,
    );

    print('+++ anime pictures fetched ${result}');

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
