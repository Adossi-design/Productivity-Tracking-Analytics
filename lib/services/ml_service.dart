import 'dart:math';
import '../config/ml_config.dart';
import '../models/time_entry.dart';

// ML analytics service with anomaly detection and pattern recognition
class MLService {
  static List<Anomaly> detectAnomalies(List<TimeEntry> entries) {
    if (entries.length < MLConfig.minEntriesForAnomalies) return [];

    final anomalies = <Anomaly>[];
    final stats = _computeStats(entries);

    final dailyHours = _groupByDay(entries);
    for (final entry in dailyHours.entries) {
      final hours = entry.value;
      if (hours > stats.avgDailyHours * MLConfig.unusualDayMultiplier) {
        anomalies.add(
          Anomaly(
            type: AnomalyType.unusualHours,
            severity:
                hours >
                    stats.avgDailyHours *
                        MLConfig.unusualDayHighSeverityMultiplier
                ? 'high'
                : 'medium',
            message:
                'Worked ${hours.toStringAsFixed(1)}h on ${_formatDate(entry.key)} - ${((hours / stats.avgDailyHours - 1) * 100).toInt()}% above your average',
            date: entry.key,
          ),
        );
      }
    }

    for (final e in entries.where((e) => e.startTime != null)) {
      final hour = e.startTime!.hour;
      if (hour >= 0 && hour < MLConfig.lateNightHourCutoff) {
        anomalies.add(
          Anomaly(
            type: AnomalyType.unusualTime,
            severity: 'medium',
            message:
                'Logged ${e.totalTime.toStringAsFixed(1)}h at $hour:${e.startTime!.minute.toString().padLeft(2, '0')} - unusual time for work',
            date: e.date,
          ),
        );
      }
    }

    // Flag long gaps between logged days. The single largest qualifying gap is
    // labelled as the longest; others are reported plainly (the previous code
    // wrongly called every gap "the longest").
    final sortedDates = entries.map((e) => e.date).toList()..sort();
    final gaps = <({int gap, DateTime date})>[];
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final gap = sortedDates[i + 1].difference(sortedDates[i]).inDays;
      if (gap > MLConfig.longGapDays) {
        gaps.add((gap: gap, date: sortedDates[i]));
      }
    }
    final maxGap = gaps.isEmpty ? 0 : gaps.map((g) => g.gap).reduce(max);
    for (final g in gaps) {
      final isLongest = g.gap == maxGap;
      anomalies.add(
        Anomaly(
          type: AnomalyType.longGap,
          severity: g.gap > MLConfig.longGapHighSeverityDays ? 'high' : 'low',
          message: isLongest
              ? '${g.gap} days without work logged - your longest recent gap'
              : '${g.gap} days without work logged',
          date: g.date,
        ),
      );
    }

    final weekendHours = entries
        .where((e) => e.date.weekday >= 6)
        .fold(0.0, (sum, e) => sum + e.totalTime);
    final weekdayHours = entries
        .where((e) => e.date.weekday < 6)
        .fold(0.0, (sum, e) => sum + e.totalTime);
    if (weekendHours > 0 && weekdayHours > 0) {
      final ratio = weekendHours / weekdayHours;
      if (ratio > 0.3) {
        anomalies.add(
          Anomaly(
            type: AnomalyType.weekendWork,
            severity: 'medium',
            message:
                '${weekendHours.toStringAsFixed(1)}h weekend work - ${(ratio * 100).toInt()}% of weekday hours',
            date: DateTime.now(),
          ),
        );
      }
    }

