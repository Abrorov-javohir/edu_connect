// models/task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String classId;
  final String teacherId;
  final DateTime createdAt;
  final bool isCompleted;
  final String subject;
  final String className;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.classId,
    required this.teacherId,
    required this.createdAt,
    required this.isCompleted,
    required this.subject,
    required this.className,
  });

  factory TaskModel.fromFirestore(
    DocumentSnapshot taskDoc,
    Map<String, dynamic> taskData,
    bool isCompleted,
    String subject,
    String className,
  ) {
    return TaskModel(
      id: taskDoc.id,
      title: taskData['title'] ?? 'No Title',
      description: taskData['description'] ?? 'No description',
      deadline: (taskData['deadline'] as Timestamp).toDate(),
      classId: taskData['classId'] ?? '',
      teacherId: taskData['teacherId'] ?? '',
      createdAt: (taskData['createdAt'] as Timestamp).toDate(),
      isCompleted: isCompleted,
      subject: subject,
      className: className,
    );
  }
}