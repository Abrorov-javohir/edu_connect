// widgets/tasks_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/widget/empty_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasksSection extends StatelessWidget {
  final List<DocumentSnapshot> upcomingTasks;
  final List<DocumentSnapshot> newTasks;
  final VoidCallback onTaskTap;

  const TasksSection({
    super.key,
    required this.upcomingTasks,
    required this.newTasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Tasks",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskList(upcomingTasks, context, true),
        const SizedBox(height: 20),
        Text(
          "New Tasks",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildTaskList(newTasks, context, false),
      ],
    );
  }

  Widget _buildTaskList(List<DocumentSnapshot> tasks, BuildContext context, bool isUpcoming) {
    if (tasks.isEmpty) {
      return const EmptySection(text: "No tasks");
    }

    return Column(
      children: tasks.map((task) {
        final data = task.data() as Map<String, dynamic>;
        final deadline = (data["deadline"] as Timestamp?)?.toDate();
        final createdAt = (data["createdAt"] as Timestamp?)?.toDate();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isUpcoming ? Icons.timer : Icons.fiber_new,
              color: isUpcoming ? Colors.blue : Colors.orange,
            ),
            title: Text(data["title"] ?? "No Title", style: GoogleFonts.poppins(fontSize: 15)),
            subtitle: Text(
              isUpcoming
                  ? (deadline != null
                      ? "Due: ${deadline.day}/${deadline.month}/${deadline.year}"
                      : "No deadline")
                  : (createdAt != null
                      ? "Created: ${createdAt.day}/${createdAt.month}/${createdAt.year}"
                      : "Unknown date"),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: onTaskTap,
          ),
        );
      }).toList(),
    );
  }
}