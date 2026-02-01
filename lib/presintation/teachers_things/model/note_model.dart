// lib/models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';

class Note {
  final String id;
  final String teacherId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category; // NEW: lesson, homework, reminder, meeting, other
  final String color;

  Note({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.color,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      title: data['title'] ?? 'Untitled Note',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      category: data['category'] ?? 'other',
      color: data['color'] ?? _getCategoryColor('other'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'category': category,
      'color': color,
    };
  }

  // Category-based colors
  static String _getCategoryColor(String category) {
    switch (category) {
      case 'lesson': return '#4A6CF7'; // Blue
      case 'homework': return '#10B981'; // Green
      case 'reminder': return '#F59E0B'; // Amber
      case 'meeting': return '#8B5CF6'; // Purple
      case 'other': return '#EF4444'; // Red
      default: return '#06B6D4'; // Cyan
    }
  }

  // Generate color based on category
  static String generateColor(String category) {
    return _getCategoryColor(category);
  }

  // Get category icon
  IconData getCategoryIcon() {
    switch (category) {
      case 'lesson': return Icons.book;
      case 'homework': return Icons.assignment;
      case 'reminder': return Icons.notifications;
      case 'meeting': return Icons.groups;
      case 'other': return Icons.note_alt;
      default: return Icons.note;
    }
  }

  // Get localized category name
  String getLocalizedCategory(LanguageProvider languageProvider) {
    switch (category) {
      case 'lesson': return languageProvider.translate('lesson');
      case 'homework': return languageProvider.translate('homework');
      case 'reminder': return languageProvider.translate('reminder');
      case 'meeting': return languageProvider.translate('meeting');
      case 'other': return languageProvider.translate('other');
      default: return 'Other';
    }
  }
}