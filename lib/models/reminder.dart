import 'package:cloud_firestore/cloud_firestore.dart';

/// Reminder model for scheduled work session notifications
class Reminder {
  final String id;
  final String projectId;
  final String projectName;
  final DateTime scheduledTime;
  final String sound;

  Reminder({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.scheduledTime,
    required this.sound,
  });

  Map<String, dynamic> toMap() => {
        'projectId': projectId,
        'projectName': projectName,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'sound': sound,
      };

  factory Reminder.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      projectId: d['projectId'] as String,
      projectName: d['projectName'] as String,
      scheduledTime: (d['scheduledTime'] as Timestamp).toDate(),
      sound: d['sound'] as String? ?? 'default',
    );
  }
}
