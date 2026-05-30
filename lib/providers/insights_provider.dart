import 'dart:math';
import 'package:flutter/material.dart';
import '../config/ml_config.dart';
import '../models/time_entry.dart';
import '../theme/app_colors.dart';

// K-Means clustering result for work session analysis
class SessionCluster {
  final String label;
  final Color color;
  final List<TimeEntry> entries;
  final double centroid;

  SessionCluster({
    required this.label,
    required this.color,
    required this.entries,
    required this.centroid,
  });

  double get totalHours => entries.fold(0.0, (sum, e) => sum + e.totalTime);
}

// Comprehensive productivity analytics from time entries
class ProductivityInsights {
  final double totalHours;
  final double avgHoursPerDay;
  final String mostProductiveDay;
  final String topProject;
  final double hoursThisWeek;
  final Map<String, double> hoursPerProject;
  final Map<String, double> last7DaysActivity;
  final List<SessionCluster> clusters;

  /// Mean silhouette coefficient of the K-Means clustering, in [-1, 1].
  /// Higher means tighter, better-separated clusters. Lets the UI report how
  /// trustworthy the session groupings are instead of presenting them blindly.
  final double silhouetteScore;

  ProductivityInsights({
    required this.totalHours,
    required this.avgHoursPerDay,
    required this.mostProductiveDay,
    required this.topProject,
    required this.hoursThisWeek,
    required this.hoursPerProject,
    required this.last7DaysActivity,
    required this.clusters,
    required this.silhouetteScore,
  });

  /// Human-readable quality label for [silhouetteScore].
  String get clusterQuality {
    if (clusters.length < 2) return 'N/A';
    if (silhouetteScore >= 0.7) return 'Strong';
    if (silhouetteScore >= 0.5) return 'Reasonable';
    if (silhouetteScore >= 0.25) return 'Weak';
    return 'Poor';
  }
}

// Analyzes time entries using K-Means clustering and statistical analysis
class InsightsProvider extends ChangeNotifier {
  ProductivityInsights? _insights;
  bool _hasEnoughData = false;

  ProductivityInsights? get insights => _insights;
  bool get hasEnoughData => _hasEnoughData;

  static const int _minEntries = MLConfig.minEntriesForInsights;

  /// Signature of the last dataset we computed for. Lets [compute] no-op when
  /// called repeatedly with unchanged data — important because screens trigger
  /// it from post-frame callbacks, which would otherwise re-run K-Means (and
  /// notify, causing more rebuilds) on every single frame.
  String? _lastSignature;

  String _signatureOf(List<TimeEntry> entries) {
    final buf = StringBuffer('${entries.length}');
    for (final e in entries) {
      buf.write('|${e.id}:${e.totalTime}');
    }
    return buf.toString();
  }

