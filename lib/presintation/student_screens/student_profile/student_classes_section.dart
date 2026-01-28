// widgets/student_classes_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class StudentClassesSection extends StatelessWidget {
  final BuildContext context;

  const StudentClassesSection({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Container();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyClasses();
        }

        final classDocs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Classes",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...classDocs.map((classDoc) => _buildClassItem(classDoc)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildClassItem(QueryDocumentSnapshot classDoc) {
    final classId = classDoc["classId"] as String;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("classes")
          .doc(classId)
          .get(),
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text("Loading..."),
          );
        }

        if (!classSnapshot.hasData || !classSnapshot.data!.exists) {
          return const ListTile(title: Text("Unknown Class"));
        }

        final classData = classSnapshot.data!.data() as Map<String, dynamic>;
        final className = classData["className"] ?? "Unknown Class";
        final subject = _getSubjectFromClassName(className);

        return FadeIn(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getSubjectColor(subject).withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getSubjectColor(subject).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: _getSubjectColor(subject).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getSubjectColor(subject).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _getSubjectIcon(subject),
                      color: _getSubjectColor(subject),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _getSubjectColor(subject),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Classes",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.grey[400], size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "You're not enrolled in any classes yet. Contact your teacher to get started!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSubjectFromClassName(String className) {
    final lowerName = className.toLowerCase();
    if (lowerName.contains('math')) return 'Mathematics';
    if (lowerName.contains('science')) return 'Science';
    if (lowerName.contains('history')) return 'History';
    if (lowerName.contains('english')) return 'English';
    if (lowerName.contains('art')) return 'Art';
    if (lowerName.contains('music')) return 'Music';
    if (lowerName.contains('physics')) return 'Physics';
    if (lowerName.contains('chemistry')) return 'Chemistry';
    if (lowerName.contains('biology')) return 'Biology';
    return 'General';
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Colors.orange[700]!;
      case 'science':
        return Colors.green[700]!;
      case 'history':
        return Colors.brown[700]!;
      case 'english':
        return Colors.blue[700]!;
      case 'art':
        return Colors.pink[700]!;
      case 'music':
        return Colors.purple[700]!;
      case 'physics':
        return Colors.indigo[700]!;
      case 'chemistry':
        return Colors.red[700]!;
      case 'biology':
        return Colors.teal[700]!;
      default:
        return Colors.blueGrey[700]!;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history;
      case 'english':
        return Icons.book;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'physics':
        return Icons.auto_fix_high;
      case 'chemistry':
        return Icons.science_outlined;
      case 'biology':
        return Icons.eco;
      default:
        return Icons.school;
    }
  }
}
