import 'package:dio/dio.dart';

import '../../../../utils/result.dart';
import '../../../../utils/utils.dart';
import '../responses/models.dart';
import 'top_client.dart';

class TopDataSourceNetwork {
  final TopClient _topClient;

  TopDataSourceNetwork(this._topClient);

  Future<Result<PaginatedResponse<Anime>>> getTopAnime({
    int page = 1,
    String? animeSearchQueryType,
    String? filter,
    String? rating,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      () => _topClient.getTopAnime(
        page,
        animeSearchQueryType: animeSearchQueryType,
        topAnimeFilter: filter,
        rating: rating,
        cancelToken: cancelToken,
      ),
      "getTopAnime",
    );
  }
}
