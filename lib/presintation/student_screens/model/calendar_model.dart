// models/calendar_event.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String type; // 'event' or 'announcement'
  final String subject;
  final String teacherId;
  final String teacherName;
  final String color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.color,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map, String id) {
    return CalendarEvent(
      id: id,
      title: map['title'] ?? 'Untitled Event',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? 'All Day',
      type: map['type'] ?? 'event',
      subject: map['subject'] ?? 'General',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? 'Teacher',
      color: _getColorForSubject(map['subject'] ?? 'General'),
    );
  }

  static String _getColorForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return '#FF9800';
      case 'science':
        return '#4CAF50';
      case 'english':
        return '#2196F3';
      case 'history':
        return '#795548';
      case 'art':
        return '#E91E63';
      case 'music':
        return '#9C27B0';
      case 'physics':
        return '#00BCD4';
      case 'chemistry':
        return '#F44336';
      case 'biology':
        return '#009688';
      default:
        return '#607D8B';
    }
  }
}