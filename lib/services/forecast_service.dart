import 'dart:math';
import '../config/ml_config.dart';
import '../models/time_entry.dart';

/// Result of fitting and evaluating the daily-hours forecast model.
class ProductivityForecast {
  /// Predicted hours for the next day.
  final double nextDayHours;

  /// Predicted total hours over the next 7 days.
  final double next7DaysHours;

  /// Fitted slope in hours/day (trend direction & strength).
  final double slope;

  /// 'increasing' | 'decreasing' | 'stable'.
  final String trend;

  /// Mean absolute error on the held-out validation set (hours).
  final double mae;

  /// Root-mean-squared error on the held-out validation set (hours).
  final double rmse;

  /// Coefficient of determination on the held-out validation set.
  final double r2;

  final int totalDays;
  final int trainDays;
  final int testDays;

  ProductivityForecast({
    required this.nextDayHours,
    required this.next7DaysHours,
    required this.slope,
    required this.trend,
    required this.mae,
    required this.rmse,
    required this.r2,
    required this.totalDays,
    required this.trainDays,
    required this.testDays,
  });
}

/// A small supervised forecaster for daily logged hours.
///
/// Unlike the heuristic [MLService], this fits parameters to data: ordinary
/// least-squares linear regression on a daily time series, evaluated honestly
/// on a held-out chronological split (MAE / RMSE / R²), then refit on the full
/// history to produce the actual forecast.
class ForecastService {
  /// Builds a continuous daily-hours series (gaps filled with 0) from the first
  /// to the last logged day, then trains, validates, and forecasts. Returns
  /// null when there is not enough history to evaluate a model.
  static ProductivityForecast? forecast(List<TimeEntry> entries) {
    if (entries.isEmpty) return null;

    final byDay = <DateTime, double>{};
    for (final e in entries) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      byDay[day] = (byDay[day] ?? 0) + e.totalTime;
    }

    final sortedDays = byDay.keys.toList()..sort();
    final first = sortedDays.first;
    final last = sortedDays.last;
    final totalDays = last.difference(first).inDays + 1;
    if (totalDays < MLConfig.minDaysForForecast) return null;

    // Continuous series indexed 0..totalDays-1 (missing days = 0 hours).
    final series = List<double>.generate(totalDays, (i) {
      final day = DateTime(first.year, first.month, first.day + i);
      return byDay[day] ?? 0.0;
    });

    // Chronological train/validation split.
    var split = (totalDays * MLConfig.forecastTrainFraction).floor();
    split = split.clamp(2, totalDays - 1); // keep ≥2 train, ≥1 test
    final trainDays = split;
    final testDays = totalDays - split;

    // Fit on training portion, evaluate on the held-out tail.
    final trainX = List<double>.generate(trainDays, (i) => i.toDouble());
    final trainY = series.sublist(0, trainDays);
    final fit = _ols(trainX, trainY);

    double sumAbs = 0, sumSq = 0, sumTot = 0;
    final testMean =
        series.sublist(trainDays).reduce((a, b) => a + b) / testDays;
    for (int i = trainDays; i < totalDays; i++) {
      final pred = fit.slope * i + fit.intercept;
      final actual = series[i];
      final err = pred - actual;
      sumAbs += err.abs();
      sumSq += err * err;
      sumTot += pow(actual - testMean, 2);
    }
    final mae = sumAbs / testDays;
    final rmse = sqrt(sumSq / testDays);
    final r2 = sumTot == 0 ? (sumSq == 0 ? 1.0 : 0.0) : 1 - (sumSq / sumTot);

    // Refit on the full history for the production forecast.
    final allX = List<double>.generate(totalDays, (i) => i.toDouble());
    final fitAll = _ols(allX, series);
    double predictAt(int index) =>
        max(0.0, fitAll.slope * index + fitAll.intercept);

    final nextDay = predictAt(totalDays);
    double next7 = 0;
    for (int i = 0; i < 7; i++) {
      next7 += predictAt(totalDays + i);
    }

    final trend = fitAll.slope > MLConfig.forecastFlatSlope
        ? 'increasing'
        : fitAll.slope < -MLConfig.forecastFlatSlope
        ? 'decreasing'
        : 'stable';

    return ProductivityForecast(
      nextDayHours: nextDay,
      next7DaysHours: next7,
      slope: fitAll.slope,
      trend: trend,
      mae: mae,
      rmse: rmse,
      r2: r2,
      totalDays: totalDays,
      trainDays: trainDays,
      testDays: testDays,
    );
  }

  /// Ordinary least-squares fit of y = slope·x + intercept.
  static ({double slope, double intercept}) _ols(
    List<double> x,
    List<double> y,
  ) {
    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (x[i] - meanX) * (y[i] - meanY);
      den += (x[i] - meanX) * (x[i] - meanX);
    }
    final slope = den == 0 ? 0.0 : num / den;
    final intercept = meanY - slope * meanX;
    return (slope: slope, intercept: intercept);
  }
}
