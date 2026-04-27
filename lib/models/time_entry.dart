import 'dart:convert';

class TimeEntry {
  final String id;
  final String projectName;
  final String taskName;
  final String notes;
  final double totalTime;
  final DateTime date;

  TimeEntry({
    required this.id,
    required this.projectName,
    required this.taskName,
    required this.notes,
    required this.totalTime,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'taskName': taskName,
      'notes': notes,
      'totalTime': totalTime,
      'date': date.toIso8601String(),
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'].toString(),
      projectName: map['projectName'].toString(),
      taskName: map['taskName'].toString(),
      notes: map['notes'].toString(),
      totalTime: (map['totalTime'] as num).toDouble(),
      date: DateTime.parse(map['date'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeEntry.fromJson(String source) =>
      TimeEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
