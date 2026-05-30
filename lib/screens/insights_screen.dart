import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/insights_provider.dart';
import '../providers/time_tracker_provider.dart';
import '../l10n/app_localizations.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.watch<ProductivityRepository>();
    final insightsProvider = context.read<InsightsProvider>();

    // Recompute whenever entries change
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => insightsProvider.compute(repo.entries.toList()),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: Text(
          l.insightsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<InsightsProvider>(
        builder: (ctx, provider, _) {
          if (repo.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }
          if (!provider.hasEnoughData) {
            return _EmptyInsights(l: l);
          }
          final ins = provider.insights!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryRow(ins: ins, l: l),
              const SizedBox(height: 16),
              _SectionCard(
                title: l.hoursPerProject,
                child: _ProjectPieChart(ins: ins),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l.dailyActivity,
                child: _DailyBarChart(ins: ins),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l.behaviorClusters,
                child: _ClusterList(ins: ins, l: l),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyInsights extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyInsights({required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.notEnoughData,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l.notEnoughDataSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary row ────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final ProductivityInsights ins;
  final AppLocalizations l;
  const _SummaryRow({required this.ins, required this.l});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: l.totalHours,
          value: '${ins.totalHours.toStringAsFixed(1)}h',
          icon: Icons.access_time,
          color: const Color(0xFF6366F1),
        ),
        _StatCard(
          label: l.avgHoursPerDay,
          value: '${ins.avgHoursPerDay.toStringAsFixed(1)}h',
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
        ),
        _StatCard(
          label: l.mostProductiveDay,
          value: ins.mostProductiveDay,
          icon: Icons.star,
          color: const Color(0xFFF59E0B),
        ),
        _StatCard(
          label: l.hoursThisWeek,
          value: '${ins.hoursThisWeek.toStringAsFixed(1)}h',
          icon: Icons.calendar_today,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card wrapper ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Pie chart ──────────────────────────────────────────────────────────────

class _ProjectPieChart extends StatelessWidget {
  final ProductivityInsights ins;
  const _ProjectPieChart({required this.ins});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    final entries = ins.hoursPerProject.entries.toList();
    final total = ins.totalHours;

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final pct = total > 0 ? entries[i].value / total * 100 : 0.0;
                  return PieChartSectionData(
                    value: entries[i].value,
                    color: colors[i % colors.length],
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entries[i].key} (${entries[i].value.toStringAsFixed(1)}h)',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Bar chart ──────────────────────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  final ProductivityInsights ins;
  const _DailyBarChart({required this.ins});

  @override
  Widget build(BuildContext context) {
    final days = ins.last7DaysActivity.entries.toList();
    final maxY = days.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          barGroups: List.generate(days.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].value,
                  color: const Color(0xFF6366F1),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final date = DateTime.parse(days[val.toInt()].key);
                  return Text(
                    DateFormat('E').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

// ── Cluster list ───────────────────────────────────────────────────────────

class _ClusterList extends StatelessWidget {
  final ProductivityInsights ins;
  final AppLocalizations l;
  const _ClusterList({required this.ins, required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ins.clusters.length >= 2) ...[
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(width: 6),
              Text(
                '${l.clusterQuality}: ${ins.clusterQuality} '
                '(${ins.silhouetteScore.toStringAsFixed(2)})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        ...ins.clusters.map((cluster) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cluster.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cluster.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cluster.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cluster.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cluster.color,
                        ),
                      ),
                      Text(
                        '${cluster.entries.length} sessions · '
                        '${cluster.totalHours.toStringAsFixed(1)}h total · '
                        'avg ${cluster.centroid.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
