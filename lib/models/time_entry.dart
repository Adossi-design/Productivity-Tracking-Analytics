import 'package:cloud_firestore/cloud_firestore.dart';

/// TimeEntry model with denormalized project and task names
class TimeEntry {
  final String id;
  final String projectName;
  final String taskName;
  final String notes;
  final double totalTime;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;

  TimeEntry({
    required this.id,
    required this.projectName,
    required this.taskName,
    required this.notes,
    required this.totalTime,
    required this.date,
    this.startTime,
    this.endTime,
  });

  /// Parses a Firestore document defensively: missing or wrongly-typed fields
  /// fall back to safe defaults rather than throwing, so a single malformed
  /// document can't break loading of the whole collection.
  factory TimeEntry.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return TimeEntry(
      id: doc.id,
      projectName: (data['projectName'] as String?) ?? '',
      taskName: (data['taskName'] as String?) ?? '',
      notes: (data['notes'] as String?) ?? '',
      totalTime: (data['totalTime'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
    );
  }
}
