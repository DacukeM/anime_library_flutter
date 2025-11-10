import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/repositories/network/top/top_anime_pagination.dart';
import '../components/retry_button.dart';

class TopAnimeScreen extends ConsumerStatefulWidget {
  static const navigationKey = "/top_anime_screen";

  const TopAnimeScreen({super.key});

  @override
  ConsumerState createState() => _TopAnimeScreenState();
}

class _TopAnimeScreenState extends ConsumerState<TopAnimeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      ref.read(topAnimePaginationProvider.notifier).fetchTopAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(topAnimePaginationProvider.notifier);
    final asyncNotifier = ref.watch(topAnimePaginationProvider);
    final animeList = notifier.anime;
    final isLoading = notifier.isLoading;
    final hasError = notifier.hasError;

    if (animeList.isEmpty) {
      if (isLoading) {
        return Text("No anime");
      }
      if (hasError) {
        return Text("Error, ${asyncNotifier.error}");
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        // _initialFetchOrders();
      },
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: animeList.length + (isLoading || hasError ? 1 : 0),
        // controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == animeList.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : RetryButton(onRetryPressed: () => Text("Tetry")),
              ),
            );
          }
          final anime = animeList[index];

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: anime.images.jpg.smallImageUrl ?? "",
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // max width per tile
          mainAxisExtent: 280,
          // mainAxisSpacing: AppDimensions.defaultRowPadding,
          // crossAxisSpacing: AppDimensions.defaultRowPadding,
        ),
      ),
    );
  }
}
