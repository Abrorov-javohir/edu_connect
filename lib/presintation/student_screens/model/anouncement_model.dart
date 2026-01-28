// model/anouncement_model.dart
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String teacherName;
  final String className;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.teacherName,
    required this.className,
  });
}