import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/statistics/presentation/providers/stats_provider.dart';
import 'package:date_journal_app/shared/widgets/bottom_nav_bar.dart';
import 'package:date_journal_app/shared/widgets/loading_spinner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3), // Light cream background
      body: statsAsync.when(
        data: (stats) {
          final totalDates = stats['totalDates'] as int;
          final avgScore = stats['averageScore'] as double;
          final topLocations = stats['topLocations'] as Map<String, int>;
          final scoresOverTime = stats['scoresOverTime'] as List<dynamic>;
          final criteriaAverages =
              stats['criteriaAverages'] as Map<String, dynamic>;

          return Stack(
            children: [
              // Header Background
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8FA3), // Light pink
                      Color(0xFFFF6B9D), // Darker pink
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Statistiques',
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Key Metrics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _HeaderStatCard(
                              title: 'Total dates',
                              value: totalDates.toString(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _HeaderStatCard(
                              title: 'Note moyenne',
                              value: avgScore.toStringAsFixed(1),
                              showStar: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Evolution Chart
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trending_up,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('Évolution des notes',
                                    style: AppTextStyles.h3),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 180,
                              child: _EvolutionChart(
                                  scoresOverTime: scoresOverTime),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Criteria Chart
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Critères moyens', style: AppTextStyles.h3),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 180,
                              child: _CriteriaChart(criteria: criteriaAverages),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Top Locations (Optional, kept for completeness but styled simpler)
                      if (topLocations.isNotEmpty) ...[
                        Text('Lieux fréquents', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        ...topLocations.entries.map((e) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.place,
                                    color: AppColors.primary),
                                title: Text(e.key, style: AppTextStyles.body),
                                trailing: Text('${e.value} dates',
                                    style: AppTextStyles.bodySmall),
                              ),
                            )),
                      ],
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: LoadingSpinner()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool showStar;

  const _HeaderStatCard({
    required this.title,
    required this.value,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              if (showStar) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Color(0xFFFFD93D), size: 28),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EvolutionChart extends StatelessWidget {
  final List<dynamic> scoresOverTime;

  const _EvolutionChart({required this.scoresOverTime});

  @override
  Widget build(BuildContext context) {
    if (scoresOverTime.isEmpty) return const SizedBox();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppColors.grey100,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: AppColors.grey100,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < scoresOverTime.length) {
                  // Show only first, last and maybe middle to avoid overlapping?
                  // For now show all as dataset is small or we can filter
                  // Simple logic: if many points, show skip 1
                  if (scoresOverTime.length > 5 && index % 2 != 0)
                    return const SizedBox();

                  final date = scoresOverTime[index]['date'] as DateTime;
                  // Use local date format if needed, simplified here
                  final text =
                      '${date.day} janv.'; // Placeholder for localization TODO
                  // Ideally: DateFormat('d MMM', 'fr_FR').format(date)
                  // But we need to ensure local is initialized or use simpler
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Fix y-axis info
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 20,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.grey500, width: 1),
            left: BorderSide(color: AppColors.grey500, width: 1),
          ),
        ),
        minX: 0,
        maxX: (scoresOverTime.length - 1).toDouble(),
        minY: 0,
        maxY: 5.5, // 5 stars
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(scoresOverTime.length, (index) {
              return FlSpot(
                  index.toDouble(), (scoresOverTime[index]['score'] as double));
            }),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class _CriteriaChart extends StatelessWidget {
  final Map<String, dynamic> criteria;

  const _CriteriaChart({required this.criteria});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Alchimie';
                    break;
                  case 1:
                    text = 'Conv.';
                    break;
                  case 2:
                    text = 'Ponctu.';
                    break;
                  case 3:
                    text = 'Appar.';
                    break;
                  default:
                    text = '';
                }
                return SideTitleWidget(
                    meta: meta, child: Text(text, style: style));
              },
            ),
          ),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (value, meta) {
                    if (value % 2 == 0) {
                      return Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 10));
                    }
                    return const SizedBox();
                  })),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: AppColors.grey100, dashArray: [5, 5]),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, criteria['chemistry'] as double),
          _makeBarGroup(1, criteria['conversation'] as double),
          _makeBarGroup(2, criteria['punctuality'] as double),
          _makeBarGroup(3, criteria['appearance'] as double),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 30, // Thicker bars
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 10, color: AppColors.grey100),
        ),
      ],
    );
  }
}
