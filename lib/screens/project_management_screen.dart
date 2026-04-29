import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';
import '../l10n/app_localizations.dart';
import 'project_detail_screen.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  void _showAddDialog(BuildContext context, AppLocalizations l) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.addProject,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.projectName,
            prefixIcon:
                const Icon(Icons.folder, color: Color(0xFF6366F1)),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context
                    .read<ProductivityRepository>()
                    .addProject(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(l.add),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l.projectManagement),
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) {
          if (repo.isLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          if (repo.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_open,
                        size: 64, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 24),
                  Text(l.noProjectsYet,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l.noProjectsYetSubtitle,
                      style:
                          const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: repo.projects.length,
            itemBuilder: (ctx, i) {
              final project = repo.projects[i];
              final taskCount =
                  repo.tasksForProject(project.id).length;
              final entryCount = repo.entries
                  .where((e) => e.projectName == project.name)
                  .length;
              final reminderCount =
                  repo.remindersForProject(project.id).length;

              return Dismissible(
                key: Key(project.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Project'),
                          content: Text(
                              'Delete "${project.name}"? This will also remove its reminders.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(l.cancel)),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text(l.delete,
                                    style: const TextStyle(
                                        color: Colors.red))),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) => repo.deleteProject(project.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder,
                          color: Color(0xFF6366F1)),
                    ),
                    title: Text(project.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Wrap(
                      spacing: 8,
                      children: [
                        _MiniChip(
                            '$taskCount tasks',
                            const Color(0xFF10B981)),
                        _MiniChip(
                            '$entryCount entries',
                            const Color(0xFF6366F1)),
                        if (reminderCount > 0)
                          _MiniChip(
                              '$reminderCount reminders',
                              const Color(0xFFF59E0B)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF6B7280)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProjectDetailScreen(project: project),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, l),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
