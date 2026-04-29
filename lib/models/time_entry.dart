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

  factory TimeEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeEntry(
      id: doc.id,
      projectName: data['projectName'] as String,
      taskName: data['taskName'] as String,
      notes: data['notes'] as String,
      totalTime: (data['totalTime'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
    );
  }
}
