// cubits/students_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StudentsState {}

class StudentsInitial extends StudentsState {}

class StudentsLoading extends StudentsState {}

class StudentsLoaded extends StudentsState {
  final List<DocumentSnapshot> students;

  StudentsLoaded(this.students);
}

class StudentsError extends StudentsState {
  final String error;

  StudentsError(this.error);
}

class TeacherClassesLoading extends StudentsState {}

class TeacherClassesLoaded extends StudentsState {
  final List<DocumentSnapshot> classes;

  TeacherClassesLoaded(this.classes);
}

class TeacherClassesError extends StudentsState {
  final String error;

  TeacherClassesError(this.error);
}

class StudentAddedSuccess extends StudentsState {}