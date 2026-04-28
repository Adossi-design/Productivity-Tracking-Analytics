import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProductivityRepository extends ChangeNotifier {
  static const String _entriesKey = 'time_entries';
  static const String _projectsKey = 'projects';
  static const String _tasksKey = 'tasks';

  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _groupByProject = false;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<TimeEntry> get entries => List<TimeEntry>.unmodifiable(_timeEntries);
  List<Project> get projects => List<Project>.unmodifiable(_projects);
  List<Task> get tasks => List<Task>.unmodifiable(_tasks);
  bool get groupByProject => _groupByProject;

  Map<String, List<TimeEntry>> get timeEntriesGroupedByProject {
    final Map<String, List<TimeEntry>> groupedEntries = {};
    for (final TimeEntry entry in _timeEntries) {
      if (groupedEntries[entry.projectName] == null) {
        groupedEntries[entry.projectName] = [];
      }
      groupedEntries[entry.projectName]!.add(entry);
    }
    return groupedEntries;
  }

  ProductivityRepository() {
    _loadPersistedRecords();
  }

  Future<void> _loadPersistedRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> entriesJson = prefs.getStringList(_entriesKey) ?? [];
    _timeEntries =
        entriesJson.map<TimeEntry>((e) => TimeEntry.fromJson(e)).toList();

    final List<String> projectsJson = prefs.getStringList(_projectsKey) ?? [];
    _projects = projectsJson.map<Project>((p) => Project.fromJson(p)).toList();

    final List<String> tasksJson = prefs.getStringList(_tasksKey) ?? [];
    _tasks = tasksJson.map<Task>((t) => Task.fromJson(t)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persistTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serialized =
        _timeEntries.map<String>((e) => e.toJson()).toList();
    await prefs.setStringList(_entriesKey, serialized);
  }

  Future<void> _persistProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serialized =
        _projects.map<String>((p) => p.toJson()).toList();
    await prefs.setStringList(_projectsKey, serialized);
  }

  Future<void> _persistTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serialized =
        _tasks.map<String>((t) => t.toJson()).toList();
    await prefs.setStringList(_tasksKey, serialized);
  }

  Future<void> addEntry({
    required String projectName,
    required String taskName,
    required String notes,
    required double totalTime,
    required DateTime date,
  }) async {
    final TimeEntry newEntry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: projectName,
      taskName: taskName,
      notes: notes,
      totalTime: totalTime,
      date: date,
    );
    _timeEntries.insert(0, newEntry);
    await _persistTimeEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    _timeEntries.removeWhere((TimeEntry e) => e.id == entryId);
    await _persistTimeEntries();
    notifyListeners();
  }

  Future<void> addProject(String projectName) async {
    final Project newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: projectName,
    );
    _projects.add(newProject);
    await _persistProjects();
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((Project p) => p.id == projectId);
    await _persistProjects();
    notifyListeners();
  }

  Future<void> addTask(String taskName, String projectId) async {
    final Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: taskName,
      projectId: projectId,
    );
    _tasks.add(newTask);
    await _persistTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((Task t) => t.id == taskId);
    await _persistTasks();
    notifyListeners();
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((Task t) => t.projectId == projectId).toList();
  }

  void toggleGroupByProject() {
    _groupByProject = !_groupByProject;
    notifyListeners();
  }

  Future<Map<String, String>> fetchRawStorageSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'time_entries': json.encode(prefs.getStringList(_entriesKey) ?? []),
      'projects': json.encode(prefs.getStringList(_projectsKey) ?? []),
      'tasks': json.encode(prefs.getStringList(_tasksKey) ?? []),
    };
  }
}
