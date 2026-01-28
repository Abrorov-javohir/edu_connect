// data/student_stats_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StudentStats> getStudentStats(String userId) async {
    try {
      // Get student stats from user document (try faster cached approach first)
      final userDoc = await _firestore.collection("users").doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        
        // Try to get cached stats first
        int totalPoints = 0;
        int classRank = 0;
        int globalRank = 0;
        double overallProgress = 0.0;
        int currentStreak = 0;
        int longestStreak = 0;
        int completedTasks = 0;
        int totalTasks = 0;
        List<TaskProgress> tasks = [];
        
        // Check if we have cached stats
        if (userData.containsKey('stats')) {
          final statsData = userData['stats'] as Map<String, dynamic>;
          totalPoints = statsData['totalPoints'] as int? ?? 0;
          classRank = statsData['classRank'] as int? ?? 0;
          globalRank = statsData['globalRank'] as int? ?? 0;
          overallProgress = statsData['overallProgress'] as double? ?? 0.0;
          currentStreak = statsData['currentStreak'] as int? ?? 0;
          longestStreak = statsData['longestStreak'] as int? ?? 0;
          completedTasks = statsData['completedTasks'] as int? ?? 0;
          totalTasks = statsData['totalTasks'] as int? ?? 0;
          
          // Get tasks from cache if available
          if (statsData.containsKey('tasks') && statsData['tasks'] is List) {
            for (final taskData in statsData['tasks']) {
              if (taskData is Map<String, dynamic>) {
                tasks.add(TaskProgress.fromMap(taskData));
              }
            }
          }
        }
        
        // If no cached stats or they're outdated, calculate them
        if (tasks.isEmpty || totalPoints == 0) {
          // Calculate fresh stats (more comprehensive)
          final stats = await _calculateFreshStats(userId);
          return stats;
        }
        
        return StudentStats(
          totalPoints: totalPoints,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          overallProgress: overallProgress,
          classRank: classRank,
          globalRank: globalRank,
          completedTasks: completedTasks,
          totalTasks: totalTasks,
          tasks: tasks,
        );
      }
      
      // If no user doc, calculate fresh stats
      return await _calculateFreshStats(userId);
    } catch (e) {
      print("Error getting student stats: $e");
      // Return default stats on error
      return StudentStats(
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        overallProgress: 0.0,
        classRank: 0,
        globalRank: 0,
        completedTasks: 0,
        totalTasks: 0,
        tasks: [],
      );
    }
  }

  Future<StudentStats> _calculateFreshStats(String userId) async {
    try {
      // Get classes this student is enrolled in
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) {
        return StudentStats(
          totalPoints: 0,
          currentStreak: 0,
          longestStreak: 0,
          overallProgress: 0.0,
          classRank: 0,
          globalRank: 0,
          completedTasks: 0,
          totalTasks: 0,
          tasks: [],
        );
      }

      final Set<String> classIds = {};
      for (final doc in classStudentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final classId = data["classId"] as String?;
        if (classId != null) {
          classIds.add(classId);
        }
      }

      // Get all tasks and submissions efficiently
      final tasksSnapshot = await _firestore.collection("tasks").get();
      final submissionsSnapshot = await _firestore
          .collection("taskSubmissions")
          .where("studentId", isEqualTo: userId)
          .where(
            "status",
            whereIn: ["completed_unverified", "submitted", "verified"],
          )
          .get();

      // Filter tasks by student's classes
      final List<QueryDocumentSnapshot> filteredTasks = [];
      for (final taskDoc in tasksSnapshot.docs) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final taskClassId = taskData["classId"] as String?;
        if (taskClassId != null && classIds.contains(taskClassId)) {
          filteredTasks.add(taskDoc);
        }
      }

      // Calculate stats
      int totalPoints = 0;
      Set<DateTime> completedDays = {};
      int totalTasks = filteredTasks.length;
      int completedTasks = 0;

      // Create map of completed task IDs
      final completedTaskIds = <String>{};
      for (final submissionDoc in submissionsSnapshot.docs) {
        final submissionData = submissionDoc.data() as Map<String, dynamic>;
        final taskId = submissionData["taskId"] as String?;
        if (taskId != null) {
          completedTaskIds.add(taskId);
          totalPoints += 5; // 5 points per completed task

          // Get completion date from task deadline
          QueryDocumentSnapshot? foundTaskDoc;
          for (final taskDoc in filteredTasks) {
            if (taskDoc.id == taskId) {
              foundTaskDoc = taskDoc;
              break;
            }
          }

          if (foundTaskDoc != null) {
            final taskData = foundTaskDoc.data() as Map<String, dynamic>;
            final deadlineTimestamp = taskData["deadline"];
            if (deadlineTimestamp is Timestamp) {
              final deadline = deadlineTimestamp.toDate();
              completedDays.add(
                DateTime(deadline.year, deadline.month, deadline.day),
              );
            }
          }
        }
      }

      completedTasks = completedTaskIds.length;

      // Calculate streaks
      int currentStreak = 0;
      int longestStreak = 0;

      if (completedDays.isNotEmpty) {
        final sortedDates = completedDays.toList()
          ..sort((a, b) => a.compareTo(b));

        currentStreak = 1;
        longestStreak = 1;

        for (int i = 1; i < sortedDates.length; i++) {
          final previousDate = sortedDates[i - 1];
          final currentDate = sortedDates[i];
          final difference = currentDate.difference(previousDate).inDays;

          if (difference == 1) {
            currentStreak++;
            longestStreak = longestStreak > currentStreak
                ? longestStreak
                : currentStreak;
          } else if (difference > 1) {
            currentStreak = 1;
          }
        }

        // Check if current streak is still active
        final today = DateTime.now();
        final todayKey = DateTime(today.year, today.month, today.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayKey = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );

        if (!completedDays.contains(todayKey) &&
            !completedDays.contains(yesterdayKey)) {
          currentStreak = 0;
        }
      }

      // Calculate progress
      double overallProgress = totalTasks > 0
          ? completedTasks / totalTasks
          : 0.0;

      // Calculate ranks
      final classRank = await _getClassRank(userId, classIds, totalPoints);
      final globalRank = await _getGlobalRank(userId, totalPoints);

      // Get task progress data with improved subject extraction
      final tasks = await _getTaskProgress(userId, classIds);

      return StudentStats(
        totalPoints: totalPoints,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        overallProgress: overallProgress,
        classRank: classRank,
        globalRank: globalRank,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        tasks: tasks,
      );
    } catch (e) {
      print("Error calculating student stats: $e");
      return StudentStats(
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        overallProgress: 0.0,
        classRank: 0,
        globalRank: 0,
        completedTasks: 0,
        totalTasks: 0,
        tasks: [],
      );
    }
  }

  Future<List<TaskProgress>> _getTaskProgress(
    String userId,
    Set<String> classIds,
  ) async {
    try {
      final tasks = <TaskProgress>[];

      // Get all tasks for student's classes
      final tasksSnapshot = await _firestore.collection("tasks").get();

      // Group tasks by subject (extracted from className)
      final Map<String, List<TaskInfo>> subjectToTasks = {};

      for (final taskDoc in tasksSnapshot.docs) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final taskClassId = taskData["classId"] as String?;

        if (taskClassId != null && classIds.contains(taskClassId)) {
          // Get class details to extract subject
          final classDoc = await _firestore
              .collection("classes")
              .doc(taskClassId)
              .get();

          if (classDoc.exists) {
            final classData = classDoc.data() as Map<String, dynamic>;
            final className = classData["className"] ?? "Unknown Class";

            // Extract subject from class name - improved logic
            String subject = className;

            // Handle formats like "1B Mathematics" or "2A Science"
            if (className.contains(" ")) {
              List<String> parts = className.split(" ");
              // If first part looks like a class code (e.g., "1B", "2A"), remove it
              if (parts.length > 1 &&
                  parts[0].length <= 3 &&
                  parts[0].contains(RegExp(r'^[0-9][A-Z]'))) {
                subject = parts.sublist(1).join(" ");
              } else {
                // If no class code, use the whole name
                subject = className;
              }
            }

            // Initialize subject list if not exists
            if (!subjectToTasks.containsKey(subject)) {
              subjectToTasks[subject] = [];
            }

            // Add task to subject
            subjectToTasks[subject]!.add(
              TaskInfo(
                taskId: taskDoc.id,
                title: taskData["title"] ?? "Untitled Task",
                isCompleted: false,
                deadline: (taskData["deadline"] as Timestamp).toDate(),
                status: "pending",
              ),
            );
          }
        }
      }

      // Check which tasks are completed
      final submissionsSnapshot = await _firestore
          .collection("taskSubmissions")
          .where("studentId", isEqualTo: userId)
          .where(
            "status",
            whereIn: ["completed_unverified", "submitted", "verified"],
          )
          .get();

      for (final submissionDoc in submissionsSnapshot.docs) {
        final submissionData = submissionDoc.data() as Map<String, dynamic>;
        final taskId = submissionData["taskId"] as String?;

        for (final subject in subjectToTasks.keys) {
          for (final task in subjectToTasks[subject]!) {
            if (task.taskId == taskId) {
              task.isCompleted = true;
              task.status = "completed";
            }
          }
        }
      }

      // Create task progress objects
      for (final subject in subjectToTasks.keys) {
        final tasksList = subjectToTasks[subject]!;

        for (final task in tasksList) {
          // Get color for subject
          final color = _getSubjectColor(subject);

          // Calculate task progress percentage (100% if completed, 0% if not)
          final progress = task.isCompleted ? 1.0 : 0.0;

          // Create task progress object
          tasks.add(
            TaskProgress(
              taskId: task.taskId,
              title: task.title,
              subject: subject,
              isCompleted: task.isCompleted,
              deadline: task.deadline,
              status: task.status,
              color: color,
              progress: progress,
            ),
          );
        }
      }

      return tasks;
    } catch (e) {
      print("Error getting task progress: $e");
      return [];
    }
  }

  Future<int> _getClassRank(
    String userId,
    Set<String> classIds,
    int userPoints,
  ) async {
    try {
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .get();
      final Set<String> studentIds = {};

      for (final doc in classStudentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final classId = data["classId"] as String?;
        final studentId = data["studentId"] as String?;

        if (classId != null &&
            studentId != null &&
            classIds.contains(classId)) {
          studentIds.add(studentId);
        }
      }

      int rank = 1;
      for (final studentId in studentIds) {
        if (studentId != userId) {
          final studentPoints = await _calculateStudentPoints(studentId);
          if (studentPoints > userPoints) {
            rank++;
          }
        }
      }

      return rank;
    } catch (e) {
      return 1;
    }
  }

  Future<int> _getGlobalRank(String userId, int userPoints) async {
    try {
      final usersSnapshot = await _firestore.collection("users").get();
      int rank = 1;

      for (final userDoc in usersSnapshot.docs) {
        if (userDoc.id != userId) {
          final studentPoints = await _calculateStudentPoints(userDoc.id);
          if (studentPoints > userPoints) {
            rank++;
          }
        }
      }

      return rank;
    } catch (e) {
      return 1;
    }
  }

  Future<int> _calculateStudentPoints(String userId) async {
    try {
      final submissionsSnapshot = await _firestore
          .collection("taskSubmissions")
          .where("studentId", isEqualTo: userId)
          .where(
            "status",
            whereIn: ["completed_unverified", "submitted", "verified"],
          )
          .get();

      return submissionsSnapshot.docs.length * 5;
    } catch (e) {
      return 0;
    }
  }

  Future<List<CourseProgress>> getStudentCourses(String userId) async {
    try {
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) return [];

      final List<String> classIds = [];
      for (final doc in classStudentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final classId = data["classId"] as String?;
        if (classId != null) {
          classIds.add(classId);
        }
      }

      // Get all classes and tasks
      final classesSnapshot = await _firestore.collection("classes").get();
      final tasksSnapshot = await _firestore.collection("tasks").get();
      final submissionsSnapshot = await _firestore
          .collection("taskSubmissions")
          .where("studentId", isEqualTo: userId)
          .where(
            "status",
            whereIn: ["completed_unverified", "submitted", "verified"],
          )
          .get();

      // Create maps for efficient lookup
      final Map<String, QueryDocumentSnapshot> classMap = {};
      for (final classDoc in classesSnapshot.docs) {
        classMap[classDoc.id] = classDoc;
      }

      final Map<String, List<QueryDocumentSnapshot>> tasksByClass = {};
      for (final taskDoc in tasksSnapshot.docs) {
        final taskData = taskDoc.data() as Map<String, dynamic>;
        final classId = taskData["classId"] as String?;
        if (classId != null) {
          if (!tasksByClass.containsKey(classId)) {
            tasksByClass[classId] = [];
          }
          tasksByClass[classId]!.add(taskDoc);
        }
      }

      final completedTaskIds = <String>{};
      for (final submissionDoc in submissionsSnapshot.docs) {
        final submissionData = submissionDoc.data() as Map<String, dynamic>;
        final taskId = submissionData["taskId"] as String?;
        if (taskId != null) {
          completedTaskIds.add(taskId);
        }
      }

      final List<CourseProgress> courses = [];
      for (final classId in classIds) {
        final classDoc = classMap[classId];
        final tasksList = tasksByClass[classId] ?? [];

        if (classDoc != null) {
          final classData = classDoc.data() as Map<String, dynamic>;
          final className =
              classData["className"] as String? ?? "Unknown Course";

          final totalTasks = tasksList.length;
          int completedTasks = 0;

          for (final taskDoc in tasksList) {
            if (completedTaskIds.contains(taskDoc.id)) {
              completedTasks++;
            }
          }

          final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
          courses.add(CourseProgress(title: className, progress: progress));
        }
      }

      return courses;
    } catch (e) {
      print("Error getting student courses: $e");
      return [];
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return Colors.orange[700]!;
      case 'science':
        return Colors.green[700]!;
      case 'history':
        return Colors.brown[700]!;
      case 'english':
        return Colors.blue[700]!;
      case 'art':
        return Colors.pink[700]!;
      case 'music':
        return Colors.purple[700]!;
      case 'physics':
        return Colors.indigo[700]!;
      case 'chemistry':
        return Colors.red[700]!;
      case 'biology':
        return Colors.teal[700]!;
      default:
        return Colors.blueGrey[700]!;
    }
  }
}

