// task_screen.dart (updated with class info)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/task/task_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskScreen extends StatelessWidget {
  final String taskId;

  const TaskScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tasks")
            .doc(taskId)
            .snapshots(),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // TASK NOT FOUND
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Task not found ❌",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // GET DATA
          final doc = snapshot.data!;
          final task = doc.data() as Map<String, dynamic>?;
          
          if (task == null) {
            return const Center(
              child: Text(
                "Task data not available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final deadlineTimestamp = task["deadline"] as Timestamp?;
          if (deadlineTimestamp == null) {
            return const Center(
              child: Text(
                "Deadline not set",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          final deadline = deadlineTimestamp.toDate();
          final now = DateTime.now();
          final isOverdue = deadline.isBefore(now);
          final daysLeft = deadline.difference(now).inDays;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOverdue ? Colors.red.shade200 : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task["title"] ?? "No Title",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOverdue ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isOverdue ? Colors.red.shade300 : Colors.green.shade300,
                          ),
                        ),
                        child: Text(
                          isOverdue 
                            ? "Overdue" 
                            : daysLeft == 0 
                              ? "Due Today" 
                              : "$daysLeft days left",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isOverdue ? Colors.red.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    task["description"] ?? "No description provided",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Task Information",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  Icons.calendar_today,
                  "Deadline",
                  "${deadline.day}/${deadline.month}/${deadline.year}",
                  isOverdue ? Colors.red : Colors.blue,
                ),

                const SizedBox(height: 12),

                // SHOW CLASS NAME
                if (task["classId"] != null) ...[
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("classes")
                        .doc(task["classId"])
                        .get(),
                    builder: (context, classSnapshot) {
                      if (classSnapshot.connectionState == ConnectionState.waiting) {
                        return _buildInfoCard(
                          Icons.class_outlined,
                          "Class",
                          "Loading...",
                          Colors.grey.shade600,
                        );
                      }
                      
                      if (classSnapshot.hasData && classSnapshot.data!.exists) {
                        final classData = classSnapshot.data!.data() as Map<String, dynamic>;
                        return _buildInfoCard(
                          Icons.class_outlined,
                          "Class",
                          classData["className"] ?? "Unknown Class",
                          Colors.blue.shade600,
                        );
                      }
                      
                      return _buildInfoCard(
                        Icons.class_outlined,
                        "Class",
                        "Unknown",
                        Colors.grey.shade600,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                _buildInfoCard(
                  Icons.access_time,
                  "Created",
                  (task["createdAt"] as Timestamp?)
                          ?.toDate()
                          .toString()
                          .split(' ')[0] ?? "Unknown",
                  Colors.grey.shade600,
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherTaskEditScreen(taskId: taskId),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Edit Task",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("tasks")
                                .doc(taskId)
                                .delete();

                            Navigator.pop(context);
                          },
                          child: Text(
                            "Delete",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}