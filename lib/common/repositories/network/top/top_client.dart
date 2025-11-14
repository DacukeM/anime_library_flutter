import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../../../utils/constants/constants.dart';
import '../responses/models.dart';

part 'top_client.g.dart';

@RestApi(baseUrl: Constants.baseUrl)
abstract class TopClient {
  factory TopClient(Dio dio, {String? baseUrl}) = _TopClient;

  @GET("/top/anime")
  Future<HttpResponse<PaginatedResponse<Anime>>> getTopAnime(
    @Query('page') int? page, {
    // @Query('limit') int? limit,
    @Query('type') String? animeSearchQueryType,
    @Query('filter') String? topAnimeFilter,
    @Query('rating') String? rating,
    @CancelRequest() CancelToken? cancelToken,
  });
}
