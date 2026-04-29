import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_tracker_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/app_auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/ml_service.dart';
import 'ml_insights_screen.dart';
import 'unified_schedule_screen.dart';
import 'home_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

// Main dashboard - shows overview of projects, tasks, and ML insights
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProductivityRepository>();
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: const Color(0xFF6366F1), size: 24),
            const SizedBox(width: 8),
            Text(l.dashboard, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      ),
      drawer: _buildUnifiedDrawer(context, repo),
      body: repo.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : repo.entries.isEmpty
              ? _buildEmptyState(context)
              : _buildDashboardContent(context, repo),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnifiedScheduleScreen())),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.scheduleSession),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              l.welcomeProductivityHub,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.startTrackingMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnifiedScheduleScreen())),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.scheduleFirstSession),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen())),
              icon: const Icon(Icons.folder_outlined),
              label: Text(l.createProjectFirst),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, ProductivityRepository repo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, repo),
          const SizedBox(height: 20),
          _buildQuickStats(context, repo),
          const SizedBox(height: 20),
          _buildRecentProjects(context, repo),
          const SizedBox(height: 20),
          _buildMLInsightsPreview(context, repo),
          const SizedBox(height: 20),
          _buildRecentActivity(context, repo),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, ProductivityRepository repo) {
    final l = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    // Dynamic greeting based on time of day
    final greeting = hour < 12 ? l.goodMorning : hour < 17 ? l.goodAfternoon : l.goodEvening;
    final emoji = hour < 12 ? '🌅' : hour < 17 ? '☀️' : '🌙';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l.readyToBeProductive,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ProductivityRepository repo) {
    final l = AppLocalizations.of(context)!;
    // Calculate hours worked this week
    final thisWeek = repo.entries.where((e) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return e.date.isAfter(weekStart);
    }).fold(0.0, (sum, e) => sum + e.totalTime);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_rounded,
            label: l.projects,
            value: '${repo.projects.length}',
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.task_alt_rounded,
            label: l.tasks,
            value: '${repo.tasks.length}',
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_rounded,
            label: l.thisWeek,
            value: '${thisWeek.toStringAsFixed(0)}h',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProjects(BuildContext context, ProductivityRepository repo) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (repo.projects.isEmpty) {
      return _EmptySection(
        icon: Icons.folder_off_rounded,
        title: l.noProjectsYet,
        subtitle: l.createFirstProject,
        actionLabel: l.createProject,
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen())),
      );
    }

    // Aggregate hours per project
    final projectHours = <String, double>{};
    for (final entry in repo.entries) {
      projectHours[entry.projectName] = (projectHours[entry.projectName] ?? 0) + entry.totalTime;
    }

    final sortedProjects = projectHours.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    // Show top 5 projects by hours
    final topProjects = sortedProjects.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('📁 ${l.topProjects}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen())),
              child: Text(l.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: topProjects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              final isLast = index == topProjects.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1).withValues(alpha: 0.2), Color(0xFF818CF8).withValues(alpha: 0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.folder_rounded, color: Color(0xFF6366F1)),
                    ),
                    title: Text(
                      project.key,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${repo.entries.where((e) => e.projectName == project.key).length} entries',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${project.value.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, indent: 88, color: isDark ? Colors.white12 : Colors.grey[200]),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMLInsightsPreview(BuildContext context, ProductivityRepository repo) {
    final l = AppLocalizations.of(context)!;
    // Need at least 5 entries for meaningful ML analysis
    if (repo.entries.length < 5) {
      return _EmptySection(
        icon: Icons.psychology_rounded,
        title: l.mlInsightsLocked,
        subtitle: '${l.logMoreSessions} ${5 - repo.entries.length} ${l.sessionsToUnlock}',
        actionLabel: l.learnMore,
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MLInsightsScreen())),
      );
    }

    final score = MLService.calculateProductivityScore(repo.entries);
    final anomalies = MLService.detectAnomalies(repo.entries);
    final patterns = MLService.recognizePatterns(repo.entries);

    // Preview card with key ML metrics
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🤖 ${l.mlInsights}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MLInsightsScreen())),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1).withValues(alpha: 0.1), const Color(0xFF818CF8).withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Advanced ML Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Tap to explore detailed insights', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6366F1)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MLStatBadge(
                      icon: Icons.analytics_rounded,
                      label: 'Score',
                      value: '${score.overall}',
                      color: score.overall >= 70 ? Colors.green : Colors.orange,
                    ),
                    _MLStatBadge(
                      icon: Icons.warning_amber_rounded,
                      label: 'Alerts',
                      value: '${anomalies.length}',
                      color: anomalies.isEmpty ? Colors.green : Colors.orange,
                    ),
                    _MLStatBadge(
                      icon: Icons.psychology_rounded,
                      label: 'Patterns',
                      value: '${patterns.length}',
                      color: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, ProductivityRepository repo) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Show last 5 time entries
    final recent = repo.entries.take(5).toList();

    if (recent.isEmpty) {
      return _EmptySection(
        icon: Icons.history_rounded,
        title: l.noActivityYet,
        subtitle: l.recentSessionsAppear,
        actionLabel: l.logTime,
        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnifiedScheduleScreen())),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('📝 ${l.recentActivity}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
              child: Text(l.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: recent.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == recent.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${item.totalTime.toStringAsFixed(1)}h',
                          style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    title: Text(item.taskName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(
                      '${item.projectName} • ${DateFormat('MMM d, h:mm a').format(item.date)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, indent: 88, color: isDark ? Colors.white12 : Colors.grey[200]),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedDrawer(BuildContext context, ProductivityRepository repo) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.read<AppAuthProvider>();
    final l = AppLocalizations.of(context)!;
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
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ML Time Tracker',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${repo.entries.length} sessions tracked',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(icon: Icons.dashboard_rounded, title: l.dashboard, isDark: isDark, onTap: () => Navigator.pop(context)),
            _DrawerItem(
              icon: Icons.add_circle_outline_rounded,
              title: l.scheduleSession,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UnifiedScheduleScreen()));
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            _DrawerItem(
              icon: Icons.list_alt_rounded,
              title: l.allTimeEntries,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.folder_rounded,
              title: l.projects,
              trailing: '${repo.projects.length}',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen()));
              },
            ),
            _DrawerItem(
              icon: Icons.task_alt_rounded,
              title: l.tasks,
              trailing: '${repo.tasks.length}',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskManagementScreen()));
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            _DrawerItem(
              icon: Icons.auto_awesome_rounded,
              title: l.mlInsights,
              badge: repo.entries.length >= 5 ? 'NEW' : null,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MLInsightsScreen()));
              },
            ),
            Divider(height: 24, color: isDark ? Colors.white12 : null),
            _DrawerItem(
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
            _DrawerItem(
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
                themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: const Color(0xFF6366F1),
              ),
              title: Text(themeProvider.isDark ? l.darkMode : l.lightMode),
              value: themeProvider.isDark,
              activeColor: const Color(0xFF6366F1),
              onChanged: (_) => themeProvider.toggle(),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded, color: Color(0xFF6366F1)),
              title: Text(l.language),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localeProvider.locale.languageCode == 'en' ? '🇬🇧 EN' : '🇫🇷 FR',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              onTap: () => localeProvider.toggle(),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: Text(l.signOut, style: const TextStyle(color: Color(0xFFEF4444))),
              onTap: () async {
                Navigator.pop(context);
                await auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _MLStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MLStatBadge({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptySection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(actionLabel),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final String? badge;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.badge,
    this.isDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1), size: 24),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : trailing != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(trailing!, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.bold)),
                )
              : null,
      onTap: onTap,
    );
  }
}
