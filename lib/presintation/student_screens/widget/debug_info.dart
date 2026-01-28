// widgets/debug_info.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.yellow[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Debug Information",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text("Student ID: $userId", style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          _buildClassEnrollments(),
          const SizedBox(height: 8),
          _buildTaskCount(),
        ],
      ),
    );
  }

  Widget _buildClassEnrollments() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Text("No user logged in");

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final enrollments = snapshot.data!.docs;

        if (enrollments.isEmpty) {
          return Text(
            "Not enrolled in any classes",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enrolled in ${enrollments.length} class${enrollments.length > 1 ? 'es' : ''}:",
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            ...enrollments.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "- Class ID: ${data['classId']}",
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTaskCount() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Text("No user logged in");

    // ✅ FIXED: Remove the problematic spread operator
    return FutureBuilder<List<String>>(
      future: _getStudentClassIds(userId),
      builder: (context, classIdsSnapshot) {
        if (!classIdsSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final classIds = classIdsSnapshot.data!;

        if (classIds.isEmpty) {
          return const Text("No classes found");
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("tasks")
              .where("classId", whereIn: classIds)
              .get(),
          builder: (context, tasksSnapshot) {
            if (!tasksSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final tasks = tasksSnapshot.data!.docs;

            return Text(
              "Found ${tasks.length} task${tasks.length != 1 ? 's' : ''} for your classes",
              style: GoogleFonts.poppins(fontSize: 12),
            );
          },
        );
      },
    );
  }

  // ✅ FIXED: Helper method to get class IDs properly
  Future<List<String>> _getStudentClassIds(String userId) async {
    try {
      final classStudentsSnapshot = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      return classStudentsSnapshot.docs
          .map((doc) => doc["classId"] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
