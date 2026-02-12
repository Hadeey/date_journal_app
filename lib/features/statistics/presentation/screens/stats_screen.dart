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
      appBar: AppBar(
        title: const Text('Statistiques'),
        automaticallyImplyLeading: false,
      ),
      body: statsAsync.when(
        data: (stats) {
          final totalDates = stats['totalDates'] as int;
          if (totalDates == 0) {
            return const Center(child: Text('Pas assez de données pour les statistiques.'));
          }

          final avgScore = stats['averageScore'] as double;
          final topLocations = stats['topLocations'] as Map<String, int>; // Use dynamic cast if needed
          final scoresOverTime = stats['scoresOverTime'] as List<dynamic>;
          final criteriaAverages = stats['criteriaAverages'] as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Dates',
                        value: totalDates.toString(),
                        icon: Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Note Moyenne',
                        value: avgScore.toStringAsFixed(1),
                        icon: Icons.star,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Line Chart (Evolution)
                Text('Évolution de vos dates', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: AppColors.grey300)),
                      minX: 0,
                      maxX: (scoresOverTime.length - 1).toDouble(),
                      minY: 0,
                      maxY: 5.5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(scoresOverTime.length, (index) {
                            return FlSpot(index.toDouble(), (scoresOverTime[index]['score'] as double));
                          }),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bar Chart (Criteria)
                Text('Points forts', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
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
                                case 0: text = 'Alchimie'; break;
                                case 1: text = 'Conv.'; break;
                                case 2: text = 'Ponctu.'; break;
                                case 3: text = 'Appar.'; break;
                                default: text = '';
                              }
                              return SideTitleWidget(meta: meta, child: Text(text, style: style));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _makeBarGroup(0, criteriaAverages['chemistry'] as double, AppColors.primary),
                        _makeBarGroup(1, criteriaAverages['conversation'] as double, AppColors.secondary),
                        _makeBarGroup(2, criteriaAverages['punctuality'] as double, AppColors.accent),
                        _makeBarGroup(3, criteriaAverages['appearance'] as double, AppColors.info),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Top Locations
                Text('Lieux préférés', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                ...topLocations.entries.map((e) => ListTile(
                  leading: const Icon(Icons.place, color: AppColors.primary),
                  title: Text(e.key, style: AppTextStyles.body),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${e.value} dates', style: AppTextStyles.bodySmall),
                  ),
                )),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
        loading: () => const LoadingSpinner(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: AppColors.grey100),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
} 
