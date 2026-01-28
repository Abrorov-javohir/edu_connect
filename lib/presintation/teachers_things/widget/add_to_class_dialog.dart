// widgets/add_to_class_dialog.dart
import 'package:edu_connect/presintation/teachers_things/cubit/student_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/students_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ FIXED IMPORTS - Use your actual cubit paths

class AddToClassDialog extends StatelessWidget {
  final String studentId;
  final String studentName;

  const AddToClassDialog({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentsCubit, StudentsState>(
      listener: (context, state) {
        if (state is StudentAddedSuccess) {
          Navigator.pop(context, true); // Return success
        } else if (state is StudentAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: BlocBuilder<StudentsCubit, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading || state is StudentAdding) { // ✅ Fixed state name
            return _buildLoadingDialog(context);
          } else if (state is StudentsError) { // ✅ Fixed state name
            return _buildErrorDialog(context, state.error);
          } else if (state is TeacherClassesLoaded) {
            return _buildClassSelectionDialog(context, state.classes);
          } else if (state is StudentAddError) {
            return _buildErrorDialog(context, state.error);
          }
          return _buildLoadingDialog(context);
        },
      ),
    );
  }

  Widget _buildLoadingDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Loading..."),
      content: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorDialog(BuildContext context, String error) {
    return AlertDialog(
      title: const Text("Error"),
      content: Text(error),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }

  Widget _buildClassSelectionDialog(BuildContext context, List<DocumentSnapshot> classes) {
    String? selectedClass;
    
    if (classes.isEmpty) {
      return AlertDialog(
        title: const Text("No Classes"),
        content: const Text("You don't have any classes created."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Add to Class", style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select a class for $studentName", style: GoogleFonts.poppins()),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedClass,
                hint: Text("Select a class", style: GoogleFonts.poppins()),
                items: classes.map((classDoc) {
                  final data = classDoc.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: classDoc.id,
                    child: Text(data["className"] ?? "No Name", style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: selectedClass == null
                  ? null
                  : () {
                      context.read<StudentsCubit>().addStudentToClass(
                        classId: selectedClass!,
                        studentId: studentId,
                        studentName: studentName,
                      );
                    },
              child: Text("Add", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}