import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../../../utils/constants/constants.dart';
import '../responses/models.dart';

part 'anime_client.g.dart';

@RestApi(baseUrl: Constants.baseUrl)
abstract class AnimeClient {
  factory AnimeClient(Dio dio, {String? baseUrl}) = _AnimeClient;

  @GET("/anime/{id}/full")
  Future<HttpResponse<DataResponse<Anime>>> getAnimeById(
    @Path() int id, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
