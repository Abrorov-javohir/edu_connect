// widgets/students_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/widget/empty_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentsSection extends StatelessWidget {
  final List<DocumentSnapshot> recentStudents;

  const StudentsSection({
    super.key,
    required this.recentStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Students",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildStudentList(),
      ],
    );
  }

  Widget _buildStudentList() {
    if (recentStudents.isEmpty) {
      return const EmptySection(text: "No students");
    }

    return Column(
      children: recentStudents.map((student) {
        final data = student.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                data["imageUrl"] ?? 
                "https://cdn-icons-png.flaticon.com/512/236/236831.png",
              ),
            ),
            title: Text(
              data["name"] ?? "Unknown Student",
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            subtitle: Text(
              data["email"] ?? "",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      }).toList(),
    );
  }
}