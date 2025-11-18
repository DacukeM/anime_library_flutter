import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/repositories/network/anime/anime_statistics_provider.dart';
import '../../common/repositories/network/responses/models.dart';

class AnimeStatisticsRow extends ConsumerStatefulWidget {
  final int? animeId;

  const AnimeStatisticsRow({super.key, required this.animeId});

  @override
  ConsumerState createState() => _AnimeStatisticsState();
}

class _AnimeStatisticsState extends ConsumerState<AnimeStatisticsRow> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(animeStatisticsProviderProvider(widget.animeId).notifier)
          .fetchAnimeStatisticsById(widget.animeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncNotifier = ref.watch(
      animeStatisticsProviderProvider(widget.animeId),
    );

    return asyncNotifier.when(
      data: (statistics) {
        if (statistics == null) {
          return const Center(child: Text('No statistics available.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Rating",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ScoresBarChart(scores: statistics?.scores ?? []),
            Divider(
              height: 0,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "On people's list",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StatsPieChart(stats: statistics!),
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

class ScoresBarChart extends StatelessWidget {
  final List<Score> scores;

  const ScoresBarChart({super.key, required this.scores});

  // 4. Helper function to format the number with commas
  String formatNumberWithCommas(int number) {
    final String numStr = number.toString();
    // This RegExp adds a comma every 3 digits from the end
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return numStr.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    // --- Calculate Score and Votes ---

    // 1. Calculate Total Votes
    final int totalVotesInt = scores.fold(0, (sum, score) => sum + score.votes);

    // 2. Calculate Total Weighted Score
    final double totalWeight = scores.fold(
      0.0,
      (sum, score) => sum + (score.score * score.votes),
    );

    // 3. Calculate Overall Score
    // Add a check for 0 votes to avoid division by zero
    final double animeScore = (totalVotesInt == 0)
        ? 0.0
        : totalWeight / totalVotesInt;

    // 5. Format the calculated values for display
    final String formattedTotalVotes =
        "${formatNumberWithCommas(totalVotesInt)} votes";
    final String formattedAnimeScore = animeScore.toStringAsFixed(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Score and Votes
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formattedAnimeScore, // Use calculated value
                  style: const TextStyle(
                    fontSize: 52, // Balanced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedTotalVotes, // Use calculated value
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        // Right Column: Bar Chart
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 150, // Constrain the chart height
            child: AspectRatio(
              aspectRatio: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    // Hide grid lines
                    gridData: const FlGridData(show: false),
                    // Define the titles
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ), // Hide Y-axis labels
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // X-axis labels (Score 1-10)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Define the bar data
                    barGroups: scores.map((score) {
                      return BarChartGroupData(
                        x: score.score, // The X-axis value (1, 2, 3... 10)
                        barRods: [
                          BarChartRodData(
                            toY: score.percentage,
                            // The Y-axis value (percentage)
                            color: Colors.blueAccent,
                            width: 15,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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

// Helper function to format numbers with commas
String _formatNumberWithCommas(int number) {
  final String numStr = number.toString();
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return numStr.replaceAllMapped(reg, (Match m) => '${m[1]},');
}

// Helper widget for the legend
class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.count,
    this.textColor,
  });

  final Color color;
  final String text;
  final int count;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4), // Slightly rounded square
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              // color: textColor ?? Colors.white.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          Text(
            _formatNumberWithCommas(count),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class StatsPieChart extends StatelessWidget {
  final AnimeStatistics stats;

  const StatsPieChart({super.key, required this.stats});

  // Define colors for each section
  static const List<Color> _sectionColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
  ];

  // Helper to build a section of the bar
  Widget _buildBarSection(int flex, Color color) {
    if (flex == 0) {
      return Container(); // Don't render a widget if the value is 0
    }
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stats.total == 0) {
      return const Center(child: Text('No statistics available.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The "1 line with separated colors" (Stacked Bar)
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: SizedBox(
            height: 30, // Height of the bar
            child: Row(
              children: [
                _buildBarSection(stats.watching, _sectionColors[0]),
                _buildBarSection(stats.completed, _sectionColors[1]),
                _buildBarSection(stats.onHold, _sectionColors[2]),
                _buildBarSection(stats.dropped, _sectionColors[3]),
                _buildBarSection(stats.planToWatch, _sectionColors[4]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. The Legend with counts
        Indicator(
          color: _sectionColors[0],
          text: 'Watching',
          count: stats.watching,
        ),
        Indicator(
          color: _sectionColors[1],
          text: 'Completed',
          count: stats.completed,
        ),
        Indicator(
          color: _sectionColors[2],
          text: 'On Hold',
          count: stats.onHold,
        ),
        Indicator(
          color: _sectionColors[3],
          text: 'Dropped',
          count: stats.dropped,
        ),
        Indicator(
          color: _sectionColors[4],
          text: 'Plan to Watch',
          count: stats.planToWatch,
        ),
        Divider(color: Colors.grey),
        Indicator(
          color: Colors.grey[700]!,
          text: 'Total',
          count: stats.total,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
