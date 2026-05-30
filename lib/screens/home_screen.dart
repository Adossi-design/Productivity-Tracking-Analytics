import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_auth_provider.dart';
import '../providers/insights_provider.dart';
import '../providers/time_tracker_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/time_entry.dart';
import '../l10n/app_localizations.dart';
import '../widgets/drawer_item.dart';
import 'unified_schedule_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';
import 'ml_insights_screen.dart';
import 'insights_screen.dart';
import 'dashboard_screen.dart';

// All Time Entries screen - shows flat list or grouped by project
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.watch<ProductivityRepository>();

    // Compute insights whenever entries change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().compute(repo.entries.toList());
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: _buildDrawer(context, l),
      appBar: AppBar(
        title: Text(l.appTitle),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Consumer<ProductivityRepository>(
            builder: (ctx, r, _) => IconButton(
              icon: Icon(
                r.groupByProject ? Icons.view_list : Icons.folder_open,
              ),
              tooltip: r.groupByProject ? l.listView : l.groupByProject,
              onPressed: r.toggleGroupByProject,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l.allEntries),
            Tab(text: l.projects),
          ],
        ),
      ),
      body: repo.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : repo.error != null
          ? _ErrorView(error: repo.error!, onRetry: repo.reload)
          : Column(
              children: [
                // ── Quick action bar ─────────────────────────────
                _QuickActionBar(
                  onSchedule: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UnifiedScheduleScreen(),
                    ),
                  ),
                ),
                // ── Tab content ──────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _TimeEntryListTab(),
                      _ProjectAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l) {
    final auth = context.read<AppAuthProvider>();
    final repo = context.watch<ProductivityRepository>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: isDark ? const Color(0xFF1E1E3A) : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 180,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF4F46E5), const Color(0xFF6366F1)]
                      : [const Color(0xFF6366F1), const Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ML Time Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${repo.entries.length} sessions tracked',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppDrawerItem(
              icon: Icons.dashboard_rounded,
              title: l.dashboard,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
            AppDrawerItem(
              icon: Icons.add_circle_outline_rounded,
              title: l.scheduleSession,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnifiedScheduleScreen(),
                  ),
                );
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            AppDrawerItem(
              icon: Icons.list_alt_rounded,
              title: l.allTimeEntries,
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
            AppDrawerItem(
              icon: Icons.folder_rounded,
              title: l.projects,
              trailing: '${repo.projects.length}',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProjectManagementScreen(),
                  ),
                );
              },
            ),
            AppDrawerItem(
              icon: Icons.task_alt_rounded,
              title: l.tasks,
              trailing: '${repo.tasks.length}',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TaskManagementScreen(),
                  ),
                );
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            AppDrawerItem(
              icon: Icons.auto_awesome_rounded,
              title: l.mlInsights,
              badge: repo.entries.length >= 5 ? 'NEW' : null,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MLInsightsScreen()),
                );
              },
            ),
            AppDrawerItem(
              icon: Icons.insights_rounded,
              title: l.insightsTitle,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsightsScreen()),
                );
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            AppDrawerItem(
              icon: Icons.settings_rounded,
              title: l.settings,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l.settings} coming soon!')),
                );
              },
            ),
            AppDrawerItem(
              icon: Icons.help_outline_rounded,
              title: l.helpAndSupport,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l.helpAndSupport} coming soon!')),
                );
              },
            ),
            const Divider(height: 24),
            SwitchListTile(
              secondary: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: const Color(0xFF6366F1),
              ),
              title: Text(themeProvider.isDark ? l.darkMode : l.lightMode),
              value: themeProvider.isDark,
              activeThumbColor: const Color(0xFF6366F1),
              onChanged: (_) => themeProvider.toggle(),
            ),
            ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: Color(0xFF6366F1),
              ),
              title: Text(l.language),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localeProvider.locale.languageCode == 'en'
                      ? '🇬🇧 EN'
                      : '🇫🇷 FR',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () => localeProvider.toggle(),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: Text(
                l.signOut,
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
              onTap: () async {
                Navigator.pop(context);
                await auth.signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Quick action bar ───────────────────────────────────────────────────────

class _QuickActionBar extends StatelessWidget {
  final VoidCallback onSchedule;

  const _QuickActionBar({required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E3A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onSchedule,
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: Text(
            '📅 ${AppLocalizations.of(context)!.scheduleNewSession}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isPermission =
        error.contains('permission') ||
        error.contains('PERMISSION_DENIED') ||
        error.contains('Missing or insufficient');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPermission
                  ? 'Firestore Permission Denied'
                  : 'Failed to load data',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isPermission
                  ? 'Go to Firebase Console → Firestore → Rules and allow authenticated users to read/write their own data.'
                  : error,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tabs ───────────────────────────────────────────────────────────────────

class _TimeEntryListTab extends StatelessWidget {
  const _TimeEntryListTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<ProductivityRepository>(
      builder: (ctx, repo, _) {
        if (repo.entries.isEmpty) {
          return _EmptyState(
            icon: Icons.access_time,
            message: l.noTimeEntries,
            subtitle: l.noTimeEntriesSubtitle,
          );
        }
        if (repo.groupByProject) {
          return _GroupedListView(grouped: repo.timeEntriesGroupedByProject);
        }
        return _FlatListView(entries: repo.entries.toList());
      },
    );
  }
}

class _ProjectAnalyticsTab extends StatelessWidget {
  const _ProjectAnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<ProductivityRepository>(
      builder: (ctx, repo, _) {
        final grouped = repo.timeEntriesGroupedByProject;
        if (grouped.isEmpty) {
          return _EmptyState(
            icon: Icons.folder_open,
            message: l.noProjectAnalytics,
            subtitle: l.noProjectAnalyticsSubtitle,
          );
        }
        return _GroupedListView(grouped: grouped);
      },
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

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
              child: Icon(icon, size: 64, color: const Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Flat list ──────────────────────────────────────────────────────────────

class _FlatListView extends StatelessWidget {
  final List<TimeEntry> entries;
  const _FlatListView({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (ctx, i) => _EntryCard(entry: entries[i]),
    );
  }
}

// ── Grouped list ───────────────────────────────────────────────────────────

class _GroupedListView extends StatelessWidget {
  final Map<String, List<TimeEntry>> grouped;
  const _GroupedListView({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final projectNames = grouped.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projectNames.length,
      itemBuilder: (ctx, i) {
        final name = projectNames[i];
        final projectEntries = grouped[name]!;
        final total = projectEntries.fold(0.0, (s, e) => s + e.totalTime);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(1)}h',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ...projectEntries.map((e) => _EntryCard(entry: e)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ── Entry card ─────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final TimeEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final repo = context.read<ProductivityRepository>();
    // Check if this entry has scheduled start/end times
    final hasSchedule = entry.startTime != null && entry.endTime != null;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(l.deleteTimeEntry),
                content: Text(l.deleteTimeEntryConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      l.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => repo.deleteEntry(entry.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D4A)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Duration badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${entry.totalTime.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.taskName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.folder_outlined,
                          size: 13,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.projectName,
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Show start/end time if available
                    if (hasSchedule) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('HH:mm').format(entry.startTime!)} – ${DateFormat('HH:mm').format(entry.endTime!)}',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.notes,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d').format(entry.date),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l.deleteTimeEntry),
                          content: Text(l.deleteTimeEntryPermanent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        repo.deleteEntry(entry.id);
                      }
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
