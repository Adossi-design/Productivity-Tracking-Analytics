/// Tunable parameters for the analytics/ML layer.
///
/// These were previously magic numbers inlined across [MLService] and
/// [InsightsProvider]. Centralising them documents the "model" and makes the
/// heuristics reviewable and adjustable in one place.
class MLConfig {
  MLConfig._();

  // ── Minimum data requirements ──────────────────────────────────────────────
  /// Entries needed before clustering/insights are meaningful.
  static const int minEntriesForInsights = 5;

  /// Entries needed before anomaly detection / recommendations run.
  static const int minEntriesForAnomalies = 7;

  /// Entries needed before pattern recognition runs.
  static const int minEntriesForPatterns = 10;

  /// Entries needed before a productivity score is computed.
  static const int minEntriesForScore = 3;

  // ── Clustering ─────────────────────────────────────────────────────────────
  /// Number of session clusters (light / moderate / deep work).
  static const int clusterCount = 3;

  /// Max Lloyd's-algorithm iterations before forced convergence.
  static const int maxKMeansIterations = 100;

  // ── Forecasting (supervised regression) ─────────────────────────────────────
  /// Distinct calendar days of history needed before a forecast is produced.
  static const int minDaysForForecast = 8;

  /// Fraction of the (chronological) series used for training; the remainder is
  /// held out to evaluate the model.
  static const double forecastTrainFraction = 0.8;

  /// |slope| (hours/day) below this is reported as a flat trend.
  static const double forecastFlatSlope = 0.1;

  // ── Anomaly thresholds ──────────────────────────────────────────────────────
  /// A day above (avg × this) is flagged as unusually high.
  static const double unusualDayMultiplier = 2.0;

  /// A day above (avg × this) is flagged as high severity.
  static const double unusualDayHighSeverityMultiplier = 3.0;

  /// Hour-of-day below this is considered "late night" work.
  static const int lateNightHourCutoff = 5;

  /// Gap (in days) without logged work that counts as a long gap.
  static const int longGapDays = 5;

  /// Gap (in days) that counts as a high-severity long gap.
  static const int longGapHighSeverityDays = 10;

  // ── Pattern / recommendation thresholds ─────────────────────────────────────
  /// Project-switch rate above this is flagged as high context switching.
  static const double highSwitchRate = 0.5;

  /// Average projects/day above this triggers a focus recommendation.
  static const double maxHealthyProjectsPerDay = 4;

  /// Average session length (hours) above this triggers a breaks recommendation.
  static const double longSessionHours = 4;

  /// Weekend work ratio above this triggers a balance recommendation.
  static const double maxHealthyWeekendRatio = 0.25;

  /// Consistency score below this triggers a consistency recommendation.
  static const double minHealthyConsistency = 0.6;

  // ── Scoring ──────────────────────────────────────────────────────────────────
  /// Weekly hours target used to compute the volume sub-score.
  static const double weeklyHoursTarget = 35.0;

  /// Sub-score below this surfaces an actionable insight.
  static const int insightThreshold = 70;
}
