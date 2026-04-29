// This file contains the dark mode fixes for dashboard_screen.dart
// Replace the _buildRecentProjects and _buildRecentActivity methods with these versions

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

  final projectHours = <String, double>{};
  for (final entry in repo.entries) {
    projectHours[entry.projectName] = (projectHours[entry.projectName] ?? 0) + entry.totalTime;
  }

  final sortedProjects = projectHours.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
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

Widget _buildRecentActivity(BuildContext context, ProductivityRepository repo) {
  final l = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
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
