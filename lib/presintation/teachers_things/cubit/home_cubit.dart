// cubits/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeCubit() : super(HomeInitial());

  Future<void> loadDashboardData() async {
    emit(HomeLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(HomeError('User not authenticated'));
        return;
      }

      // Load tasks
      final tasksSnapshot = await _firestore
          .collection("tasks")
          .where("teacherId", isEqualTo: userId)
          .get();

      // Load announcements
      final announcementsSnapshot = await _firestore
          .collection("announcements")
          .where("teacherId", isEqualTo: userId)
          .get();

      // Load students (through classes)
      final classesSnapshot = await _firestore
          .collection("classes")
          .where("teacherId", isEqualTo: userId)
          .get();

      final List<DocumentSnapshot> allStudents = [];
      
      for (final classDoc in classesSnapshot.docs) {
        final classId = classDoc.id;
        final classStudentsSnapshot = await _firestore
            .collection("classStudents")
            .where("classId", isEqualTo: classId)
            .get();

        for (final classStudentDoc in classStudentsSnapshot.docs) {
          final studentId = classStudentDoc["studentId"];
          final studentDoc = await _firestore
              .collection("users")
              .doc(studentId)
              .get();
          
          if (studentDoc.exists) {
            allStudents.add(studentDoc);
          }
        }
      }

      // Process and sort data
      final upcomingTasks = _getUpcomingTasks(tasksSnapshot.docs);
      final newTasks = _getNewTasks(tasksSnapshot.docs);
      final recentAnnouncements = _getRecentAnnouncements(announcementsSnapshot.docs);
      final recentStudents = _getRecentStudents(allStudents);

      emit(HomeLoaded(
        upcomingTasks: upcomingTasks,
        newTasks: newTasks,
        recentAnnouncements: recentAnnouncements,
        recentStudents: recentStudents,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  List<DocumentSnapshot> _getUpcomingTasks(List<DocumentSnapshot> tasks) {
    final upcoming = tasks.where((task) {
      final data = task.data() as Map<String, dynamic>;
      final deadline = data["deadline"] as Timestamp?;
      if (deadline == null) return false;
      return deadline.toDate().isAfter(DateTime.now());
    }).toList();

    upcoming.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final deadlineA = (dataA["deadline"] as Timestamp?)?.toDate() ?? DateTime(2100);
      final deadlineB = (dataB["deadline"] as Timestamp?)?.toDate() ?? DateTime(2100);
      return deadlineA.compareTo(deadlineB);
    });

    return upcoming.take(3).toList();
  }

  List<DocumentSnapshot> _getNewTasks(List<DocumentSnapshot> tasks) {
    final sorted = List<DocumentSnapshot>.from(tasks);
    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final createdAtA = (dataA["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      final createdAtB = (dataB["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      return createdAtB.compareTo(createdAtA); // Most recent first
    });

    return sorted.take(3).toList();
  }

  List<DocumentSnapshot> _getRecentAnnouncements(List<DocumentSnapshot> announcements) {
    final sorted = List<DocumentSnapshot>.from(announcements);
    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final createdAtA = (dataA["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      final createdAtB = (dataB["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      return createdAtB.compareTo(createdAtA); // Most recent first
    });

    return sorted.take(3).toList();
  }

  List<DocumentSnapshot> _getRecentStudents(List<DocumentSnapshot> students) {
    final sorted = List<DocumentSnapshot>.from(students);
    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final createdAtA = (dataA["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      final createdAtB = (dataB["createdAt"] as Timestamp?)?.toDate() ?? DateTime(2000);
      return createdAtB.compareTo(createdAtA); // Most recent first
    });

    return sorted.take(3).toList();
  }
}