    return anomalies..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Pattern> recognizePatterns(List<TimeEntry> entries) {
    if (entries.length < MLConfig.minEntriesForPatterns) return [];

    final patterns = <Pattern>[];

    final sequences = _findTaskSequences(entries);
    for (final seq in sequences.entries) {
      if (seq.value > 2) {
        patterns.add(
          Pattern(
            type: PatternType.taskSequence,
            description:
                'You often work on "${seq.key.second}" after "${seq.key.first}"',
            confidence: min(seq.value / 5.0, 1.0),
            impact: 'positive',
          ),
        );
      }
    }

    final dayStats = _groupByWeekday(entries);
    final avgHours =
        (dayStats.values.fold(0.0, (a, b) => a + b) / dayStats.length)
            .toDouble();
    final bestDay = dayStats.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final worstDay = dayStats.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    if (bestDay.value > avgHours * 1.3) {
      patterns.add(
        Pattern(
          type: PatternType.dayOfWeek,
          description:
              'Your productivity peaks on ${_dayName(bestDay.key)} (${((bestDay.value / avgHours - 1) * 100).toInt()}% above average)',
          confidence: 0.8,
          impact: 'positive',
        ),
      );
    }

    if (worstDay.value < avgHours * 0.7) {
      patterns.add(
        Pattern(
          type: PatternType.dayOfWeek,
          description:
              'Productivity drops ${((1 - worstDay.value / avgHours) * 100).toInt()}% on ${_dayName(worstDay.key)}',
          confidence: 0.75,
          impact: 'negative',
        ),
      );
    }

    final breakPattern = _analyzeBreakPattern(entries);
    if (breakPattern != null) patterns.add(breakPattern);

    final switchRate = _calculateSwitchRate(entries);
    if (switchRate > MLConfig.highSwitchRate) {
      patterns.add(
        Pattern(
          type: PatternType.taskSwitching,
          description:
              'High task switching detected - you switch projects ${(switchRate * 100).toInt()}% of the time',
          confidence: 0.85,
          impact: 'negative',
        ),
      );
    }

    final timePattern = _analyzeTimeOfDay(entries);
    if (timePattern != null) patterns.add(timePattern);

    return patterns;
  }

  static List<Recommendation> generateRecommendations(List<TimeEntry> entries) {
    if (entries.length < MLConfig.minEntriesForAnomalies) return [];

    final recommendations = <Recommendation>[];
    final stats = _computeStats(entries);

    final timeAnalysis = _analyzeOptimalTimes(entries);
    for (final rec in timeAnalysis) {
      recommendations.add(rec);
    }

    if (stats.avgProjectsPerDay > MLConfig.maxHealthyProjectsPerDay) {
      recommendations.add(
        Recommendation(
          type: RecommendationType.focus,
          title: 'Reduce Context Switching',
          description:
              'You work on ${stats.avgProjectsPerDay.toStringAsFixed(1)} projects/day. Try limiting to 3-4 for better focus.',
          priority: 'high',
          expectedImpact: '+15-20% productivity',
        ),
      );
    }

    final avgSessionLength = _calculateAvgSessionLength(entries);
    if (avgSessionLength > MLConfig.longSessionHours) {
      recommendations.add(
        Recommendation(
          type: RecommendationType.breaks,
          title: 'Take More Breaks',
          description:
              'Your average session is ${avgSessionLength.toStringAsFixed(1)}h. Consider 5-10min breaks every 90min.',
          priority: 'medium',
          expectedImpact: '+10% sustained focus',
        ),
      );
    }

    final weekendRatio = _calculateWeekendRatio(entries);
    if (weekendRatio > MLConfig.maxHealthyWeekendRatio) {
      recommendations.add(
        Recommendation(
          type: RecommendationType.balance,
          title: 'Improve Work-Life Balance',
          description:
              '${(weekendRatio * 100).toInt()}% of your work happens on weekends. Consider redistributing to weekdays.',
          priority: 'high',
          expectedImpact: 'Reduced burnout risk',
        ),
      );
    }

    final consistency = _calculateConsistency(entries);
    if (consistency < MLConfig.minHealthyConsistency) {
      recommendations.add(
        Recommendation(
          type: RecommendationType.consistency,
          title: 'Build Consistent Habits',
          description:
              'Your work schedule varies significantly. Try establishing regular work blocks.',
          priority: 'medium',
          expectedImpact: '+25% consistency score',
        ),
      );
    }

    return recommendations..sort(
      (a, b) =>
          _priorityValue(b.priority).compareTo(_priorityValue(a.priority)),
    );
  }

