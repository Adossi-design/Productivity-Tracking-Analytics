import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';
import '../models/time_entry.dart';
import 'add_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';
import 'local_storage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildNavigationDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Project & Task Time Tracking System',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Consumer<ProductivityRepository>(
            builder: (ctx, repository, _) => IconButton(
              icon: Icon(
                repository.groupByProject ? Icons.view_list : Icons.folder_open,
              ),
              tooltip:
                  repository.groupByProject ? 'List View' : 'Group by Project',
              onPressed: () => repository.toggleGroupByProject(),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Entries'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TimeEntryListTab(),
          _ProjectAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEntryScreen()),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log Time Entry'),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.access_time, color: Colors.white, size: 30),
                ),
                SizedBox(height: 12),
                Text(
                  'Project & Task Time Tracking System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track productivity across projects and tasks',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF6366F1)),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFF6366F1)),
            title: const Text('Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProjectManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task, color: Color(0xFF6366F1)),
            title: const Text('Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskManagementScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage, color: Color(0xFF6366F1)),
            title: const Text('Local Storage'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocalStorageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimeEntryListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductivityRepository>(
      builder: (ctx, repository, _) {
        if (repository.entries.isEmpty) {
          return const _EmptyStateView(
            icon: Icons.access_time,
            message: 'No time entries recorded yet',
            subtitle: 'Tap the button below to log your first time entry',
          );
        }
        if (repository.groupByProject) {
          return _ProjectGroupedEntryListView(
              grouped: repository.timeEntriesGroupedByProject);
        }
        return _TimeEntryListView(entries: repository.entries.toList());
      },
    );
  }
}

class _ProjectAnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductivityRepository>(
      builder: (ctx, repository, _) {
        final groupedEntries = repository.timeEntriesGroupedByProject;
        if (groupedEntries.isEmpty) {
          return const _EmptyStateView(
            icon: Icons.folder_open,
            message: 'No project analytics available',
            subtitle: 'Log time entries against projects to see analytics here',
          );
        }
        return _ProjectGroupedEntryListView(grouped: groupedEntries);
      },
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _EmptyStateView({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, size: 64, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TimeEntryListView extends StatelessWidget {
  final List<TimeEntry> entries;
  const _TimeEntryListView({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (ctx, i) => _TimeEntryCard(entry: entries[i]),
    );
  }
}

class _ProjectGroupedEntryListView extends StatelessWidget {
  final Map<String, List<TimeEntry>> grouped;
  const _ProjectGroupedEntryListView({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final projectNames = grouped.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projectNames.length,
      itemBuilder: (ctx, i) {
        final projectName = projectNames[i];
        final projectEntries = grouped[projectName]!;
        final totalHours =
            projectEntries.fold(0.0, (sum, e) => sum + e.totalTime);
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
                      projectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${totalHours.toStringAsFixed(1)}h',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ...projectEntries.map((e) => _TimeEntryCard(entry: e)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _TimeEntryCard extends StatelessWidget {
  final TimeEntry entry;
  const _TimeEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final repository =
        Provider.of<ProductivityRepository>(context, listen: false);
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
                title: const Text('Delete Time Entry'),
                content: const Text(
                    'Are you sure you want to delete this time entry?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => repository.deleteEntry(entry.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.folder_outlined,
                            size: 13, color: Color(0xFF6366F1)),
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
                    if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.notes,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
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
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Time Entry'),
                          content:
                              const Text('Delete this time entry permanently?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        repository.deleteEntry(entry.id);
                      }
                    },
                    child: const Icon(Icons.delete_outline,
                        color: Color(0xFFEF4444), size: 20),
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
