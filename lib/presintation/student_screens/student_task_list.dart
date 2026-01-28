// widgets/tasks_list.dart (Updated)
import 'package:edu_connect/presintation/student_screens/cubit/task_cubit.dart';
import 'package:edu_connect/presintation/student_screens/model/task_model.dart';
import 'package:edu_connect/presintation/student_screens/widget/task_card.dart';
import 'package:edu_connect/presintation/student_screens/widget/task_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksList extends StatelessWidget {
  final List<DocumentSnapshot> tasks;

  const TasksList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const TasksEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskFutureBuilder(taskDoc: tasks[index]);
      },
    );
  }
}

class TaskFutureBuilder extends StatelessWidget {
  final DocumentSnapshot taskDoc;

  const TaskFutureBuilder({super.key, required this.taskDoc});

  @override
  Widget build(BuildContext context) {
    final taskData = taskDoc.data() as Map<String, dynamic>;

    return FutureBuilder<bool>(
      future: context.read<TasksCubit>().isTaskCompleted(taskDoc.id),
      builder: (context, completionSnapshot) {
        final isCompleted = completionSnapshot.data == true;

        return FutureBuilder<DocumentSnapshot?>(
          future: _getClassData(taskData["classId"]),
          builder: (context, classSnapshot) {
            String subject = "Subject";
            String className = "Unknown";

            if (classSnapshot.data?.exists == true) {
              final classData =
                  classSnapshot.data!.data() as Map<String, dynamic>;
              className = classData["className"] ?? "Unknown";

              // Extract subject from class name
              if (className.contains(" ")) {
                subject = className.split(" ")[0];
              } else {
                subject = className;
              }
            }

            final taskModel = TaskModel.fromFirestore(
              taskDoc,
              taskData,
              isCompleted,
              subject,
              className,
            );

            return TaskCard(task: taskModel);
          },
        );
      },
    );
  }

  Future<DocumentSnapshot?> _getClassData(String? classId) async {
    if (classId == null) return null;
    try {
      return await FirebaseFirestore.instance
          .collection("classes")
          .doc(classId)
          .get();
    } catch (e) {
      return null;
    }
  }
}
