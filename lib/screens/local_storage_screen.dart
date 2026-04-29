import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';
import '../l10n/app_localizations.dart';

class LocalStorageScreen extends StatelessWidget {
  const LocalStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: Text(l.localStorageInspector,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductivityRepository>().reload(),
          ),
        ],
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) {
          if (repo.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6366F1)));
          }
          final hasData = repo.entries.isNotEmpty ||
              repo.projects.isNotEmpty ||
              repo.tasks.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.storage,
                                color: Color(0xFF6366F1), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(l.storageOverview,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      _CountRow(
                          label: l.timeEntries,
                          count: repo.entries.length,
                          color: const Color(0xFF6366F1)),
                      const SizedBox(height: 8),
                      _CountRow(
                          label: l.projects,
                          count: repo.projects.length,
                          color: const Color(0xFF10B981)),
                      const SizedBox(height: 8),
                      _CountRow(
                          label: l.tasks,
                          count: repo.tasks.length,
                          color: const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!hasData)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storage,
                            size: 64, color: Color(0xFF6366F1)),
                      ),
                      const SizedBox(height: 16),
                      Text(l.storageEmpty,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(l.storageEmptySubtitle,
                          style: const TextStyle(
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              else ...[
                _CollectionCard(
                  label: 'time_entries',
                  icon: Icons.access_time,
                  color: const Color(0xFF6366F1),
                  subtitle: l.sharedPreferencesKey,
                  items: repo.entries
                      .map((e) =>
                          '${e.taskName} · ${e.projectName} · ${e.totalTime}h')
                      .toList(),
                ),
                const SizedBox(height: 12),
                _CollectionCard(
                  label: 'projects',
                  icon: Icons.folder,
                  color: const Color(0xFF10B981),
                  subtitle: l.sharedPreferencesKey,
                  items: repo.projects.map((p) => p.name).toList(),
                ),
                const SizedBox(height: 12),
                _CollectionCard(
                  label: 'tasks',
                  icon: Icons.task_alt,
                  color: const Color(0xFFF59E0B),
                  subtitle: l.sharedPreferencesKey,
                  items: repo.tasks.map((t) => t.name).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountRow(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF6B7280))),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: count == 0
                ? Colors.grey.shade200
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count records',
            style: TextStyle(
                color: count == 0 ? Colors.grey : color,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String subtitle;
  final List<String> items;

  const _CollectionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.items,
  });

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(widget.icon, color: widget.color, size: 20),
            ),
            title: Text(widget.label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.subtitle,
                style: const TextStyle(fontSize: 11)),
            trailing: Icon(
                _expanded
                    ? Icons.expand_less
                    : Icons.expand_more,
                color: const Color(0xFF6B7280)),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $item',
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontFamily: 'monospace',
                                fontSize: 11),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