  static ProductivityScore calculateProductivityScore(List<TimeEntry> entries) {
    if (entries.length < MLConfig.minEntriesForScore) {
      return ProductivityScore(
        overall: 50,
        volume: 50,
        consistency: 50,
        focus: 50,
        balance: 50,
        efficiency: 50,
        insights: [
          'Need more data for accurate scoring '
              '(minimum ${MLConfig.minEntriesForScore} entries)',
        ],
      );
    }

    final stats = _computeStats(entries);
    final insights = <String>[];
    const threshold = MLConfig.insightThreshold;

    const targetHours = MLConfig.weeklyHoursTarget;
    final volumeScore = min(
      (stats.totalHours / targetHours) * 100,
      100,
    ).toInt();
    if (volumeScore < threshold) {
      insights.add(
        'Volume below target - worked ${stats.totalHours.toStringAsFixed(1)}h vs ${targetHours.toStringAsFixed(0)}h target',
      );
    }

    final consistencyScore = (_calculateConsistency(entries) * 100).toInt();
    if (consistencyScore < threshold) {
      insights.add(
        'Inconsistent schedule - try establishing regular work blocks',
      );
    }

    final switchRate = _calculateSwitchRate(entries);
    final focusScore = ((1 - switchRate) * 100).toInt();
    if (focusScore < threshold) {
      insights.add(
        'High task fragmentation - worked on ${stats.avgProjectsPerDay.toStringAsFixed(1)} projects/day',
      );
    }

    final weekendRatio = _calculateWeekendRatio(entries);
    final balanceScore = (max(0, 1 - weekendRatio * 2) * 100).toInt();
    if (balanceScore < threshold) {
      insights.add(
        'Work-life balance needs attention - ${(weekendRatio * 100).toInt()}% weekend work',
      );
    }

    final avgSession = _calculateAvgSessionLength(entries);
    final efficiencyScore = avgSession > 2 && avgSession < 4
        ? 90
        : (avgSession > 4 ? 60 : 70);
    if (efficiencyScore < threshold) {
      insights.add(
        'Session length suboptimal - average ${avgSession.toStringAsFixed(1)}h per session',
      );
    }

    final overall =
        ((volumeScore +
                    consistencyScore +
                    focusScore +
                    balanceScore +
                    efficiencyScore) /
                5)
            .round();

    if (insights.isEmpty) {
      insights.add('Great work! All productivity metrics are healthy');
    }

    return ProductivityScore(
      overall: overall,
      volume: volumeScore,
      consistency: consistencyScore,
      focus: focusScore,
      balance: balanceScore,
      efficiency: efficiencyScore,
      insights: insights,
    );
  }

  static _Stats _computeStats(List<TimeEntry> entries) {
    final totalHours = entries.fold(0.0, (sum, e) => sum + e.totalTime);
    final days = entries.map((e) => _dateKey(e.date)).toSet().length;
    final avgDailyHours = days > 0 ? (totalHours / days).toDouble() : 0.0;

    final projectsPerDay = <String, Set<String>>{};
    for (final e in entries) {
      projectsPerDay.putIfAbsent(_dateKey(e.date), () => {}).add(e.projectName);
    }
    final avgProjectsPerDay =
        (projectsPerDay.values.fold(0, (sum, s) => sum + s.length) /
                max(projectsPerDay.length, 1))
            .toDouble();

    return _Stats(
      totalHours: totalHours,
      avgDailyHours: avgDailyHours,
      avgProjectsPerDay: avgProjectsPerDay,
    );
  }

