import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/time_tracker_provider.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class UnifiedScheduleScreen extends StatefulWidget {
  const UnifiedScheduleScreen({super.key});

  @override
  State<UnifiedScheduleScreen> createState() => _UnifiedScheduleScreenState();
}

class _UnifiedScheduleScreenState extends State<UnifiedScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Project? _selectedProject;
  bool _creatingNewProject = false;
  final _newProjectController = TextEditingController();
  
  String? _selectedTaskId;
  bool _creatingNewTask = false;
  final _newTaskController = TextEditingController();
  
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool _setReminder = true;
  String _selectedSound = 'default';
  
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _newProjectController.dispose();
    _newTaskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _computedHours {
    if (_startTime == null || _endTime == null) return null;
    final start = _startDateTime!;
    final end = _endDateTime!;
    return end.difference(start).inMinutes / 60.0;
  }

  DateTime? get _startDateTime {
    if (_startTime == null) return null;
    return DateTime(_selectedStartDate.year, _selectedStartDate.month,
        _selectedStartDate.day, _startTime!.hour, _startTime!.minute);
  }

  DateTime? get _endDateTime {
    if (_endTime == null) return null;
    return DateTime(_selectedEndDate.year, _selectedEndDate.month,
        _selectedEndDate.day, _endTime!.hour, _endTime!.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final repo = context.read<ProductivityRepository>();
    
    if (!_creatingNewProject && _selectedProject == null) {
      _showError('Please select or create a project');
      return;
    }
    
    if (_creatingNewProject && _newProjectController.text.trim().isEmpty) {
      _showError('Please enter a project name');
      return;
    }
    
    if (!_creatingNewTask && _selectedTaskId == null) {
      _showError('Please select or create a task');
      return;
    }
    
    if (_creatingNewTask && _newTaskController.text.trim().isEmpty) {
      _showError('Please enter a task name');
      return;
    }
    
    if (_startTime == null || _endTime == null) {
      _showError('Please set both start and end time');
      return;
    }
    
    final hours = _computedHours!;
    if (hours <= 0) {
      _showError('End time must be after start time');
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      String projectId;
      String projectName;
      
      if (_creatingNewProject) {
        projectName = _newProjectController.text.trim();
        await repo.addProject(projectName);
        projectId = repo.projects.last.id;
      } else {
        projectId = _selectedProject!.id;
        projectName = _selectedProject!.name;
      }
      
      String taskName;
      
      if (_creatingNewTask) {
        taskName = _newTaskController.text.trim();
        await repo.addTask(taskName, projectId);
      } else {
        final task = repo.tasks.firstWhere((t) => t.id == _selectedTaskId);
        taskName = task.name;
      }
      
      await repo.addEntry(
        projectName: projectName,
        taskName: taskName,
        notes: _notesController.text.trim(),
        totalTime: hours,
        date: _selectedStartDate,
        startTime: _startDateTime,
        endTime: _endDateTime,
      );
      
      if (_setReminder && _startDateTime != null && !kIsWeb) {
        try {
          await repo.addReminder(
            projectId: projectId,
            projectName: projectName,
            scheduledTime: _startDateTime!,
            sound: _selectedSound,
          );
        } catch (e) {
          if (mounted) _showWarning('Session scheduled but reminder failed: $e');
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Scheduled: $taskName on $projectName'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Failed to schedule: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Web Platform: Notifications require browser tab to stay open'),
              backgroundColor: Color(0xFFF59E0B),
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('📅 Schedule Work Session'),
      ),
      body: Consumer<ProductivityRepository>(
        builder: (ctx, repo, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('1️⃣ Project', Icons.folder),
                  const SizedBox(height: 12),
                  _buildProjectSelector(repo),
                  const SizedBox(height: 24),

                  _buildSectionHeader('2️⃣ Task', Icons.task_alt),
                  const SizedBox(height: 12),
                  _buildTaskSelector(repo),
                  const SizedBox(height: 24),

                  _buildSectionHeader('3️⃣ Schedule', Icons.schedule),
                  const SizedBox(height: 12),
                  _buildDateTimePickers(isDark),
                  const SizedBox(height: 24),

                  if (!kIsWeb) ...[
                    _buildSectionHeader('4️⃣ Reminder', Icons.alarm),
                    const SizedBox(height: 12),
                    _buildReminderToggle(),
                    if (_setReminder) ...[
                      const SizedBox(height: 12),
                      _buildSoundSelector(),
                    ],
                    const SizedBox(height: 24),
                  ],

                  _buildSectionHeader('5️⃣ Notes (Optional)', Icons.notes),
                  const SizedBox(height: 12),
                  _buildNotesField(),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        _isSaving ? 'Scheduling...' : '✅ Schedule Session',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSelector(ProductivityRepository repo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Select Existing'),
                  icon: Icon(Icons.folder_outlined, size: 18),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Create New'),
                  icon: Icon(Icons.add_circle_outline, size: 18),
                ),
              ],
              selected: {_creatingNewProject},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _creatingNewProject = selection.first;
                  if (_creatingNewProject) {
                    _selectedProject = null;
                  } else {
                    _newProjectController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_creatingNewProject)
              Column(
                children: [
                  TextField(
                    controller: _newProjectController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter project name',
                      prefixIcon: const Icon(Icons.folder, color: Color(0xFF6366F1)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_newProjectController.text.trim().isEmpty) {
                          _showError('Please enter a project name');
                          return;
                        }
                        await repo.addProject(_newProjectController.text.trim());
                        setState(() {
                          _selectedProject = repo.projects.last;
                          _creatingNewProject = false;
                          _newProjectController.clear();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Project "${_selectedProject!.name}" created'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else if (repo.projects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No projects yet. Create one above!',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              )
            else
              DropdownButtonFormField<Project>(
                value: _selectedProject,
                hint: const Text('Select a project'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.folder_outlined, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                items: repo.projects
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProject = v),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSelector(ProductivityRepository repo) {
    final availableTasks = _selectedProject != null
        ? repo.tasksForProject(_selectedProject!.id)
        : [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Select Existing'),
                  icon: Icon(Icons.task_outlined, size: 18),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Create New'),
                  icon: Icon(Icons.add_circle_outline, size: 18),
                ),
              ],
              selected: {_creatingNewTask},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _creatingNewTask = selection.first;
                  if (_creatingNewTask) {
                    _selectedTaskId = null;
                  } else {
                    _newTaskController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_creatingNewTask)
              Column(
                children: [
                  TextField(
                    controller: _newTaskController,
                    decoration: InputDecoration(
                      hintText: 'Enter task name',
                      prefixIcon: const Icon(Icons.task_alt, color: Color(0xFF6366F1)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_selectedProject == null) {
                          _showError('Please select a project first');
                          return;
                        }
                        if (_newTaskController.text.trim().isEmpty) {
                          _showError('Please enter a task name');
                          return;
                        }
                        await repo.addTask(_newTaskController.text.trim(), _selectedProject!.id);
                        setState(() {
                          _selectedTaskId = repo.tasks.last.id;
                          _creatingNewTask = false;
                          _newTaskController.clear();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Task "${repo.tasks.last.name}" created'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else if (_selectedProject == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select a project first',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              )
            else if (availableTasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tasks for this project. Create one above!',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedTaskId,
                hint: const Text('Select a task'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.task_outlined, color: Color(0xFF6366F1)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
                items: availableTasks
                    .map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTaskId = v),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePickers(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedStartDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _selectedStartDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              DateFormat('MMM d, yyyy').format(_selectedStartDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeTile(
                label: 'Start',
                time: _startTime,
                icon: Icons.play_circle_outline,
                color: const Color(0xFF10B981),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _startTime = picked);
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedEndDate,
                    firstDate: _selectedStartDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _selectedEndDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(
                              DateFormat('MMM d, yyyy').format(_selectedEndDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeTile(
                label: 'End',
                time: _endTime,
                icon: Icons.stop_circle_outlined,
                color: const Color(0xFFEF4444),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _endTime = picked);
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
        if (_computedHours != null && _computedHours! > 0) ...[ 
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF6366F1), size: 18),
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
        ],
      ],
    );
  }

  Widget _buildTimeTile({
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final hasTime = time != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Icon(icon, color: hasTime ? color : Colors.grey, size: 18),
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
              hasTime ? time!.format(context) : 'Tap',
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

  Widget _buildReminderToggle() {
    return SwitchListTile(
      value: _setReminder,
      onChanged: (v) => setState(() => _setReminder = v),
      title: const Text('Set reminder notifications'),
      subtitle: const Text('Get notified 10 min before, 5 min before, and at start time'),
      secondary: const Icon(Icons.alarm, color: Color(0xFF6366F1)),
      activeColor: const Color(0xFF6366F1),
    );
  }

  Widget _buildSoundSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Sound',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...NotificationService.soundOptions.map((sound) {
              return RadioListTile<String>(
                value: sound.value,
                groupValue: _selectedSound,
                onChanged: (v) => setState(() => _selectedSound = v!),
                title: Text(sound.label),
                subtitle: Text(sound.description, style: const TextStyle(fontSize: 12)),
                secondary: IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  color: const Color(0xFF6366F1),
                  tooltip: 'Preview sound',
                  onPressed: () => NotificationService.instance.previewSound(sound.value),
                ),
                activeColor: const Color(0xFF6366F1),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Add any notes about this session...',
        prefixIcon: const Icon(Icons.notes, color: Color(0xFF6366F1), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
      ),
    );
  }
}
