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

      // Load announcements for these classes - OPTIMIZED: Use limit for better performance
      final announcementsSnapshot = await _firestore
          .collection("announcements")
          .where("classId", whereIn: classIds)
          .orderBy("createdAt", descending: true)
          .limit(5) // Limit to 5 announcements for better performance
          .get();

      final List<Announcement> announcements = [];

      for (final doc in announcementsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Handle different possible field names with proper null safety
        String title = "New Announcement";
        String content = "No description available";
        DateTime createdAt = DateTime.now();
        String teacherName = "Teacher";
        String className = "Class";

        // Title handling
        if (data.containsKey('title') && data['title'] != null) {
          title = data['title'] as String;
        } else if (data.containsKey('announcementTitle') &&
            data['announcementTitle'] != null) {
          title = data['announcementTitle'] as String;
        }

        // Content handling
        if (data.containsKey('content') && data['content'] != null) {
          content = data['content'] as String;
        } else if (data.containsKey('description') &&
            data['description'] != null) {
          content = data['description'] as String;
        } else if (data.containsKey('announcementContent') &&
            data['announcementContent'] != null) {
          content = data['announcementContent'] as String;
        }

        // Date handling
        if (data.containsKey('createdAt') && data['createdAt'] != null) {
          final createdAtField = data['createdAt'];
          if (createdAtField is Timestamp) {
            createdAt = createdAtField.toDate();
          } else if (createdAtField is DateTime) {
            createdAt = createdAtField;
          }
        } else if (data.containsKey('timestamp') && data['timestamp'] != null) {
          final timestampField = data['timestamp'];
          if (timestampField is Timestamp) {
            createdAt = timestampField.toDate();
          } else if (timestampField is DateTime) {
            createdAt = timestampField;
          }
        }

        // Teacher name handling
        if (data.containsKey('teacherName') && data['teacherName'] != null) {
          teacherName = data['teacherName'] as String;
        } else if (data.containsKey('author') && data['author'] != null) {
          teacherName = data['author'] as String;
        }

        // Class name handling
        if (data.containsKey('className') && data['className'] != null) {
          className = data['className'] as String;
        }

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
}
