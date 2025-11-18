import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/repositories/network/responses/mapper.dart';
import '../../common/repositories/network/anime/anime_recommendations_provider.dart';
import '../../components/retry_button.dart';
import '../../utils/constants/app_dimensions.dart';
import 'anime_details_screen.dart';

class AnimeRecommendationsRow extends ConsumerStatefulWidget {
  final int? animeId;

  const AnimeRecommendationsRow({super.key, required this.animeId});

  @override
  ConsumerState createState() => _AnimeRecommendationsRowState();
}

class _AnimeRecommendationsRowState
    extends ConsumerState<AnimeRecommendationsRow> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(animeRecommendationsProviderProvider(widget.animeId).notifier)
          .fetchAnimePicturesById(widget.animeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncNotifier = ref.watch(
      animeRecommendationsProviderProvider(widget.animeId),
    );

    return asyncNotifier.when(
      data: (recommendations) {
        return SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final recommendation = recommendations?[index];

              return InkWell(
                onTap: () {
                  context.pushNamed(
                    AnimeDetailsScreen.routeName,
                    pathParameters: {
                      'id': recommendation?.entry.malId.toString() ?? "",
                    },
                    extra: recommendation?.entry.toAnime(),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200,
                      // width: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall,
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              recommendation?.entry.images.jpg.largeImageUrl ??
                              "",
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 130,
                      child: Text(
                        recommendation?.entry.title ?? "",
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                width: AppDimensions.defaultPageHorizontalPadding,
              );
            },
            itemCount: recommendations?.length ?? 0,
          ),
        );
      },
      error: (e, st) {
        return RetryButton(
          onRetryPressed: () {
            ref
                .read(
                  animeRecommendationsProviderProvider(widget.animeId).notifier,
                )
                .fetchAnimePicturesById(widget.animeId);
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
