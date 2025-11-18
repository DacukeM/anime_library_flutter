import 'models.dart';

extension AnimeRecommendationEntryToAnime on AnimeRecommendationEntry {
  /// Converts a partial [AnimeRecommendationEntry] into a partial [Anime] object.
  ///
  /// This is useful for passing recommendation data to widgets that expect
  /// a full [Anime] object, even if most fields will be null or empty.
  Anime toAnime() {
    return Anime(
      // --- Data from recommendation ---
      malId: malId,
      url: url,
      images: images,
      title: title,

      // --- Default values for required fields ---
      approved: false,
      titles: [],
      titleSynonyms: [],
      airing: false,
      producers: [],
      licensors: [],
      studios: [],
      genres: [],
      explicitGenres: [],
      themes: [],
      demographics: [],

      // --- All other nullable fields will be null ---
    );
  }
}
