// cubits/students_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentsCubit() : super(StudentsInitial());

  Future<void> loadStudents() async {
    emit(StudentsLoading());
    try {
      // Load all students
      final studentsSnapshot = await _firestore
          .collection("users")
          .where("role", isEqualTo: "student")
          .get();

      emit(StudentsLoaded(studentsSnapshot.docs));
    } catch (e) {
      emit(StudentsError(e.toString()));
    }
  }

  Future<void> loadTeacherClasses() async {
    emit(TeacherClassesLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(TeacherClassesError('User not authenticated'));
        return;
      }

      final classesSnapshot = await _firestore
          .collection("classes")
          .where("teacherId", isEqualTo: userId)
          .get();

      emit(TeacherClassesLoaded(classesSnapshot.docs));
    } catch (e) {
      emit(TeacherClassesError(e.toString()));
    }
  }

  Future<void> addStudentToClass({
    required String classId,
    required String studentId,
    required String studentName,
  }) async {
    emit(StudentAdding());
    try {
      // Check if student already exists in class
      final existingStudent = await _firestore
          .collection("classStudents")
          .where("classId", isEqualTo: classId)
          .where("studentId", isEqualTo: studentId)
          .get();

      if (existingStudent.docs.isNotEmpty) {
        emit(StudentAddError('Student already exists in this class'));
        return;
      }

      // Add student to class
      await _firestore.collection("classStudents").add({
        "classId": classId,
        "studentId": studentId,
        "studentName": studentName,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      // Update student count
      final classRef = _firestore.collection("classes").doc(classId);
      final classDoc = await classRef.get();
      final currentCount = (classDoc.data()?["studentCount"] ?? 0) as int;
      await classRef.update({
        "studentCount": currentCount + 1,
      });

      emit(StudentAddedSuccess());
    } catch (e) {
      emit(StudentAddError(e.toString()));
    }
  }
}