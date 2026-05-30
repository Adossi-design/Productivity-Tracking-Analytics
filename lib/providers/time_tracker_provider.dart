import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

// Central repository for productivity data with real-time Firestore sync.
//
// Each collection is backed by a snapshots() listener, so changes made on any
// device (or by latency-compensated local writes) propagate live without a
// manual reload. Firestore's offline cache means listeners also fire instantly
// while offline and reconcile on reconnect.
class ProductivityRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _userId;

  ProductivityRepository({required String userId}) : _userId = userId {
    if (_userId.isNotEmpty) _subscribe();
  }

  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<Reminder> _reminders = [];
  bool _groupByProject = false;
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _entriesSub;
  StreamSubscription? _projectsSub;
  StreamSubscription? _tasksSub;
  StreamSubscription? _remindersSub;

  String get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get groupByProject => _groupByProject;
  List<TimeEntry> get entries => List.unmodifiable(_timeEntries);
  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void setUser(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscribe();
  }

  void clearUser() {
    if (_userId.isEmpty) return;
    _userId = '';
    _cancelSubscriptions();
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

  /// Attaches real-time listeners to all of the user's collections.
  void _subscribe() {
    _cancelSubscriptions();
    if (_userId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    void onError(Object e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }

    _entriesSub = _entriesRef
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
          _timeEntries = _parseDocs(snap.docs, TimeEntry.fromDoc);
          _isLoading = false;
          _error = null;
          notifyListeners();
        }, onError: onError);

    _projectsSub = _projectsRef.snapshots().listen((snap) {
      _projects = _parseDocs(snap.docs, Project.fromDoc);
      notifyListeners();
    }, onError: onError);

    _tasksSub = _tasksRef.snapshots().listen((snap) {
      _tasks = _parseDocs(snap.docs, Task.fromDoc);
      notifyListeners();
    }, onError: onError);

    _remindersSub = _remindersRef.snapshots().listen((snap) {
      _reminders = _parseDocs(snap.docs, Reminder.fromDoc);
      notifyListeners();
    }, onError: onError);
  }

  void _cancelSubscriptions() {
    _entriesSub?.cancel();
    _projectsSub?.cancel();
    _tasksSub?.cancel();
    _remindersSub?.cancel();
    _entriesSub = _projectsSub = _tasksSub = _remindersSub = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  /// Maps Firestore docs to models, skipping any individual document that
  /// fails to parse so one corrupt record can't blank out the whole list.
  List<T> _parseDocs<T>(
    List<QueryDocumentSnapshot> docs,
    T Function(DocumentSnapshot) fromDoc,
  ) {
    final result = <T>[];
    for (final doc in docs) {
      try {
        result.add(fromDoc(doc));
      } catch (e) {
        debugPrint(
          '[ProductivityRepository] Skipped malformed doc ${doc.id}: $e',
        );
      }
    }
    return result;
  }

  /// Re-attaches the listeners (used by the error-state retry button).
  Future<void> reload() async => _subscribe();

  /// Persists a time entry. When [scheduleNotifications] is true and the entry
  /// has a future start/end, schedules the session's reminder notifications.
  /// Notification scheduling is opt-in so callers stay the single source of
  /// truth — the repository never schedules behind the caller's back.
  Future<TimeEntry> addEntry({
    required String projectName,
    required String taskName,
    required String notes,
    required double totalTime,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
    bool scheduleNotifications = false,
    String sound = 'default',
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

    if (scheduleNotifications && startTime != null && endTime != null) {
      await NotificationService.instance.scheduleSession(
        id: ref.id.hashCode.abs() % 100000,
        projectName: projectName,
        taskName: taskName,
        startTime: startTime,
        endTime: endTime,
        sound: sound,
      );
    }

    // No optimistic mutation needed: the snapshots() listener (latency-
    // compensated by Firestore) updates the cache and notifies listeners.
    return TimeEntry(
      id: ref.id,
      projectName: projectName,
      taskName: taskName,
      notes: notes,
      totalTime: totalTime,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<void> deleteEntry(String entryId) async {
    await _entriesRef.doc(entryId).delete();
  }

  Future<Project> addProject(String name) async {
    final ref = await _projectsRef.add({'name': name});
    return Project(id: ref.id, name: name);
  }

  Future<void> deleteProject(String projectId) async {
    final projectReminders = _reminders
        .where((r) => r.projectId == projectId)
        .toList();
    for (final r in projectReminders) {
      await cancelReminder(r.id);
    }
    await _projectsRef.doc(projectId).delete();
  }

  Future<Task> addTask(String name, String projectId) async {
    final ref = await _tasksRef.add({'name': name, 'projectId': projectId});
    return Task(id: ref.id, name: name, projectId: projectId);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
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

    await NotificationService.instance.scheduleReminder(
      id: ref.id.hashCode.abs() % 100000,
      projectName: projectName,
      scheduledTime: scheduledTime,
      sound: sound,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    final reminder = _reminders.where((r) => r.id == reminderId).firstOrNull;
    if (reminder != null) {
      await NotificationService.instance.cancelReminder(
        reminder.id.hashCode.abs() % 100000,
      );
    }
    await _remindersRef.doc(reminderId).delete();
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
