import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/repositories/network/responses/models.dart';
import '../../common/repositories/network/top/top_anime_pagination.dart';
import '../../components/retry_button.dart';
import '../anime/anime_details_screen.dart';

class TopAnimeScreen extends ConsumerStatefulWidget {
  static const navigationKey = "/top_anime_screen";

  const TopAnimeScreen({super.key});

  @override
  ConsumerState createState() => _TopAnimeScreenState();
}

class _TopAnimeScreenState extends ConsumerState<TopAnimeScreen> {
  static const double _margin = 20;
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

    final hasActiveFilters = notifier.type != null ||
        notifier.filter != null ||
        notifier.rating != null ||
        notifier.sfw == true;

    Widget bodyWidget;

    if (animeList.isEmpty) {
      if (isLoading) {
        bodyWidget = GridView.builder(
          shrinkWrap: true,
          itemCount: 6,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 320,
            mainAxisSpacing: _margin,
            crossAxisSpacing: _margin,
          ),
          itemBuilder: (context, index) => const AnimeRowShimmer(),
        );
      } else if (hasError) {
        bodyWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Error loading top anime\n${asyncNotifier.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              RetryButton(onRetryPressed: () => _refresh()),
            ],
          ),
        );
      } else {
        bodyWidget = const Center(
          child: Text(
            "No anime found matching current filters.",
            style: TextStyle(fontSize: 16),
          ),
        );
      }
    } else {
      bodyWidget = GridView.builder(
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
                    : RetryButton(onRetryPressed: () => _loadNextPage()),
              ),
            );
          }
          final anime = animeList[index];

          return AnimeRow(anime: anime);
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // max width per tile
          mainAxisExtent: 320,
          mainAxisSpacing: _margin,
          crossAxisSpacing: _margin,
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Top Anime"),
          actions: [
            IconButton(
              icon: Icon(
                hasActiveFilters ? Icons.filter_list_alt : Icons.filter_list_rounded,
                color: hasActiveFilters ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ],
        ),
        body: Column(
          children: [
            if (hasActiveFilters) _buildActiveFiltersRow(context, notifier),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refresh();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _margin),
                  child: bodyWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersRow(BuildContext context, TopAnimePagination notifier) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            if (notifier.type != null)
              InputChip(
                label: Text("Type: ${notifier.type}"),
                onDeleted: () => notifier.setType(null),
              ),
            if (notifier.filter != null)
              InputChip(
                label: Text("Filter: ${notifier.filter}"),
                onDeleted: () => notifier.setFilter(null),
              ),
            if (notifier.rating != null)
              InputChip(
                label: Text("Rating: ${notifier.rating?.toUpperCase()}"),
                onDeleted: () => notifier.setRating(null),
              ),
            if (notifier.sfw == true)
              InputChip(
                label: const Text("SFW: Yes"),
                onDeleted: () => notifier.setSfw(null),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final notifier = ref.watch(topAnimePaginationProvider.notifier);
            final type = notifier.type;
            final filter = notifier.filter;
            final rating = notifier.rating;
            final sfw = notifier.sfw ?? false;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter Top Anime",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all_rounded, size: 20),
                        label: const Text("Reset"),
                        onPressed: () {
                          notifier.clearFilters();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Type Dropdown
                  _buildDropdown<String>(
                    context: context,
                    label: "Type",
                    value: type,
                    prefixIcon: const Icon(Icons.movie_filter_outlined),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("All")),
                      DropdownMenuItem(value: "TV", child: Text("TV")),
                      DropdownMenuItem(value: "OVA", child: Text("OVA")),
                      DropdownMenuItem(value: "Movie", child: Text("Movie")),
                      DropdownMenuItem(value: "Special", child: Text("Special")),
                      DropdownMenuItem(value: "ONA", child: Text("ONA")),
                      DropdownMenuItem(value: "Music", child: Text("Music")),
                      DropdownMenuItem(value: "CM", child: Text("CM")),
                      DropdownMenuItem(value: "PV", child: Text("PV")),
                      DropdownMenuItem(value: "TV Special", child: Text("TV Special")),
                    ],
                    onChanged: (val) => notifier.setType(val),
                  ),
                  const SizedBox(height: 15),

                  // Filter Dropdown
                  _buildDropdown<String>(
                    context: context,
                    label: "Filter Type",
                    value: filter,
                    prefixIcon: const Icon(Icons.sort_rounded),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("All")),
                      DropdownMenuItem(value: "airing", child: Text("Airing")),
                      DropdownMenuItem(value: "upcoming", child: Text("Upcoming")),
                      DropdownMenuItem(value: "bypopularity", child: Text("Popularity")),
                      DropdownMenuItem(value: "favorite", child: Text("Favorite")),
                    ],
                    onChanged: (val) => notifier.setFilter(val),
                  ),
                  const SizedBox(height: 15),

                  // Rating Dropdown
                  _buildDropdown<String>(
                    context: context,
                    label: "Rating",
                    value: rating,
                    prefixIcon: const Icon(Icons.explicit_outlined),
                    items: const [
                      DropdownMenuItem(value: null, child: Text("All")),
                      DropdownMenuItem(value: "g", child: Text("G - All Ages")),
                      DropdownMenuItem(value: "pg", child: Text("PG - Children")),
                      DropdownMenuItem(value: "pg13", child: Text("PG-13 - Teens 13+")),
                      DropdownMenuItem(value: "r17", child: Text("R - 17+ (violence/profanity)")),
                      DropdownMenuItem(value: "r", child: Text("R+ - Mild Nudity")),
                      DropdownMenuItem(value: "rx", child: Text("Rx - Hentai")),
                    ],
                    onChanged: (val) => notifier.setRating(val),
                  ),
                  const SizedBox(height: 20),

                  // SFW Switch
                  SwitchListTile(
                    secondary: const Icon(Icons.security_outlined),
                    title: const Text(
                      "Safe for Work (SFW)",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text("Filter out adult entries"),
                    value: sfw,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => notifier.setSfw(val ? true : null),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
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

  void _loadNextPage() {
    ref.read(topAnimePaginationProvider.notifier).loadMoreTopAnime();
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
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        context.pushNamed(
          AnimeDetailsScreen.routeName,
          pathParameters: {'id': anime.malId.toString()},
          extra: anime,
        );
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: anime.images?.jpg.largeImageUrl ?? "",
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
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
                        spacing: 10,
                        children: [
                          if (anime.score != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  anime.score.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  anime.aired?.string ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        14, // Adjust the font size as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${anime.title ?? ""}\n',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeRowShimmer extends StatelessWidget {
  const AnimeRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
