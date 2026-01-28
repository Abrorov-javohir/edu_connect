// widgets/tasks_empty_state.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasksEmptyState extends StatelessWidget {
  const TasksEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[100]!), // ✅ Fixed: Use Border.all()
            ),
            child: Icon(
              Icons.task_alt,
              size: 60,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Tasks Yet",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Your teachers will assign tasks here. Complete them to earn points!",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center, // ✅ Fixed: Moved textAlign outside style
            ),
          ),
        ],
      ),
    );
  }
}