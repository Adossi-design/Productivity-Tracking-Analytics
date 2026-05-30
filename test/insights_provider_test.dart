import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_tracking_analytics/config/ml_config.dart';
import 'package:productivity_tracking_analytics/models/time_entry.dart';
import 'package:productivity_tracking_analytics/providers/insights_provider.dart';

TimeEntry entry(double hours, DateTime date) => TimeEntry(
  id: '${date.microsecondsSinceEpoch}-$hours',
  projectName: 'P',
  taskName: 'T',
  notes: '',
  totalTime: hours,
  date: date,
);

void main() {
  group('InsightsProvider.compute', () {
    test('reports not-enough-data below the minimum', () {
      final provider = InsightsProvider();
      final entries = List.generate(
        MLConfig.minEntriesForInsights - 1,
        (i) => entry(2, DateTime(2026, 1, i + 1)),
      );

      provider.compute(entries);

      expect(provider.hasEnoughData, isFalse);
      expect(provider.insights, isNull);
    });

    test('clusters durations into sorted light/moderate/deep groups', () {
      final provider = InsightsProvider();
      // Three clearly separated duration bands.
      final entries = <TimeEntry>[
        entry(0.5, DateTime(2026, 1, 1)),
        entry(0.7, DateTime(2026, 1, 2)),
        entry(2.0, DateTime(2026, 1, 3)),
        entry(2.2, DateTime(2026, 1, 4)),
        entry(6.0, DateTime(2026, 1, 5)),
        entry(6.5, DateTime(2026, 1, 6)),
      ];

      provider.compute(entries);
      final insights = provider.insights!;

      expect(insights.clusters.length, 3);
      // Centroids must be ascending (light < moderate < deep).
      final centroids = insights.clusters.map((c) => c.centroid).toList();
      expect(centroids[0], lessThan(centroids[1]));
      expect(centroids[1], lessThan(centroids[2]));
      expect(insights.clusters.first.label, 'Light Sessions');
      expect(insights.clusters.last.label, 'Deep Work Sessions');
    });

    test('well-separated data yields a strong silhouette score', () {
      final provider = InsightsProvider();
      final entries = <TimeEntry>[
        entry(0.5, DateTime(2026, 1, 1)),
        entry(0.6, DateTime(2026, 1, 2)),
        entry(3.0, DateTime(2026, 1, 3)),
        entry(3.1, DateTime(2026, 1, 4)),
        entry(8.0, DateTime(2026, 1, 5)),
        entry(8.2, DateTime(2026, 1, 6)),
      ];

      provider.compute(entries);

      expect(provider.insights!.silhouetteScore, greaterThan(0.5));
      expect(provider.insights!.clusterQuality, anyOf('Strong', 'Reasonable'));
    });

    test('totals and top project are computed correctly', () {
      final provider = InsightsProvider();
      final entries = <TimeEntry>[
        entry(1, DateTime(2026, 1, 1)),
        entry(2, DateTime(2026, 1, 2)),
        entry(3, DateTime(2026, 1, 3)),
        entry(4, DateTime(2026, 1, 4)),
        entry(5, DateTime(2026, 1, 5)),
      ];

      provider.compute(entries);

      expect(provider.insights!.totalHours, 15);
      expect(provider.insights!.topProject, 'P');
    });

    test('is memoized: recomputing with identical data keeps the result', () {
      final provider = InsightsProvider();
      final entries = List.generate(
        6,
        (i) => entry(i + 1.0, DateTime(2026, 1, i + 1)),
      );

      provider.compute(entries);
      final first = provider.insights;
      provider.compute(entries); // same signature → should be skipped

      expect(identical(provider.insights, first), isTrue);
    });
  });
}
