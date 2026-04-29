import 'package:cloud_firestore/cloud_firestore.dart';

/// Project model with Firestore serialization
class Project {
  final String id;
  final String name;

  Project({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Project.fromMap(Map<String, dynamic> map) =>
      Project(id: map['id'] as String, name: map['name'] as String);

  factory Project.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(id: doc.id, name: data['name'] as String);
  }
}
