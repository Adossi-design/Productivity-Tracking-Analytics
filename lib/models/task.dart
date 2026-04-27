import 'dart:convert';

class Task {
  final String id;
  final String name;
  final String projectId;

  Task({
    required this.id,
    required this.name,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'projectId': projectId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      projectId: map['projectId'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
