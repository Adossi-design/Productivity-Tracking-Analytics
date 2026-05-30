import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_tracking_analytics/models/time_entry.dart';
import 'package:productivity_tracking_analytics/services/forecast_service.dart';

TimeEntry entry(double hours, DateTime date) => TimeEntry(
  id: '${date.microsecondsSinceEpoch}-$hours',
  projectName: 'P',
  taskName: 'T',
  notes: '',
  totalTime: hours,
  date: date,
);

void main() {
  group('ForecastService.forecast', () {
    test('returns null without enough days of history', () {
      final entries = [
        entry(2, DateTime(2026, 1, 1)),
        entry(2, DateTime(2026, 1, 2)),
        entry(2, DateTime(2026, 1, 3)),
      ];
      expect(ForecastService.forecast(entries), isNull);
    });

    test('learns a clean linear trend and validates near-perfectly', () {
      // hours = 1 + 0.5 * dayIndex over 12 consecutive days (no gaps).
      final entries = List.generate(
        12,
        (i) => entry(1 + 0.5 * i, DateTime(2026, 1, 1 + i)),
      );

      final f = ForecastService.forecast(entries)!;

      expect(f.trend, 'increasing');
      expect(f.slope, closeTo(0.5, 0.01));
      // Held-out error should be tiny and R² near 1 for a clean line.
      expect(f.mae, lessThan(0.05));
      expect(f.r2, greaterThan(0.99));
      // Next day is index 12 → 1 + 0.5*12 = 7.
      expect(f.nextDayHours, closeTo(7.0, 0.1));
      // Train + test partition covers the whole series.
      expect(f.trainDays + f.testDays, f.totalDays);
      expect(f.testDays, greaterThanOrEqualTo(1));
    });

    test('reports a stable trend for flat history', () {
      final entries = List.generate(
        10,
        (i) => entry(3, DateTime(2026, 2, 1 + i)),
      );

      final f = ForecastService.forecast(entries)!;

      expect(f.trend, 'stable');
      expect(f.slope, closeTo(0.0, 0.01));
      expect(f.nextDayHours, closeTo(3.0, 0.2));
    });

    test('detects a downward trend', () {
      final entries = List.generate(
        10,
        (i) => entry(10 - 0.7 * i, DateTime(2026, 3, 1 + i)),
      );

      final f = ForecastService.forecast(entries)!;

      expect(f.trend, 'decreasing');
      expect(f.slope, lessThan(0));
    });
  });
}