class StudentStats {
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final double overallProgress;
  final int classRank;
  final int globalRank;
  final int completedTasks;
  final int totalTasks;
  final List<TaskProgress> tasks;

  StudentStats({
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.overallProgress,
    required this.classRank,
    required this.globalRank,
    required this.completedTasks,
    required this.totalTasks,
    required this.tasks,
  });
}

class TaskProgress {
  final String taskId;
  final String title;
  final String subject;
  final bool isCompleted;
  final DateTime deadline;
  final String status;
  final Color color;
  final double progress;

  TaskProgress({
    required this.taskId,
    required this.title,
    required this.subject,
    required this.isCompleted,
    required this.deadline,
    required this.status,
    required this.color,
    required this.progress,
  });

  factory TaskProgress.fromMap(Map<String, dynamic> data) {
    return TaskProgress(
      taskId: data['taskId'] as String,
      title: data['title'] as String,
      subject: data['subject'] as String,
      isCompleted: data['isCompleted'] as bool,
      deadline: DateTime.fromMillisecondsSinceEpoch(data['deadline']),
      status: data['status'] as String,
      color: _getColorFromHex(data['color'] as String),
      progress: data['progress'] as double,
    );
  }

  static Color _getColorFromHex(String hex) {
    // Convert hex string to Color
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.length == 6) {
      hex = 'FF' + hex; // Add alpha channel
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class TaskInfo {
  final String taskId;
  final String title;
  bool isCompleted;
  final DateTime deadline;
  String status;

  TaskInfo({
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.deadline,
    required this.status,
  });
}

class CourseProgress {
  final String title;
  final double progress;

  CourseProgress({required this.title, required this.progress});
}