  static Map<DateTime, double> _groupByDay(List<TimeEntry> entries) {
    final map = <DateTime, double>{};
    for (final e in entries) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + e.totalTime;
    }
    return map;
  }

  static Map<int, double> _groupByWeekday(List<TimeEntry> entries) {
    final map = <int, double>{};
    for (final e in entries) {
      map[e.date.weekday] = (map[e.date.weekday] ?? 0) + e.totalTime;
    }
    return map;
  }

  static Map<_Pair<String, String>, int> _findTaskSequences(
    List<TimeEntry> entries,
  ) {
    final sequences = <_Pair<String, String>, int>{};
    final sorted = entries.toList()..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < sorted.length - 1; i++) {
      final pair = _Pair(sorted[i].taskName, sorted[i + 1].taskName);
      sequences[pair] = (sequences[pair] ?? 0) + 1;
    }
    return sequences;
  }

  static Pattern? _analyzeBreakPattern(List<TimeEntry> entries) {
    final sorted =
        entries.where((e) => e.startTime != null && e.endTime != null).toList()
          ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

    if (sorted.length < 5) return null;

    int longSessions = 0;
    for (final e in sorted) {
      if (e.totalTime > MLConfig.longSessionHours) longSessions++;
    }

    if (longSessions > sorted.length * 0.5) {
      return Pattern(
        type: PatternType.breaks,
        description:
            'You frequently work $longSessions long sessions (>4h) without breaks',
        confidence: 0.8,
        impact: 'negative',
      );
    }
    return null;
  }

  /// Maps an hour-of-day (0-23) to a human-readable slot with correct 12-hour
  /// labelling (fixes the previous "0am"/"0pm" boundary bug).
  static String _describeTimeSlot(int hour) {
    final h = hour % 24;
    final period = h < 12 ? 'am' : 'pm';
    final display = h % 12 == 0 ? 12 : h % 12;
    final part = h < 12
        ? 'morning'
        : h < 18
        ? 'afternoon'
        : 'evening';
    return '$part ($display$period)';
  }

  static double _calculateSwitchRate(List<TimeEntry> entries) {
    if (entries.length < 2) return 0;
    final sorted = entries.toList()..sort((a, b) => a.date.compareTo(b.date));
    int switches = 0;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].projectName != sorted[i + 1].projectName) switches++;
    }
    return switches / (sorted.length - 1);
  }

  static Pattern? _analyzeTimeOfDay(List<TimeEntry> entries) {
    final withTime = entries.where((e) => e.startTime != null).toList();
    if (withTime.length < 5) return null;

    final morningHours = withTime
        .where((e) => e.startTime!.hour >= 6 && e.startTime!.hour < 12)
        .fold(0.0, (sum, e) => sum + e.totalTime);
    final afternoonHours = withTime
        .where((e) => e.startTime!.hour >= 12 && e.startTime!.hour < 18)
        .fold(0.0, (sum, e) => sum + e.totalTime);
    final eveningHours = withTime
        .where((e) => e.startTime!.hour >= 18 && e.startTime!.hour < 24)
        .fold(0.0, (sum, e) => sum + e.totalTime);

    final total = morningHours + afternoonHours + eveningHours;
    if (total == 0) return null;

    if (morningHours / total > 0.5) {
      return Pattern(
        type: PatternType.timeOfDay,
        description:
            'You\'re a morning person - ${(morningHours / total * 100).toInt()}% of work happens 6am-12pm',
        confidence: 0.85,
        impact: 'positive',
      );
    } else if (eveningHours / total > 0.4) {
      return Pattern(
        type: PatternType.timeOfDay,
        description:
            'You work best in evenings - ${(eveningHours / total * 100).toInt()}% of work happens after 6pm',
        confidence: 0.85,
        impact: 'neutral',
      );
    }
    return null;
  }

  static List<Recommendation> _analyzeOptimalTimes(List<TimeEntry> entries) {
    final recommendations = <Recommendation>[];
    final withTime = entries.where((e) => e.startTime != null).toList();
    if (withTime.length < 5) return recommendations;

    // Group by project and time of day
    final projectTimes = <String, List<int>>{};
    for (final e in withTime) {
      projectTimes.putIfAbsent(e.projectName, () => []).add(e.startTime!.hour);
    }

    for (final entry in projectTimes.entries) {
      if (entry.value.length < 3) continue;
      final avgHour = (entry.value.reduce((a, b) => a + b) / entry.value.length)
          .toDouble();
      final timeSlot = _describeTimeSlot(avgHour.round());

      recommendations.add(
        Recommendation(
          type: RecommendationType.scheduling,
          title: 'Optimal Time for ${entry.key}',
          description:
              'You typically work on "${entry.key}" in the $timeSlot - schedule similar tasks then',
          priority: 'medium',
          expectedImpact: '+10% efficiency',
        ),
      );
    }

    return recommendations;
  }

  static double _calculateAvgSessionLength(List<TimeEntry> entries) {
    final withTime = entries.where(
      (e) => e.startTime != null && e.endTime != null,
    );
    if (withTime.isEmpty) return 0;
    return withTime.fold(0.0, (sum, e) => sum + e.totalTime) / withTime.length;
  }

  static double _calculateWeekendRatio(List<TimeEntry> entries) {
    final weekendHours = entries
        .where((e) => e.date.weekday >= 6)
        .fold(0.0, (sum, e) => sum + e.totalTime);
    final totalHours = entries.fold(0.0, (sum, e) => sum + e.totalTime);
    return totalHours > 0 ? weekendHours / totalHours : 0;
  }

  static double _calculateConsistency(List<TimeEntry> entries) {
    final dailyHours = _groupByDay(entries);
    if (dailyHours.length < 3) return 0.5;

    final values = dailyHours.values.toList();
    final avg = values.fold(0.0, (a, b) => a + b) / values.length;
    final variance =
        values.fold(0.0, (sum, v) => sum + pow(v - avg, 2)) / values.length;
    final stdDev = sqrt(variance);

    return max(0, 1 - (stdDev / max(avg, 1)));
  }

  static int _priorityValue(String priority) {
    switch (priority) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
  static String _formatDate(DateTime date) => '${date.month}/${date.day}';
  static String _dayName(int weekday) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ══════════════════════════════════════════════════════════════════════════════

class _Stats {
  final double totalHours;
  final double avgDailyHours;
  final double avgProjectsPerDay;
  _Stats({
    required this.totalHours,
    required this.avgDailyHours,
    required this.avgProjectsPerDay,
  });
}

class _Pair<T1, T2> {
  final T1 first;
  final T2 second;
  _Pair(this.first, this.second);

  @override
  bool operator ==(Object other) =>
      other is _Pair && first == other.first && second == other.second;

  @override
  int get hashCode => Object.hash(first, second);
}

enum AnomalyType { unusualHours, unusualTime, longGap, weekendWork }

class Anomaly {
  final AnomalyType type;
  final String severity;
  final String message;
  final DateTime date;
  Anomaly({
    required this.type,
    required this.severity,
    required this.message,
    required this.date,
  });
}

enum PatternType { taskSequence, dayOfWeek, breaks, taskSwitching, timeOfDay }

class Pattern {
  final PatternType type;
  final String description;
  final double confidence;
  final String impact;
  Pattern({
    required this.type,
    required this.description,
    required this.confidence,
    required this.impact,
  });
}

enum RecommendationType { scheduling, focus, breaks, balance, consistency }

class Recommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final String priority;
  final String expectedImpact;
  Recommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedImpact,
  });
}

class ProductivityScore {
  final int overall;
  final int volume;
  final int consistency;
  final int focus;
  final int balance;
  final int efficiency;
  final List<String> insights;
  ProductivityScore({
    required this.overall,
    required this.volume,
    required this.consistency,
    required this.focus,
    required this.balance,
    required this.efficiency,
    required this.insights,
  });
}
