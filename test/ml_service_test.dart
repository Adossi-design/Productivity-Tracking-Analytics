import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_tracking_analytics/config/ml_config.dart';
import 'package:productivity_tracking_analytics/models/time_entry.dart';
import 'package:productivity_tracking_analytics/services/ml_service.dart';

/// Builds a TimeEntry with sensible defaults so tests stay terse.
TimeEntry entry({
  String project = 'Project A',
  String task = 'Task',
  double hours = 2,
  required DateTime date,
  DateTime? start,
  DateTime? end,
}) {
  return TimeEntry(
    id: '${date.microsecondsSinceEpoch}-$task-$hours',
    projectName: project,
    taskName: task,
    notes: '',
    totalTime: hours,
    date: date,
    startTime: start,
    endTime: end,
  );
}

void main() {
  group('MLService.calculateProductivityScore', () {
    test('returns neutral defaults below the minimum entry count', () {
      final entries = List.generate(
        MLConfig.minEntriesForScore - 1,
        (i) => entry(date: DateTime(2026, 1, i + 1)),
      );

      final score = MLService.calculateProductivityScore(entries);

      expect(score.overall, 50);
      expect(score.insights.single, contains('Need more data'));
    });

    test('produces sub-scores clamped to the 0-100 range', () {
      final entries = List.generate(
        10,
        (i) => entry(hours: 3, date: DateTime(2026, 1, i + 1)),
      );

      final score = MLService.calculateProductivityScore(entries);

      for (final s in [
        score.overall,
        score.volume,
        score.consistency,
        score.focus,
        score.balance,
        score.efficiency,
      ]) {
        expect(s, inInclusiveRange(0, 100));
      }
    });

    test('flags fragmented focus when many projects are touched per day', () {
      // Five different projects all logged on the same day.
      final day = DateTime(2026, 3, 2);
      final entries = List.generate(
        5,
        (i) => entry(project: 'Project $i', hours: 1, date: day),
      );

      final score = MLService.calculateProductivityScore(entries);

      // Switch rate is high → focus score should be well below perfect.
      expect(score.focus, lessThan(100));
    });
  });

  group('MLService.detectAnomalies', () {
    test('returns nothing below the minimum entry count', () {
      final entries = List.generate(
        MLConfig.minEntriesForAnomalies - 1,
        (i) => entry(date: DateTime(2026, 1, i + 1)),
      );
      expect(MLService.detectAnomalies(entries), isEmpty);
    });

    test('flags a day with hours far above the personal average', () {
      final entries = <TimeEntry>[
        for (int i = 0; i < 9; i++)
          entry(hours: 2, date: DateTime(2026, 2, i + 1)),
        entry(hours: 20, date: DateTime(2026, 2, 20)), // spike
      ];

      final anomalies = MLService.detectAnomalies(entries);

      expect(anomalies.any((a) => a.type == AnomalyType.unusualHours), isTrue);
    });

    test('labels only the single largest gap as the longest', () {
      final entries = <TimeEntry>[
        entry(date: DateTime(2026, 1, 1)),
        entry(date: DateTime(2026, 1, 9)), // 8-day gap
        entry(date: DateTime(2026, 1, 10)),
        entry(date: DateTime(2026, 1, 30)), // 20-day gap (the longest)
        entry(date: DateTime(2026, 1, 31)),
        entry(date: DateTime(2026, 2, 1)),
        entry(date: DateTime(2026, 2, 2)),
      ];

      final longGaps = MLService.detectAnomalies(
        entries,
      ).where((a) => a.type == AnomalyType.longGap).toList();

      final longestLabels = longGaps
          .where((a) => a.message.contains('longest'))
          .toList();
      expect(
        longestLabels.length,
        1,
        reason: 'exactly one gap should be called the longest',
      );
      expect(longestLabels.single.message, contains('20 days'));
    });
  });

  group('MLService.recognizePatterns', () {
    test('returns nothing below the minimum entry count', () {
      final entries = List.generate(
        MLConfig.minEntriesForPatterns - 1,
        (i) => entry(date: DateTime(2026, 1, i + 1)),
      );
      expect(MLService.recognizePatterns(entries), isEmpty);
    });
  });

  group('MLService.generateRecommendations', () {
    test('recommends better balance when weekend work is high', () {
      // Heavy weekend logging (Sat 2026-01-03 / Sun 2026-01-04).
      final entries = <TimeEntry>[
        entry(hours: 8, date: DateTime(2026, 1, 3)),
        entry(hours: 8, date: DateTime(2026, 1, 4)),
        entry(hours: 1, date: DateTime(2026, 1, 5)),
        entry(hours: 1, date: DateTime(2026, 1, 6)),
        entry(hours: 1, date: DateTime(2026, 1, 7)),
        entry(hours: 1, date: DateTime(2026, 1, 8)),
        entry(hours: 1, date: DateTime(2026, 1, 9)),
      ];

      final recs = MLService.generateRecommendations(entries);

      expect(recs.any((r) => r.type == RecommendationType.balance), isTrue);
    });
  });
}
