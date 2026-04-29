import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

// Central repository for productivity data with Firestore sync
class ProductivityRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _userId;

  ProductivityRepository({required String userId}) : _userId = userId {
    if (_userId.isNotEmpty) _loadAll();
  }

  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<Reminder> _reminders = [];
  bool _groupByProject = false;
  bool _isLoading = false;
  String? _error;
  String get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get groupByProject => _groupByProject;
  List<TimeEntry> get entries => List.unmodifiable(_timeEntries);
  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void setUser(String userId) {
    _userId = userId;
    _loadAll();
  }

  void clearUser() {
    _userId = '';
    _timeEntries = [];
    _projects = [];
    _tasks = [];
    _reminders = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  CollectionReference get _entriesRef =>
      _db.collection('users').doc(_userId).collection('time_entries');
  CollectionReference get _projectsRef =>
      _db.collection('users').doc(_userId).collection('projects');
  CollectionReference get _tasksRef =>
      _db.collection('users').doc(_userId).collection('tasks');
  CollectionReference get _remindersRef =>
      _db.collection('users').doc(_userId).collection('reminders');

  Future<void> _loadAll() async {
    if (_userId.isEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final results = await Future.wait([
        _entriesRef.orderBy('date', descending: true).get(),
        _projectsRef.get(),
        _tasksRef.get(),
        _remindersRef.get(),
      ]);
      
      _timeEntries = results[0].docs.map((d) => TimeEntry.fromDoc(d)).toList();
      _projects = results[1].docs.map((d) => Project.fromDoc(d)).toList();
      _tasks = results[2].docs.map((d) => Task.fromDoc(d)).toList();
      _reminders = results[3].docs.map((d) => Reminder.fromDoc(d)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() => _loadAll();

  Future<void> addEntry({
    required String projectName,
    required String taskName,
    required String notes,
    required double totalTime,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final data = <String, dynamic>{
      'projectName': projectName,
      'taskName': taskName,
      'notes': notes,
      'totalTime': totalTime,
      'date': Timestamp.fromDate(date),
    };
    if (startTime != null) data['startTime'] = Timestamp.fromDate(startTime);
    if (endTime != null) data['endTime'] = Timestamp.fromDate(endTime);

    final ref = await _entriesRef.add(data);

    if (startTime != null && endTime != null) {
      await NotificationService.instance.scheduleSession(
        id: ref.id.hashCode.abs() % 100000,
        projectName: projectName,
        taskName: taskName,
        startTime: startTime,
        endTime: endTime,
      );
    }

    _timeEntries.insert(
      0,
      TimeEntry(
        id: ref.id,
        projectName: projectName,
        taskName: taskName,
        notes: notes,
        totalTime: totalTime,
        date: date,
        startTime: startTime,
        endTime: endTime,
      ),
    );
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    await _entriesRef.doc(entryId).delete();
    _timeEntries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  Future<void> addProject(String name) async {
    final ref = await _projectsRef.add({'name': name});
    _projects.add(Project(id: ref.id, name: name));
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    final projectReminders =
        _reminders.where((r) => r.projectId == projectId).toList();
    for (final r in projectReminders) {
      await cancelReminder(r.id);
    }
    
    await _projectsRef.doc(projectId).delete();
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  Future<void> addTask(String name, String projectId) async {
    final ref = await _tasksRef.add({'name': name, 'projectId': projectId});
    _tasks.add(Task(id: ref.id, name: name, projectId: projectId));
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  List<Task> tasksForProject(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();

  Future<void> addReminder({
    required String projectId,
    required String projectName,
    required DateTime scheduledTime,
    required String sound,
  }) async {
    final ref = await _remindersRef.add({
      'projectId': projectId,
      'projectName': projectName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'sound': sound,
    });
    
    final reminder = Reminder(
      id: ref.id,
      projectId: projectId,
      projectName: projectName,
      scheduledTime: scheduledTime,
      sound: sound,
    );
    _reminders.add(reminder);

    await NotificationService.instance.scheduleReminder(
      id: ref.id.hashCode.abs() % 100000,
      projectName: projectName,
      scheduledTime: scheduledTime,
      sound: sound,
    );

    notifyListeners();
  }

  Future<void> cancelReminder(String reminderId) async {
    final reminder = _reminders.where((r) => r.id == reminderId).firstOrNull;
    if (reminder != null) {
      await NotificationService.instance
          .cancelReminder(reminder.id.hashCode.abs() % 100000);
    }
    
    await _remindersRef.doc(reminderId).delete();
    _reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();
  }

  List<Reminder> remindersForProject(String projectId) =>
      _reminders.where((r) => r.projectId == projectId).toList();

  Map<String, List<TimeEntry>> get timeEntriesGroupedByProject {
    final map = <String, List<TimeEntry>>{};
    for (final e in _timeEntries) {
      map.putIfAbsent(e.projectName, () => []).add(e);
    }
    return map;
  }

  void toggleGroupByProject() {
    _groupByProject = !_groupByProject;
    notifyListeners();
  }
}
