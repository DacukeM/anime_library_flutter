import 'package:dio/dio.dart';

import '../../../../utils/result.dart';
import '../../../../utils/utils.dart';
import '../responses/models.dart';
import 'anime_client.dart';

class AnimeDataSourceNetwork {
  final AnimeClient _animeClient;

  AnimeDataSourceNetwork(this._animeClient);

  Future<Result<DataResponse<Anime>>> getAnimeById({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      () => _animeClient.getAnimeById(id, cancelToken: cancelToken),
      "getAnimeById",
    );
  }

  Future<Result<AnimeStatisticsResponse>> getAnimeStatisticsById({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      () => _animeClient.getStatisticsById(id, cancelToken: cancelToken),
      "getAnimeStatisticsById",
    );
  }

  Future<Result<AnimePicturesResponse>> getAnimePicturesById({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      () => _animeClient.getPicturesById(id, cancelToken: cancelToken),
      "getAnimePicturesById",
    );
  }

  Future<Result<AnimeRecommendationResponse>> getAnimeRecommendationsById({
    required int id,
    CancelToken? cancelToken,
  }) async {
    return handleRequest(
      () => _animeClient.getAnimeRecommendationsById(
        id,
        cancelToken: cancelToken,
      ),
      "getAnimeRecommendationsById",
    );
  }
}