  void compute(List<TimeEntry> entries) {
    final signature = _signatureOf(entries);
    if (signature == _lastSignature) return; // nothing changed; skip work
    _lastSignature = signature;

    if (entries.length < _minEntries) {
      _hasEnoughData = false;
      _insights = null;
      notifyListeners();
      return;
    }

    _hasEnoughData = true;

    final totalHours = entries.fold(0.0, (s, e) => s + e.totalTime);

    final activeDays = entries.map((e) => _dayKey(e.date)).toSet();
    final avgHoursPerDay = activeDays.isEmpty
        ? 0.0
        : totalHours / activeDays.length;

    final dayTotals = <String, double>{};
    for (final e in entries) {
      final day = _weekdayName(e.date.weekday);
      dayTotals[day] = (dayTotals[day] ?? 0) + e.totalTime;
    }
    final mostProductiveDay = dayTotals.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    final hoursPerProject = <String, double>{};
    for (final e in entries) {
      hoursPerProject[e.projectName] =
          (hoursPerProject[e.projectName] ?? 0) + e.totalTime;
    }
    final topProject = hoursPerProject.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final hoursThisWeek = entries
        .where(
          (e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))),
        )
        .fold(0.0, (s, e) => s + e.totalTime);

    final last7DaysActivity = <String, double>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = _dayKey(day);
      last7DaysActivity[key] = 0.0;
    }
    for (final e in entries) {
      final key = _dayKey(e.date);
      if (last7DaysActivity.containsKey(key)) {
        last7DaysActivity[key] = last7DaysActivity[key]! + e.totalTime;
      }
    }

    final clusters = _kMeans(entries, k: MLConfig.clusterCount);
    final silhouette = _silhouetteScore(clusters);

    _insights = ProductivityInsights(
      totalHours: totalHours,
      avgHoursPerDay: avgHoursPerDay,
      mostProductiveDay: mostProductiveDay,
      topProject: topProject,
      hoursThisWeek: hoursThisWeek,
      hoursPerProject: hoursPerProject,
      last7DaysActivity: last7DaysActivity,
      clusters: clusters,
      silhouetteScore: silhouette,
    );

    notifyListeners();
  }

  /// Mean silhouette coefficient over all points (1-D durations).
  ///
  /// For each point: a = mean distance to other points in its own cluster,
  /// b = lowest mean distance to points of any other cluster, and the
  /// coefficient is (b - a) / max(a, b). Returns 0 when it can't be defined
  /// (fewer than two non-empty clusters).
  double _silhouetteScore(List<SessionCluster> clusters) {
    final populated = clusters.where((c) => c.entries.isNotEmpty).toList();
    if (populated.length < 2) return 0.0;

    final values = populated
        .map((c) => c.entries.map((e) => e.totalTime).toList())
        .toList();

    double totalScore = 0;
    int count = 0;
    for (int ci = 0; ci < values.length; ci++) {
      final own = values[ci];
      for (final x in own) {
        // a: mean intra-cluster distance (excluding the point itself).
        double a = 0;
        if (own.length > 1) {
          a = own.fold(0.0, (s, y) => s + (x - y).abs()) / (own.length - 1);
        }
        // b: lowest mean distance to any other cluster.
        double b = double.infinity;
        for (int cj = 0; cj < values.length; cj++) {
          if (cj == ci) continue;
          final other = values[cj];
          final mean =
              other.fold(0.0, (s, y) => s + (x - y).abs()) / other.length;
          if (mean < b) b = mean;
        }
        final denom = max(a, b);
        if (denom > 0) totalScore += (b - a) / denom;
        count++;
      }
    }
    return count == 0 ? 0.0 : totalScore / count;
  }

  // K-Means clustering implementation using Lloyd's algorithm
  List<SessionCluster> _kMeans(List<TimeEntry> entries, {required int k}) {
    if (entries.isEmpty) return [];

    final values = entries.map((e) => e.totalTime).toList();
    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);

    if (maxVal == minVal) {
      return [
        SessionCluster(
          label: 'Moderate Sessions',
          color: AppColors.warning,
          entries: entries,
          centroid: minVal,
        ),
      ];
    }

    List<double> centroids = List.generate(
      k,
      (i) => minVal + (maxVal - minVal) * i / (k - 1),
    );

    List<int> assignments = List.filled(entries.length, 0);

    for (int iter = 0; iter < MLConfig.maxKMeansIterations; iter++) {
      bool changed = false;
      for (int i = 0; i < values.length; i++) {
        int best = 0;
        double bestDist = (values[i] - centroids[0]).abs();
        for (int c = 1; c < k; c++) {
          final d = (values[i] - centroids[c]).abs();
          if (d < bestDist) {
            bestDist = d;
            best = c;
          }
        }
        if (assignments[i] != best) {
          assignments[i] = best;
          changed = true;
        }
      }

      if (!changed) break;

      for (int c = 0; c < k; c++) {
        final clusterVals = <double>[];
        for (int i = 0; i < values.length; i++) {
          if (assignments[i] == c) clusterVals.add(values[i]);
        }
        if (clusterVals.isNotEmpty) {
          centroids[c] =
              clusterVals.reduce((a, b) => a + b) / clusterVals.length;
        }
      }
    }

    final indexed = List.generate(k, (c) {
      final clusterEntries = <TimeEntry>[];
      for (int i = 0; i < entries.length; i++) {
        if (assignments[i] == c) clusterEntries.add(entries[i]);
      }
      return (centroid: centroids[c], entries: clusterEntries);
    });

    indexed.sort((a, b) => a.centroid.compareTo(b.centroid));

    final labels = [
      'Light Sessions',
      'Moderate Sessions',
      'Deep Work Sessions',
    ];
    final colors = [AppColors.success, AppColors.warning, AppColors.primary];

    return List.generate(k, (i) {
      if (indexed[i].entries.isEmpty) return null;
      return SessionCluster(
        label: labels[i],
        color: colors[i],
        entries: indexed[i].entries,
        centroid: indexed[i].centroid,
      );
    }).whereType<SessionCluster>().toList();
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
