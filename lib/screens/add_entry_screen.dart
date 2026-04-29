import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/time_tracker_provider.dart';
import '../l10n/app_localizations.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectName;
  String? _selectedTaskName;
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double? get _computedHours {
    if (_startTime == null || _endTime == null) return null;
    final start = _startTime!.hour * 60 + _startTime!.minute;
    var end = _endTime!.hour * 60 + _endTime!.minute;
    if (end <= start) end += 24 * 60;
    return (end - start) / 60.0;
  }

  DateTime? get _startDateTime {
    if (_startTime == null) return null;
    return DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _startTime!.hour, _startTime!.minute);
  }

  DateTime? get _endDateTime {
    if (_endTime == null) return null;
    final base = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _endTime!.hour, _endTime!.minute);
    if (_startTime != null &&
        (_endTime!.hour * 60 + _endTime!.minute) <=
            (_startTime!.hour * 60 + _startTime!.minute)) {
      return base.add(const Duration(days: 1));
    }
    return base;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFF6366F1)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      helpText: 'Select Start Time',
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        if (_endTime != null) {
          final s = picked.hour * 60 + picked.minute;
          final e = _endTime!.hour * 60 + _endTime!.minute;
          if (e <= s) _endTime = null;
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ??
          (_startTime != null
              ? TimeOfDay(
                  hour: (_startTime!.hour + 1) % 24,
                  minute: _startTime!.minute)
              : TimeOfDay.now()),
      helpText: 'Select End Time',
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectName == null) {
      _showSnack(l.pleaseSelectProject);
      return;
    }
    if (_selectedTaskName == null) {
      _showSnack(l.pleaseSelectTask);
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showSnack('Please set both start and end time');
      return;
    }
    final hours = _computedHours!;
    if (hours <= 0) {
      _showSnack('End time must be after start time');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<ProductivityRepository>().addEntry(
            projectName: _selectedProjectName!,
            taskName: _selectedTaskName!,
            notes: _notesController.text,
            totalTime: hours,
            date: _selectedDate,
            startTime: _startDateTime,
            endTime: _endDateTime,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProductivityRepository>(
      builder: (ctx, repo, _) {
        final selectedProject = _selectedProjectName != null
            ? repo.projects
                .where((p) => p.name == _selectedProjectName)
                .firstOrNull
            : null;
        final tasksForProject = selectedProject != null
            ? repo.tasks
                .where((t) => t.projectId == selectedProject.id)
                .toList()
            : <Task>[];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(title: Text(l.logTimeEntry)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l.date),
                  _TapField(
                    onTap: _pickDate,
                    icon: Icons.calendar_today,
                    text: DateFormat('EEEE, MMMM d, yyyy')
                        .format(_selectedDate),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Work Session Time'),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: 'Start Time',
                          time: _startTime,
                          icon: Icons.play_circle_outline,
                          color: const Color(0xFF10B981),
                          onTap: _pickStartTime,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeTile(
                          label: 'End Time',
                          time: _endTime,
                          icon: Icons.stop_circle_outlined,
                          color: const Color(0xFFEF4444),
                          onTap: _pickEndTime,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  if (_computedHours != null && _computedHours! > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Color(0xFF6366F1), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${_computedHours!.toStringAsFixed(1)} hours',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_startTime != null || _endTime != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Set both start and end time to calculate duration',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _SectionLabel(l.project),
                  _DropdownField(
                    value: _selectedProjectName,
                    hint: l.selectProject,
                    icon: Icons.folder_outlined,
                    items: repo.projects.isEmpty
                        ? null
                        : repo.projects
                            .map((p) => DropdownMenuItem<String>(
                                  value: p.name,
                                  child: Text(p.name),
                                ))
                            .toList(),
                    emptyText: l.noProjectsAvailable,
                    onChanged: (val) => setState(() {
                      _selectedProjectName = val;
                      _selectedTaskName = null;
                    }),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(l.task),
                  _DropdownField(
                    value: _selectedTaskName,
                    hint: l.selectTask,
                    icon: Icons.task_alt,
                    items: tasksForProject.isEmpty
                        ? null
                        : tasksForProject
                            .map((t) => DropdownMenuItem<String>(
                                  value: t.name,
                                  child: Text(t.name),
                                ))
                            .toList(),
                    emptyText: l.noTasksAvailable,
                    onChanged: (val) =>
                        setState(() => _selectedTaskName = val),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(l.notes),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l.addNotes,
                      prefixIcon: const Icon(Icons.notes,
                          color: Color(0xFF6366F1), size: 20),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF6366F1), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(l.saveTimeEntry,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Time tile ──────────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasTime
              ? color.withValues(alpha: 0.08)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasTime ? color : Colors.grey.shade300,
            width: hasTime ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: hasTime ? color : Colors.grey, size: 18),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: hasTime ? color : Colors.grey,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasTime ? time!.format(context) : 'Tap to set',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: hasTime ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _TapField extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String text;
  const _TapField(
      {required this.onTap, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<String>>? items;
  final String emptyText;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 12),
              Text(hint,
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF))),
            ],
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280)),
          items: items ??
              [
                DropdownMenuItem<String>(
                  value: null,
                  enabled: false,
                  child: Text(emptyText,
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF))),
                )
              ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF374151))),
    );
  }
}
