import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/repositories/network/anime/anime_by_id_provider.dart';
import '../../common/repositories/network/responses/models.dart';
import '../../utils/constants/app_dimensions.dart';
import 'anime_pictures_row.dart';
import 'anime_recommendations_row.dart';
import 'anime_statistics_row.dart';

class AnimeDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/anime-details';

  final Anime? initialAnime;

  const AnimeDetailsScreen({super.key, this.initialAnime});

  @override
  ConsumerState createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends ConsumerState<AnimeDetailsScreen> {
  Anime? _initialAnime;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _initialAnime = widget.initialAnime;
      if (_initialAnime != null) {
        final notifier = ref.read(
          animeByIdProviderProvider(widget.initialAnime?.malId).notifier,
        );
        notifier.setInitialAnime(_initialAnime);
        notifier.fetchAnimeById(_initialAnime?.malId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.read(
      animeByIdProviderProvider(widget.initialAnime?.malId).notifier,
    );
    final asyncNotifier = ref.watch(
      animeByIdProviderProvider(widget.initialAnime?.malId),
    );

    _initialAnime = notifier.anime;

    if (_initialAnime != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_initialAnime?.title ?? "")),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              spacing: AppDimensions.defaultRowPadding,
              children: [
                AnimeImage(imageUrl: _initialAnime?.images?.jpg.largeImageUrl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.defaultPageHorizontalPadding,
                  ),
                  child: Column(
                    spacing: AppDimensions.defaultRowPadding,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AnimeTitle(
                          title: _initialAnime?.title,
                          titleEnglish: _initialAnime?.titleEnglish,
                          titleJapanese: _initialAnime?.titleJapanese,
                          titleSynonyms: _initialAnime?.titleSynonyms ?? [],
                        ),
                      ),
                      Row(
                        spacing: AppDimensions.defaultRowPadding,
                        children: [
                          Icon(Icons.queue_play_next_outlined),
                          Text(
                            "${(_initialAnime?.episodes ?? 0)} Episodes, ${_initialAnime?.duration}",
                          ),
                        ],
                      ),
                      Row(
                        spacing: AppDimensions.defaultRowPadding,
                        children: [
                          Icon(Icons.calendar_month_outlined),
                          Text(
                            "${(_initialAnime?.type)}, ${_initialAnime?.status}",
                          ),
                        ],
                      ),
                      Row(
                        spacing: AppDimensions.defaultRowPadding,
                        children: [
                          Icon(Icons.insert_link),
                          Text("Source ${_initialAnime?.source}"),
                        ],
                      ),
                      const SizedBox.shrink(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimeGenres(genres: _initialAnime?.genres ?? []),
                      ),
                      const SizedBox.shrink(),
                      AnimeDescription(
                        description: _initialAnime?.synopsis ?? "",
                      ),
                      const SizedBox.shrink(),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      AnimeStatisticsRow(animeId: _initialAnime?.malId),
                      const SizedBox.shrink(),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      AnimePicturesRow(animeId: _initialAnime?.malId),
                      const SizedBox.shrink(),
                      Divider(
                        height: 0,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      AnimeRecommendationsRow(animeId: _initialAnime?.malId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text("No anime, ${asyncNotifier.runtimeType}")),
    );
  }
}

class AnimeImage extends StatelessWidget {
  final double _imageSize = 400;
  final String? imageUrl;

  const AnimeImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl ?? "",
          width: double.infinity,
          height: _imageSize,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 48),
          ),
        ),
        Container(
          width: double.infinity,
          height: _imageSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.7),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageViewer(imageUrl: imageUrl ?? ""),
              ),
            );
          },
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? "",
                height: _imageSize,
                placeholder: (context, url) {
                  return const Center(child: CircularProgressIndicator());
                },
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimeTitle extends StatelessWidget {
  final String? title;
  final String? titleEnglish;
  final String? titleJapanese;
  final List<String> titleSynonyms;

  const AnimeTitle({
    super.key,
    this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.titleSynonyms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.defaultPageHorizontalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppDimensions.defaultRowPadding,
                  children: [
                    AnimeTitleRowWithCopy(
                      name: "Title: ",
                      title: titleEnglish ?? "",
                    ),
                    Divider(
                      height: 0,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    AnimeTitleRowWithCopy(
                      name: "Original title: ",
                      title: title ?? "",
                    ),
                    Divider(
                      height: 0,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    AnimeTitleRowWithCopy(
                      name: "Japanese title: ",
                      title: titleJapanese ?? "",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Row(
        spacing: AppDimensions.defaultRowPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(Icons.info_outline_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleEnglish ?? "",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title ?? "", style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeTitleRowWithCopy extends StatelessWidget {
  final String name;
  final String title;

  const AnimeTitleRowWithCopy({
    super.key,
    required this.name,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: title));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.copy, size: 20),
            ],
          ),
          Text(title),
        ],
      ),
    );
  }
}

class AnimeGenres extends StatelessWidget {
  final List<MalEntry> genres;

  const AnimeGenres({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<TextSpan> listOfGenres = [];

    for (int i = 0; i < genres.length; i++) {
      final genre = genres[i];
      final genreName = genre.name;

      listOfGenres.add(
        TextSpan(
          text: genreName,
          recognizer: TapGestureRecognizer()..onTap = () {},
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      );
      if (i < genres.length - 1) {
        listOfGenres.add(
          TextSpan(text: ", ", style: theme.textTheme.bodyMedium),
        );
      }
    }

    return RichText(text: TextSpan(children: listOfGenres));
  }
}

class AnimeDescription extends StatefulWidget {
  final String description;

  const AnimeDescription({super.key, required this.description});

  @override
  State<AnimeDescription> createState() => _AnimeDescriptionState();
}

class _AnimeDescriptionState extends State<AnimeDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      spacing: AppDimensions.defaultRowPadding,
      children: [
        Text(
          widget.description,
          maxLines: _isExpanded ? 1000 : 6,
          overflow: TextOverflow.ellipsis,
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? "Less" : "More...",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

