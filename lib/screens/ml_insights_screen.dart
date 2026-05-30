import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/time_tracker_provider.dart';
import '../services/forecast_service.dart';
import '../services/ml_service.dart';
import '../theme/app_colors.dart';

class MLInsightsScreen extends StatelessWidget {
  const MLInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.watch<ProductivityRepository>();
    final entries = repo.entries;

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.mlInsights)),
        body: Center(child: Text(l.mlNoData)),
      );
    }

    final score = MLService.calculateProductivityScore(entries);
    final anomalies = MLService.detectAnomalies(entries);
    final patterns = MLService.recognizePatterns(entries);
    final recommendations = MLService.generateRecommendations(entries);
    final forecast = ForecastService.forecast(entries);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.mlInsights),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProductivityScoreCard(score: score),
          const SizedBox(height: 16),
          _ForecastCard(forecast: forecast),
          const SizedBox(height: 16),
          _AnomaliesCard(anomalies: anomalies),
          const SizedBox(height: 16),
          _PatternsCard(patterns: patterns),
          const SizedBox(height: 16),
          _RecommendationsCard(recommendations: recommendations),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRODUCTIVITY SCORE CARD
// ══════════════════════════════════════════════════════════════════════════════

class _ProductivityScoreCard extends StatelessWidget {
  final ProductivityScore score;
  const _ProductivityScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l.productivityScore,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${score.overall}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(score.overall),
                    ),
                  ),
                  Text(
                    _scoreLabel(l, score.overall),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ScoreBar(label: l.scoreVolume, score: score.volume),
            _ScoreBar(label: l.scoreConsistency, score: score.consistency),
            _ScoreBar(label: l.scoreFocus, score: score.focus),
            _ScoreBar(label: l.scoreBalance, score: score.balance),
            _ScoreBar(label: l.scoreEfficiency, score: score.efficiency),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...score.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel(AppLocalizations l, int score) {
    if (score >= 80) return l.scoreExcellent;
    if (score >= 60) return l.scoreGood;
    if (score >= 40) return l.scoreFair;
    return l.scoreNeedsImprovement;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FORECAST CARD (supervised regression)
// ══════════════════════════════════════════════════════════════════════════════

class _ForecastCard extends StatelessWidget {
  final ProductivityForecast? forecast;
  const _ForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final f = forecast;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l.forecastTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (f != null) ...[const Spacer(), _TrendChip(trend: f.trend)],
              ],
            ),
            const SizedBox(height: 12),
            if (f == null)
              Text(
                l.forecastInsufficient,
                style: const TextStyle(color: Colors.grey),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _ForecastStat(
                      label: l.forecastNextDay,
                      value: '${f.nextDayHours.toStringAsFixed(1)}h',
                    ),
                  ),
                  Expanded(
                    child: _ForecastStat(
                      label: l.forecastNext7Days,
                      value: '${f.next7DaysHours.toStringAsFixed(1)}h',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l.modelAccuracy,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(name: 'MAE', value: '${f.mae.toStringAsFixed(2)}h'),
                  _Metric(name: 'RMSE', value: '${f.rmse.toStringAsFixed(2)}h'),
                  _Metric(name: 'R²', value: f.r2.toStringAsFixed(2)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.forecastValidation(f.trainDays, f.testDays),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final String trend;
  const _TrendChip({required this.trend});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (IconData icon, Color color, String label) = switch (trend) {
      'increasing' => (Icons.trending_up, AppColors.success, l.trendIncreasing),
      'decreasing' => (
        Icons.trending_down,
        AppColors.danger,
        l.trendDecreasing,
      ),
      _ => (Icons.trending_flat, AppColors.textMuted, l.trendStable),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastStat extends StatelessWidget {
  final String label;
  final String value;
  const _ForecastStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String name;
  final String value;
  const _Metric({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            color: score >= 70
                ? Colors.green
                : score >= 50
                ? Colors.orange
                : Colors.red,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANOMALIES CARD
// ══════════════════════════════════════════════════════════════════════════════

class _AnomaliesCard extends StatelessWidget {
  final List<Anomaly> anomalies;
  const _AnomaliesCard({required this.anomalies});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  l.anomalyDetection,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (anomalies.isEmpty)
              Text(l.noAnomalies, style: const TextStyle(color: Colors.green))
            else
              ...anomalies.take(5).map((a) => _AnomalyTile(anomaly: a)),
          ],
        ),
      ),
    );
  }
}

class _AnomalyTile extends StatelessWidget {
  final Anomaly anomaly;
  const _AnomalyTile({required this.anomaly});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _severityColor(anomaly.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _severityColor(anomaly.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _anomalyIcon(anomaly.type),
            color: _severityColor(anomaly.severity),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anomaly.message, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  _formatDate(anomaly.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _anomalyIcon(AnomalyType type) {
    switch (type) {
      case AnomalyType.unusualHours:
        return Icons.access_time;
      case AnomalyType.unusualTime:
        return Icons.nightlight;
      case AnomalyType.longGap:
        return Icons.event_busy;
      case AnomalyType.weekendWork:
        return Icons.weekend;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PATTERNS CARD
// ══════════════════════════════════════════════════════════════════════════════

class _PatternsCard extends StatelessWidget {
  final List<Pattern> patterns;
  const _PatternsCard({required this.patterns});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l.patternRecognition,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (patterns.isEmpty)
              Text(l.noPatterns, style: const TextStyle(color: Colors.grey))
            else
              ...patterns.map((p) => _PatternTile(pattern: p)),
          ],
        ),
      ),
    );
  }
}

class _PatternTile extends StatelessWidget {
  final Pattern pattern;
  const _PatternTile({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _impactColor(pattern.impact).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _impactColor(pattern.impact).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _patternIcon(pattern.type),
            color: _impactColor(pattern.impact),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pattern.description, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.confidenceLabel}: ${(pattern.confidence * 100).toInt()}%',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _impactColor(pattern.impact),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pattern.impact,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _impactColor(String impact) {
    switch (impact) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _patternIcon(PatternType type) {
    switch (type) {
      case PatternType.taskSequence:
        return Icons.swap_horiz;
      case PatternType.dayOfWeek:
        return Icons.calendar_today;
      case PatternType.breaks:
        return Icons.coffee;
      case PatternType.taskSwitching:
        return Icons.shuffle;
      case PatternType.timeOfDay:
        return Icons.schedule;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECOMMENDATIONS CARD
// ══════════════════════════════════════════════════════════════════════════════

class _RecommendationsCard extends StatelessWidget {
  final List<Recommendation> recommendations;
  const _RecommendationsCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recommend, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  l.recommendations,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recommendations.isEmpty)
              Text(
                l.noRecommendations,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...recommendations.map(
                (r) => _RecommendationTile(recommendation: r),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final Recommendation recommendation;
  const _RecommendationTile({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _priorityColor(recommendation.priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _priorityColor(recommendation.priority).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _recommendationIcon(recommendation.type),
                color: _priorityColor(recommendation.priority),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _priorityColor(recommendation.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  recommendation.priority.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                recommendation.expectedImpact,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _recommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.scheduling:
        return Icons.schedule;
      case RecommendationType.focus:
        return Icons.center_focus_strong;
      case RecommendationType.breaks:
        return Icons.free_breakfast;
      case RecommendationType.balance:
        return Icons.balance;
      case RecommendationType.consistency:
        return Icons.repeat;
    }
  }
}
