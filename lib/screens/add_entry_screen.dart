import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({Key? key}) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectName;
  String? _selectedTaskName;
  final _notesController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _openDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitEntry() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }
    if (_selectedTaskName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a task')),
      );
      return;
    }

    Provider.of<ProductivityRepository>(context, listen: false).addEntry(
      projectName: _selectedProjectName!,
      taskName: _selectedTaskName!,
      notes: _notesController.text,
      totalTime: double.parse(_hoursController.text),
      date: _selectedDate,
    );
    Navigator.pop(context);
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductivityRepository>(
      builder: (ctx, repository, _) {
        final availableProjects = repository.projects;
        final tasksForSelectedProject = _selectedProjectName != null
            ? repository.tasks.where((t) {
                final matchingProject = repository.projects
                    .where((p) => p.name == _selectedProjectName)
                    .toList();
                return matchingProject.isNotEmpty &&
                    t.projectId == matchingProject.first.id;
              }).toList()
            : [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            title: const Text('Log Time Entry',
                style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Hours Worked'),
                  TextFormField(
                    controller: _hoursController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        _fieldDecoration('e.g. 2.5', Icons.access_time),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter hours worked';
                      if (double.tryParse(v) == null)
                        return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Project'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProjectName,
                        hint: Row(
                          children: const [
                            Icon(Icons.folder_outlined,
                                color: Color(0xFF6366F1), size: 20),
                            SizedBox(width: 12),
                            Text('Select a project',
                                style: TextStyle(color: Color(0xFF9CA3AF))),
                          ],
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF6B7280)),
                        items: availableProjects.isEmpty
                            ? [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  enabled: false,
                                  child: Text('No projects available',
                                      style:
                                          TextStyle(color: Color(0xFF9CA3AF))),
                                )
                              ]
                            : availableProjects
                                .map((p) => DropdownMenuItem<String>(
                                      value: p.name,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.folder_outlined,
                                              color: Color(0xFF6366F1),
                                              size: 20),
                                          const SizedBox(width: 12),
                                          Text(p.name),
                                        ],
                                      ),
                                    ))
                                .toList(),
                        onChanged: (val) => setState(() {
                          _selectedProjectName = val;
                          _selectedTaskName = null;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Task'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTaskName,
                        hint: Row(
                          children: const [
                            Icon(Icons.task_alt,
                                color: Color(0xFF6366F1), size: 20),
                            SizedBox(width: 12),
                            Text('Select a task',
                                style: TextStyle(color: Color(0xFF9CA3AF))),
                          ],
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF6B7280)),
                        items: tasksForSelectedProject.isEmpty
                            ? [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  enabled: false,
                                  child: Text('No tasks available',
                                      style:
                                          TextStyle(color: Color(0xFF9CA3AF))),
                                )
                              ]
                            : tasksForSelectedProject
                                .map((t) => DropdownMenuItem<String>(
                                      value: t.name,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.task_alt,
                                              color: Color(0xFF6366F1),
                                              size: 20),
                                          const SizedBox(width: 12),
                                          Text(t.name),
                                        ],
                                      ),
                                    ))
                                .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedTaskName = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Notes'),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration:
                        _fieldDecoration('Add notes...', Icons.notes),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Date'),
                  GestureDetector(
                    onTap: _openDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Time Entry',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}
