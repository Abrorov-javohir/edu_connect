// widgets/task_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/student_screens/widget/task_actions.dart';
import 'package:edu_connect/presintation/student_screens/widget/task_status_badge.dart' hide TaskActions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskCard2 extends StatelessWidget {
  final DocumentSnapshot task;
  final Map<String, dynamic> data;
  final bool isOverdue;
  final int daysLeft;
  final String status;
  final String taskId;
  final VoidCallback onTaskUpdated;

  const TaskCard2({
    super.key,
    required this.task,
    required this.data,
    required this.isOverdue,
    required this.daysLeft,
    required this.status,
    required this.taskId,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ✅ FIXED: Use gradient property directly, not a method
        gradient: LinearGradient(
          colors: [_getStatusColor(status).withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            TaskStatusBadge(status: status),
            const SizedBox(height: 16),

            // Task Title & Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red[50]! : Colors.green[50]!,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOverdue ? Colors.red[300]! : Colors.green[300]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isOverdue ? Icons.warning : Icons.check_circle,
                    color: isOverdue ? Colors.red[800]! : Colors.green[800]!,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["title"] ?? "No Title",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data["description"] ?? "No description",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildPointsBadge(isOverdue),
              ],
            ),
            const SizedBox(height: 16),

            // Deadline Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red[50]! : Colors.blue[50]!,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOverdue ? Colors.red[200]! : Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning : Icons.calendar_today,
                    size: 18,
                    color: isOverdue ? Colors.red[700]! : Colors.blue[700]!,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isOverdue
                          ? "Overdue by ${(-daysLeft)} days"
                          : daysLeft == 0
                          ? "Due today!"
                          : daysLeft == 1
                          ? "Due tomorrow"
                          : "Due in $daysLeft days",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.red[700]! : Colors.blue[700]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Class Info
            if (data["classId"] != null)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("classes")
                    .doc(data["classId"])
                    .get(),
                builder: (context, classSnapshot) {
                  if (classSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildClassBadge("Loading...");
                  }

                  if (classSnapshot.hasData && classSnapshot.data!.exists) {
                    final classData =
                        classSnapshot.data!.data() as Map<String, dynamic>;
                    final className = classData["className"] ?? "Unknown Class";
                    return _buildClassBadge(className);
                  }
                  return _buildClassBadge("Unknown Class");
                },
              ),

            const SizedBox(height: 20),

            // 🔥 PROFESSIONAL HYBRID MODEL BUTTONS
            TaskActions(
              taskId: taskId,
              status: status,
              onTaskUpdated: onTaskUpdated,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ REMOVED _getCardGradient method - not needed anymore

  Color _getStatusColor(String status) {
    switch (status) {
      case "completed_unverified":
        return Colors.green[700]!;
      case "submitted":
        return Colors.blue[700]!;
      case "verified":
        return Colors.purple[700]!;
      case "rejected":
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildPointsBadge(bool isOverdue) {
    final points = isOverdue ? "-5" : "+5";
    final color = isOverdue ? Colors.red[700]! : Colors.green[700]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.star, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            points,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassBadge(String className) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.class_, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            className,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}
