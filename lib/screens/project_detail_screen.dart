import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/reminder.dart';
import '../providers/time_tracker_provider.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.alarm_add_rounded),
              tooltip: 'Set Reminder',
              onPressed: () => _showReminderDialog(context, l),
            ),
        ],
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) {
          final tasks = repo.tasksForProject(project.id);
          final reminders = repo.remindersForProject(project.id);
          final entryCount = repo.entries
              .where((e) => e.projectName == project.name)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Stats row ────────────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                    icon: Icons.task_alt,
                    label: '${tasks.length} tasks',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.access_time,
                    label: '$entryCount entries',
                    color: const Color(0xFF6366F1),
                  ),
                  if (reminders.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.alarm,
                      label: '${reminders.length} reminders',
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // ── Tasks section ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddTaskDialog(context, l, repo),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l.addTask),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tasks.isEmpty)
                const _EmptySection(
                  icon: Icons.task_alt,
                  message: 'No tasks yet',
                  subtitle: 'Tap "Add Task" to create one',
                )
              else
                ...tasks.map(
                  (task) => Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => repo.deleteTask(task.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.task_alt,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                        ),
                        title: Text(
                          task.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          onPressed: () => repo.deleteTask(task.id),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Reminders section ─────────────────────────────────────
              if (!kIsWeb) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showReminderDialog(context, l),
                      icon: const Icon(Icons.alarm_add, size: 18),
                      label: const Text('Add Reminder'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (reminders.isEmpty)
                  const _EmptySection(
                    icon: Icons.alarm_off,
                    message: 'No reminders set',
                    subtitle: 'Tap "Add Reminder" to schedule one',
                  )
                else
                  ...reminders.map(
                    (r) => _ReminderCard(
                      reminder: r,
                      onDelete: () => repo.cancelReminder(r.id),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Add task dialog ────────────────────────────────────────────────────────

  void _showAddTaskDialog(
    BuildContext context,
    AppLocalizations l,
    ProductivityRepository repo,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l.addTask,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.taskName,
            prefixIcon: const Icon(Icons.task_alt, color: Color(0xFF6366F1)),
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
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                repo.addTask(ctrl.text.trim(), project.id);
                Navigator.pop(context);
              }
            },
            child: Text(l.add),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  // ── Add reminder dialog ────────────────────────────────────────────────────

  void _showReminderDialog(BuildContext context, AppLocalizations l) {
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    String selectedSound = 'default';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text(
            'Set Reminder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & time picker
              const Text(
                'Date & Time',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF6366F1),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date == null) return;
                  if (!ctx.mounted) return;
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                  );
                  if (time == null) return;
                  setState(() {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6366F1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF6366F1),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy – HH:mm').format(selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sound picker
              const Text(
                'Alert Sound',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedSound,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.music_note,
                    color: Color(0xFF6366F1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                items: NotificationService.soundOptions
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.value,
                        child: Text(s.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => selectedSound = v ?? 'default'),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFF6366F1),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You\'ll be notified 10 min before, 5 min before, and at the exact time.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final repo = context.read<ProductivityRepository>();
                await repo.addReminder(
                  projectId: project.id,
                  projectName: project.name,
                  scheduledTime: selectedDate,
                  sound: selectedSound,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reminder set for ${DateFormat('MMM d – HH:mm').format(selectedDate)}',
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.alarm_add, size: 18),
              label: const Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder card ──────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  const _ReminderCard({required this.reminder, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isPast = reminder.scheduledTime.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isPast ? Colors.grey : const Color(0xFFF59E0B)).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPast ? Icons.alarm_off : Icons.alarm,
            color: isPast ? Colors.grey : const Color(0xFFF59E0B),
            size: 18,
          ),
        ),
        title: Text(
          DateFormat('MMM d, yyyy – HH:mm').format(reminder.scheduledTime),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          isPast ? 'Passed · ${reminder.sound}' : reminder.sound,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  const _EmptySection({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
