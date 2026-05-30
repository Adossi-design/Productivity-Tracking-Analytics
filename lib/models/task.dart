import 'package:cloud_firestore/cloud_firestore.dart';

/// Task model with parent project reference
class Task {
  final String id;
  final String name;
  final String projectId;

  Task({required this.id, required this.name, required this.projectId});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'projectId': projectId,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    name: map['name'] as String,
    projectId: map['projectId'] as String,
  );

  factory Task.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return Task(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Untitled',
      projectId: (data['projectId'] as String?) ?? '',
    );
  }
}
