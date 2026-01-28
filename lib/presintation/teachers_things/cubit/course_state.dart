// cubits/courses_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<DocumentSnapshot> courses;

  CoursesLoaded(this.courses);
}

class CoursesError extends CoursesState {
  final String error;

  CoursesError(this.error);
}