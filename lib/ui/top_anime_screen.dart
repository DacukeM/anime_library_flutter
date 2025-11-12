import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/repositories/network/responses/models.dart';
import '../common/repositories/network/top/top_anime_pagination.dart';
import '../components/retry_button.dart';

class TopAnimeScreen extends ConsumerStatefulWidget {
  static const navigationKey = "/top_anime_screen";

  const TopAnimeScreen({super.key});

  @override
  ConsumerState createState() => _TopAnimeScreenState();
}

class _TopAnimeScreenState extends ConsumerState<TopAnimeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initialFetchAnime());
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: animeList.length + (isLoading || hasError ? 1 : 0),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == animeList.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : RetryButton(onRetryPressed: () => Text("Retry")),
                ),
              );
            }
            final anime = animeList[index];

            return AnimeRow(anime: anime);
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // max width per tile
            mainAxisExtent: 280,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
        ),
      ),
    );
  }

  void _initialFetchAnime() {
    ref.read(topAnimePaginationProvider.notifier).fetchTopAnime();
  }

  void _refresh() {
    ref.read(topAnimePaginationProvider.notifier).refreshTopAnime();
  }

  void _loadNextPageErrorCheck() {
    final notifier = ref.read(topAnimePaginationProvider.notifier);
    if (!notifier.hasError) {
      notifier.loadMoreTopAnime();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 20) {
      _loadNextPageErrorCheck();
    }
  }
}

class AnimeRow extends StatelessWidget {
  final Anime anime;

  const AnimeRow({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: anime.images.jpg.largeImageUrl ?? "",
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        anime.score.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Adjust the font size as needed
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        anime.aired?.from.toString().substring(0, 10) ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Adjust the font size as needed
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    anime.title ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
