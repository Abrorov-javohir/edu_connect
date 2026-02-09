// data/anouncement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_connect/presintation/student_screens/model/anouncement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Announcement>> getStudentAnnouncements() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      // Get classes this student is enrolled in
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) return [];

      final List<String> classIds = [];
      for (final doc in classStudentsSnapshot.docs) {
        final classId = doc["classId"] as String?;
        if (classId != null) {
          classIds.add(classId);
        }
      }

      if (classIds.isEmpty) return [];

      // Load announcements for these classes
      final announcementsSnapshot = await _firestore
          .collection("announcements")
          .where("classId", whereIn: classIds)
          .orderBy("createdAt", descending: true)
          .limit(5)
          .get();

      final List<Announcement> announcements = [];

      for (final doc in announcementsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // ✅ CRITICAL FIX: Handle missing classId by checking teacherId
        String? announcementClassId = data["classId"] as String?;
        String? announcementTeacherId = data["teacherId"] as String?;
        
        // If classId is missing, try to find it from teacher's classes
        if (announcementClassId == null && announcementTeacherId != null) {
          final teacherClasses = await _firestore
              .collection("classes")
              .where("teacherId", isEqualTo: announcementTeacherId)
              .get();
          
          for (final classDoc in teacherClasses.docs) {
            final classId = classDoc.id;
            if (classIds.contains(classId)) {
              announcementClassId = classId;
              break;
            }
          }
        }
        
        // Skip if we can't determine the class
        if (announcementClassId == null || !classIds.contains(announcementClassId)) {
          continue;
        }

        // Extract fields with fallbacks
        String title = _extractField(data, ['title', 'announcementTitle', 'subject']) ?? "New Announcement";
        String content = _extractField(data, ['content', 'description', 'announcementContent', 'body']) ?? "No description available";
        DateTime createdAt = _extractDate(data, ['createdAt', 'timestamp', 'date']) ?? DateTime.now();
        String teacherName = _extractField(data, ['teacherName', 'author', 'createdBy', 'teacher']) ?? "Teacher";
        String className = _extractField(data, ['className', 'class', 'courseName']) ?? "Class";

        announcements.add(
          Announcement(
            id: doc.id,
            title: title,
            content: content,
            createdAt: createdAt,
            teacherName: teacherName,
            className: className,
          ),
        );
      }

      return announcements;
    } catch (e) {
      print("Error loading announcements: $e");
      return [];
    }
  }

  // Helper method to extract string fields with multiple possible keys
  String? _extractField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  // Helper method to extract date fields
  DateTime? _extractDate(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        }
      }
    }
    return null;
  }
}