// student_all_classes_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_class_detail_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StudentAllClassesScreen extends StatefulWidget {
  const StudentAllClassesScreen({super.key});

  @override
  State<StudentAllClassesScreen> createState() => _StudentAllClassesScreenState();
}

class _StudentAllClassesScreenState extends State<StudentAllClassesScreen> {
  List<Map<String, dynamic>> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'my_classes':
            return "Mening Sinfim";
          case 'teacher':
            return "O'qituvchi: ";
          case 'no_classes':
            return "Sinf topilmadi";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'my_classes':
            return "Мои Классы";
          case 'teacher':
            return "Учитель: ";
          case 'no_classes':
            return "Классы не найдены";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'my_classes':
            return "My Classes";
          case 'teacher':
            return "Teacher: ";
          case 'no_classes':
            return "No classes found";
          default:
            return key;
        }
    }
  }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      // Get all class IDs the student is enrolled in
      final classStudentsSnapshot = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      final classIds = classStudentsSnapshot.docs
          .map((doc) => doc["classId"] as String)
          .toList();

      if (classIds.isEmpty) {
        setState(() {
          _classes = [];
          _loading = false;
        });
        return;
      }

      // Get all class details
      final classesQuery = await FirebaseFirestore.instance
          .collection("classes")
          .where(FieldPath.documentId, whereIn: classIds)
          .get();

      final List<Map<String, dynamic>> classes = [];
      
      for (final classDoc in classesQuery.docs) {
        final classData = classDoc.data();
        
        // Get teacher details
        final teacherDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(classData["teacherId"])
            .get();
            
        final teacherName = teacherDoc.exists 
            ? teacherDoc["name"] ?? teacherDoc["displayName"] ?? "Unknown Teacher"
            : "Unknown Teacher";

        // Count students in class
        final studentCountSnapshot = await FirebaseFirestore.instance
            .collection("classStudents")
            .where("classId", isEqualTo: classDoc.id)
            .get();
            
        final studentCount = studentCountSnapshot.size;

        classes.add({
          "classId": classDoc.id,
          "className": classData["className"] ?? "Unknown Class",
          "teacherName": teacherName,
          "studentCount": studentCount,
        });
      }

      setState(() {
        _classes = classes;
        _loading = false;
      });
    } catch (e) {
      print("Error loading classes: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_getLocalizedString('my_classes')} (${_classes.length})",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? Center(
                  child: Text(
                    _getLocalizedString('no_classes'),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClasses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classData = _classes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[900]
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[700]!
                                    : Colors.blue[100]!,
                              ),
                            ),
                            child: Icon(
                              Icons.class_outlined,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[300]
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(
                            classData["className"],
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          subtitle: Text(
                            "${_getLocalizedString('teacher')} ${classData["teacherName"]}",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${classData["studentCount"]} students",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentClassDetailsScreen(classData: classData),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


