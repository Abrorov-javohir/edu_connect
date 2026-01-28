// cubits/tasks_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/student_screens/cubit/task_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksCubit extends Cubit<TasksState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TasksCubit() : super(TasksInitial());

  Future<void> loadStudentTasks() async {
    emit(TasksLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(TasksError('User not authenticated'));
        return;
      }

      // Get classes this student is enrolled in
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      final classIds = classStudentsSnapshot.docs
          .map((doc) => doc["classId"])
          .toList();

      if (classIds.isEmpty) {
        emit(TasksLoaded([]));
        return;
      }

      // Get tasks for these classes
      final tasksSnapshot = await _firestore
          .collection("tasks")
          .where("classId", whereIn: classIds)
          .orderBy("deadline", descending: false)
          .get();

      emit(TasksLoaded(tasksSnapshot.docs));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> completeTask(String taskId, bool completed) async {
    emit(TaskUpdating());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(TaskUpdateError('User not authenticated'));
        return;
      }

      // Check if task completion already exists
      final completionSnapshot = await _firestore
          .collection("taskCompletions")
          .where("taskId", isEqualTo: taskId)
          .where("studentId", isEqualTo: userId)
          .get();

      if (completionSnapshot.docs.isNotEmpty) {
        // Update existing completion
        await _firestore
            .collection("taskCompletions")
            .doc(completionSnapshot.docs.first.id)
            .update({
              "completed": completed,
              "completedAt": completed ? FieldValue.serverTimestamp() : null,
            });
      } else if (completed) {
        // Create new completion record
        await _firestore.collection("taskCompletions").add({
          "taskId": taskId,
          "studentId": userId,
          "completed": true,
          "completedAt": FieldValue.serverTimestamp(),
        });
      }

      // Refresh tasks
      loadStudentTasks();
    } catch (e) {
      emit(TaskUpdateError(e.toString()));
    }
  }

  Future<bool> isTaskCompleted(String taskId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return false;

      final completionSnapshot = await _firestore
          .collection("taskCompletions")
          .where("taskId", isEqualTo: taskId)
          .where("studentId", isEqualTo: userId)
          .limit(1)
          .get();

      if (completionSnapshot.docs.isEmpty) return false;

      final completionData =
          completionSnapshot.docs.first.data() as Map<String, dynamic>;
      return completionData["completed"] == true;
    } catch (e) {
      return false;
    }
  }

  double calculateHomeworkProgress({
    required bool isCompleted,
    required bool isOverdue,
    required DateTime deadline,
  }) {
    if (isCompleted) return 1.0;
    if (isOverdue) {
      final overdueDays = DateTime.now().difference(deadline).inDays;
      return (1.0 - (overdueDays * 0.1)).clamp(0.0, 0.8);
    } else {
      final daysLeft = deadline.difference(DateTime.now()).inDays;
      if (daysLeft <= 7) {
        return ((7 - daysLeft) / 7.0 * 0.8).clamp(0.0, 0.8);
      } else {
        return 0.2;
      }
    }
  }

  // cubits/tasks_cubit.dart (Add this method)
  Future<List<DocumentSnapshot>> getStudentClasses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      return classStudentsSnapshot.docs;
    } catch (e) {
      return [];
    }
  }
}
