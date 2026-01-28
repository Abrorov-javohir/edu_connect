// cubits/tasks_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<DocumentSnapshot> tasks;

  TasksLoaded(this.tasks);
}

class TasksError extends TasksState {
  final String error;

  TasksError(this.error);
}

class TaskUpdating extends TasksState {}

class TaskUpdateError extends TasksState {
  final String error;

  TaskUpdateError(this.error);
}