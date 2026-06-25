import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../di/di.dart';
import '../responses/models.dart';
import 'top_data_source_network.dart';

part 'top_anime_pagination.g.dart';

@riverpod
class TopAnimePagination extends _$TopAnimePagination {
  static const String tag = '+++TopAnimePagination';
  final _topDataSource = getIt<TopDataSourceNetwork>();
  CancelToken? _cancelToken;
  List<Anime> _anime = [];
  int _page = 1;
  bool _hasNextPage = true;
  bool _isLoading = false;
  bool _hasError = false;
  int _totalProducts = 0;

  // Filter states
  String? _type;
  String? _filter;
  String? _rating;
  bool? _sfw;

  List<Anime> get anime => _anime;

  bool get isLoading => _isLoading;

  bool get hasNextPage => _hasNextPage;

  bool get hasError => _hasError;

  int get totalProducts => _totalProducts;

  // Getters for filters
  String? get type => _type;
  String? get filter => _filter;
  String? get rating => _rating;
  bool? get sfw => _sfw;

  @override
  FutureOr<void> build() {}

  Future<void> fetchTopAnime() async {
    if (_isLoading || !_hasNextPage) return;
    _isLoading = true;
    _hasError = false;

    _cancelToken?.cancel("Cancel by user");
    _cancelToken = CancelToken();

    state = const AsyncLoading();

    final result = await _topDataSource.getTopAnime(
      page: _page,
      animeSearchQueryType: _type,
      filter: _filter,
      rating: _rating,
      sfw: _sfw,
      cancelToken: _cancelToken,
    );

    _isLoading = false;
    _cancelToken = null;

    result.when(
      success: (data) {
        _hasNextPage = data.pagination.hasNextPage;
        _anime.addAll(data.data);
        _page++;
        state = AsyncData(null);
      },
      error: (error) {
        _hasError = true;
        state = AsyncError(error, StackTrace.current);
      },
    );
  }

  Future<void> refreshTopAnime() async {
    _hasNextPage = true;
    _anime = [];
    _page = 1;
    await fetchTopAnime();
  }

  void setType(String? value) {
    if (_type != value) {
      _type = value;
      refreshTopAnime();
    }
  }

  void setFilter(String? value) {
    if (_filter != value) {
      _filter = value;
      refreshTopAnime();
    }
  }

  void setRating(String? value) {
    if (_rating != value) {
      _rating = value;
      refreshTopAnime();
    }
  }

  void setSfw(bool? value) {
    if (_sfw != value) {
      _sfw = value;
      refreshTopAnime();
    }
  }

  void clearFilters() {
    if (_type != null || _filter != null || _rating != null || _sfw != null) {
      _type = null;
      _filter = null;
      _rating = null;
      _sfw = null;
      refreshTopAnime();
    }
  }

  Future<void> loadMoreTopAnime() async {
    if (_isLoading || !_hasNextPage) return;
    await fetchTopAnime();
  }
}
