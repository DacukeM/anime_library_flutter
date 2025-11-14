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
}
