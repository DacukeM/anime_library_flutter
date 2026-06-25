import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/repositories/network/anime/anime_pictures_provider.dart';
import '../../utils/constants/app_dimensions.dart';
import 'anime_details_screen.dart';

class AnimePicturesRow extends ConsumerStatefulWidget {
  final int? animeId;

  const AnimePicturesRow({super.key, required this.animeId});

  @override
  ConsumerState createState() => _AnimePicturesRowState();
}

class _AnimePicturesRowState extends ConsumerState<AnimePicturesRow> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(animePicturesProviderProvider(widget.animeId).notifier)
          .fetchAnimePicturesById(widget.animeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncNotifier = ref.watch(animePicturesProviderProvider(widget.animeId));

    return asyncNotifier.when(
      data: (pictures) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Pictures",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl = pictures?[index].jpg.largeImageUrl ?? "";
                  return GestureDetector(
                    onTap: () {
                      if (imageUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 130,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    width: AppDimensions.defaultPageHorizontalPadding,
                  );
                },
                itemCount: pictures?.length ?? 0,
              ),
            ),
          ],
        );
      },
      error: (e, st) {
        return Center(child: Text(e.toString()));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
