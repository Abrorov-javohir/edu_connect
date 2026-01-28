// cubits/home_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<DocumentSnapshot> upcomingTasks;
  final List<DocumentSnapshot> newTasks;
  final List<DocumentSnapshot> recentAnnouncements;
  final List<DocumentSnapshot> recentStudents;

  HomeLoaded({
    required this.upcomingTasks,
    required this.newTasks,
    required this.recentAnnouncements,
    required this.recentStudents,
  });
}

class HomeError extends HomeState {
  final String error;

  HomeError(this.error);
}