// student_class_students_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StudentClassStudentsScreen extends StatelessWidget {
  final String classId;
  final String className;

  const StudentClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'classmates':
            return "Sinfdoshlar - $className";
          case 'no_students':
            return "Bu sinfda talabalar yo'q";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'classmates':
            return "Одноклассники - $className";
          case 'no_students':
            return "Студентов в этом классе нет";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'classmates':
            return "Classmates - $className";
          case 'no_students':
            return "No students in this class";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedString('classmates', context),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getClassStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final students = snapshot.data!;
          if (students.isEmpty) {
            return Center(child: Text(_getLocalizedString('no_students', context)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      student["imageUrl"] ??
                          "https://cdn-icons-png.flaticon.com/512/236/236831.png",
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                  title: Text(
                    student["name"],
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    student["email"],
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onTap: () {
                    // Navigate to student profile details
                    // TODO: Implement navigation to student profile
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getClassStudents() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      // Get all students in this class
      final classStudentsSnapshot = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("classId", isEqualTo: classId)
          .get();

      final students = <Map<String, dynamic>>[];

      for (final classStudentDoc in classStudentsSnapshot.docs) {
        final studentId = classStudentDoc["studentId"];

        // Don't add current user to classmates list
        if (studentId == currentUserId) continue;

        // Get student details
        final studentDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(studentId)
            .get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data()!;
          students.add({
            "studentId": studentId,
            "name": studentData["name"] ?? studentData["displayName"] ?? "Unknown Student",
            "email": studentData["email"] ?? "No Email",
            "imageUrl": studentData["imageUrl"] ?? "https://cdn-icons-png.flaticon.com/512/236/236831.png",
          });
        }
      }

      return students;
    } catch (e) {
      print("Error getting class students: $e");
      return [];
    }
  }
}