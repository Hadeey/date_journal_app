import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // We reuse the dates available in the app state or fetch fresh?
  // Using datesProvider is better as it caches the list 
  // But datesProvider is AsyncNotifier, so we watch it.
  
  final datesAsync = ref.watch(datesProvider);
  
  return datesAsync.when(
    data: (dates) {
      if (dates.isEmpty) {
        return {
          'averageScore': 0.0,
          'totalDates': 0,
          'topLocations': <String, int>{},
          'scoresOverTime': <Map<String, dynamic>>[],
          'criteriaAverages': <String, double>{
             'chemistry': 0.0,
             'conversation': 0.0,
             'punctuality': 0.0,
             'appearance': 0.0,
          }
        };
      }

      // Average Overall Score
      double totalScore = 0;
      for (var d in dates) {
        totalScore += d.ratingOverall;
      }
      double averageScore = totalScore / dates.length;

      // Top Locations
      final locationCounts = <String, int>{};
      for (var d in dates) {
        final loc = d.location;
        locationCounts[loc] = (locationCounts[loc] ?? 0) + 1;
      }
      // Sort map by value
      var sortedLocations = Map.fromEntries(
        locationCounts.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value))
      );
      // Take top 3
      if (sortedLocations.length > 3) {
        sortedLocations = Map.fromEntries(sortedLocations.entries.take(3));
      }

      // Scores Over Time (Reversed because dates are new -> old, we want old -> new for graph)
      final chronologicalDates = dates.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final scoresOverTime = chronologicalDates.map((d) => {
        'date': d.dateTime,
        'score': d.ratingOverall,
      }).toList();

      // Criteria Averages
      double totalChem = 0;
      double totalConv = 0;
      double totalPunc = 0;
      double totalApp = 0;

      for (var d in dates) {
         totalChem += d.ratingChemistry;
         totalConv += d.ratingConversation;
         totalPunc += d.ratingPunctuality;
         totalApp += d.ratingAppearance;
      }

      return {
        'averageScore': averageScore,
        'totalDates': dates.length,
        'topLocations': sortedLocations,
        'scoresOverTime': scoresOverTime,
        'criteriaAverages': {
          'chemistry': totalChem / dates.length,
          'conversation': totalConv / dates.length,
          'punctuality': totalPunc / dates.length,
          'appearance': totalApp / dates.length,
        }
      };
    },
    loading: () => throw Exception('Loading'), // Handled by UI
    error: (e, s) => throw e,
  );
});
