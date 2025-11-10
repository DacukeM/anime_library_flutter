import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'top_data_source_network.dart';

part 'top_anime_pagination.g.dart';

@riverpod
class TopAnimePagination extends _$TopAnimePagination {
  static const String tag = '+++TopAnimePagination';
  final _topDataSource = getIt<TopDataSourceNetwork>();
  List<Anime> _anime = [];
  int _page = 1;
  bool _hasNextPage = true;
  bool _isLoading = false;
  bool _hasError = false;
  int _totalProducts = 0;

  List<Anime> get anime => _anime;

  bool get isLoading => _isLoading;

  bool get hasNextPage => _hasNextPage;

  bool get hasError => _hasError;

  int get totalProducts => _totalProducts;

  @override
  FutureOr<void> build() {}

  Future<void> fetchTopAnime() async {
    if (_isLoading || !_hasNextPage) return;
    _isLoading = true;
    _hasError = false;

    state = const AsyncLoading();

    final result = await _topDataSource.getTopAnime(page: _page);

    _isLoading = false;
    result.when(
      success: (data) {
        _hasNextPage = data.pagination.hasNextPage;
        _anime = data.data;
        _page++;
        state = AsyncData(null);
      },
      error: (error) {
        _hasError = true;
        state = AsyncError(error, StackTrace.current);
      },
    );
  }
}
