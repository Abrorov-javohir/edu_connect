// utils/students_utils.dart
import 'package:edu_connect/presintation/teachers_things/cubit/student_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/widget/add_to_class_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsUtils {
  static Future<bool> showAddToClassDialog(
    BuildContext context, 
    String studentId, 
    String studentName,
  ) async {
    // Load teacher's classes first
    await context.read<StudentsCubit>().loadTeacherClasses();
    
    // Show dialog
    return await showDialog<bool>(
      context: context,
      builder: (context) => AddToClassDialog(
        studentId: studentId,
        studentName: studentName,
      ),
    ) ?? false;
  }
}