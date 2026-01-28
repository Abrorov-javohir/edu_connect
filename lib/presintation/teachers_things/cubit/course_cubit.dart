// cubits/courses_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/course_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CoursesCubit() : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(CoursesError('User not authenticated'));
        return;
      }

      final querySnapshot = await _firestore
          .collection("courses")
          .where("teacherId", isEqualTo: userId)
          .get();

      emit(CoursesLoaded(querySnapshot.docs));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore
          .collection("courses")
          .doc(courseId)
          .delete();
      loadCourses(); // Refresh list
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void searchCourses(String query) {
    if (state is! CoursesLoaded) return;
    
    final courses = (state as CoursesLoaded).courses;
    if (query.isEmpty) {
      emit(CoursesLoaded(courses));
      return;
    }

    final filtered = courses.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final courseName = (data["courseName"] ?? "").toLowerCase();
      final roomNumber = (data["roomNumber"] ?? "").toLowerCase();
      return courseName.contains(query.toLowerCase()) ||
          roomNumber.contains(query.toLowerCase());
    }).toList();

    emit(CoursesLoaded(filtered));
  }

  void sortCourses({
    required List<DocumentSnapshot> courses,
    String sortBy = 'name',
    bool sortAscending = true,
  }) {
    final sorted = List<DocumentSnapshot>.from(courses);
    
    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      int result = 0;
      switch (sortBy) {
        case 'name':
          result = (dataA["courseName"] ?? "").toLowerCase().compareTo(
            (dataB["courseName"] ?? "").toLowerCase(),
          );
          break;
        case 'date':
          final dateA = (dataA["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
          final dateB = (dataB["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
          result = dateA.compareTo(dateB);
          break;
        case 'room':
          result = (dataA["roomNumber"] ?? "").toLowerCase().compareTo(
            (dataB["roomNumber"] ?? "").toLowerCase(),
          );
          break;
      }
      return sortAscending ? result : -result;
    });

    emit(CoursesLoaded(sorted));
  }
}