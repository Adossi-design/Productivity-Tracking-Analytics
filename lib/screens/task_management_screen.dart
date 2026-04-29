import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';
import '../l10n/app_localizations.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  void _showAddDialog(
    BuildContext context,
    AppLocalizations l,
    ProductivityRepository repo, {
    String? preselectedProjectId,
  }) {
    final ctrl = TextEditingController();
    String? selectedProjectId = preselectedProjectId;

    if (repo.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Create a project first before adding tasks.'),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l.addTask,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l.taskName,
                  prefixIcon: const Icon(Icons.task_alt,
                      color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedProjectId,
                hint: Text(l.selectParentProject),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.folder_outlined,
                      color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                items: repo.projects
                    .map((p) => DropdownMenuItem(
                        value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedProjectId = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel)),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty &&
                    selectedProjectId != null) {
                  repo.addTask(ctrl.text.trim(), selectedProjectId!);
                  Navigator.pop(ctx);
                }
              },
              child: Text(l.add),
            ),
          ],
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(l.taskManagement)),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) {
          if (repo.isLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          if (repo.projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder_off_outlined,
                          size: 56, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(height: 20),
                    const Text('No projects yet',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a project first, then add tasks to it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            );
          }

          final projectsWithTasks = repo.projects
              .map((p) => (
                    project: p,
                    tasks: repo.tasksForProject(p.id),
                  ))
              .toList();

          final hasAnyTask =
              projectsWithTasks.any((g) => g.tasks.isNotEmpty);

          if (!hasAnyTask) {
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
                    child: const Icon(Icons.task_alt,
                        size: 64, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 24),
                  Text(l.noTasksYet,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l.noTasksYetSubtitle,
                      style:
                          const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projectsWithTasks.length,
            itemBuilder: (ctx, i) {
              final group = projectsWithTasks[i];
              if (group.tasks.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8, top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(group.project.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text('${group.tasks.length} tasks',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showAddDialog(
                              context, l, repo,
                              preselectedProjectId: group.project.id),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  ...group.tasks.map((task) => Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => repo.deleteTask(task.id),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.task_alt,
                                  color: Color(0xFF10B981), size: 18),
                            ),
                            title: Text(task.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Color(0xFFEF4444), size: 20),
                              onPressed: () => repo.deleteTask(task.id),
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) => FloatingActionButton(
          onPressed: () => _showAddDialog(context, l, repo),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
