import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({Key? key}) : super(key: key);

  void _showAddTaskDialog(
      BuildContext context, ProductivityRepository repository) {
    final taskNameController = TextEditingController();
    String? selectedProjectId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Task',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Task name',
                  prefixIcon:
                      const Icon(Icons.task_alt, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedProjectId,
                hint: const Text('Select parent project'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.folder_outlined,
                      color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                items: repository.projects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedProjectId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (taskNameController.text.trim().isNotEmpty &&
                    selectedProjectId != null) {
                  repository.addTask(
                      taskNameController.text.trim(), selectedProjectId!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: const Text('Task Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repository, _) {
          final tasks = repository.tasks;
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.task_alt,
                        size: 64, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 24),
                  const Text('No tasks yet',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first task',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (ctx, i) {
              final task = tasks[i];
              final parentProject = repository.projects
                  .where((p) => p.id == task.projectId)
                  .toList();
              final parentProjectName =
                  parentProject.isNotEmpty ? parentProject.first.name : 'Unknown Project';
              return Dismissible(
                key: Key(task.id),
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
                onDismissed: (_) => repository.deleteTask(task.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.task_alt, color: Color(0xFF10B981)),
                    ),
                    title: Text(task.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.folder_outlined,
                            size: 13, color: Color(0xFF6366F1)),
                        const SizedBox(width: 4),
                        Text(parentProjectName,
                            style: const TextStyle(
                                color: Color(0xFF6366F1), fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFEF4444)),
                      onPressed: () => repository.deleteTask(task.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<ProductivityRepository>(
        builder: (ctx, repository, _) => FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, repository),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
