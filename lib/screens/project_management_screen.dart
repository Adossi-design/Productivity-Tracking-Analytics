import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({Key? key}) : super(key: key);

  void _showAddProjectDialog(BuildContext context) {
    final projectNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Project',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: projectNameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Project name',
            prefixIcon: const Icon(Icons.folder, color: Color(0xFF6366F1)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (projectNameController.text.trim().isNotEmpty) {
                Provider.of<ProductivityRepository>(context, listen: false)
                    .addProject(projectNameController.text.trim());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: const Text('Project Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repository, _) {
          final projects = repository.projects;
          if (projects.isEmpty) {
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
                    child: const Icon(Icons.folder_open,
                        size: 64, color: Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 24),
                  const Text('No projects yet',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first project',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (ctx, i) {
              final project = projects[i];
              final linkedEntryCount = repository.entries
                  .where((e) => e.projectName == project.name)
                  .length;
              return Dismissible(
                key: Key(project.id),
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
                onDismissed: (_) => repository.deleteProject(project.id),
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
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder, color: Color(0xFF6366F1)),
                    ),
                    title: Text(project.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$linkedEntryCount time entries',
                        style: const TextStyle(color: Color(0xFF6B7280))),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFEF4444)),
                      onPressed: () => repository.deleteProject(project.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
