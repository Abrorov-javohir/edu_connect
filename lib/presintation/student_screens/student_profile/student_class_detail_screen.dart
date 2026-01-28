// student_class_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_class_student_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StudentClassDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> classData;

  const StudentClassDetailsScreen({super.key, required this.classData});

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'class_info':
            return "Sinf Ma'lumoti";
          case 'teacher':
            return "O'qituvchi";
          case 'total_students':
            return "Jami Talabalar";
          case 'view_classmates':
            return "Sinfdoshlarni Ko'rish";
          case 'students':
            return "talaba";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'class_info':
            return "Информация о классе";
          case 'teacher':
            return "Учитель";
          case 'total_students':
            return "Всего студентов";
          case 'view_classmates':
            return "Посмотреть одноклассников";
          case 'students':
            return "студент";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'class_info':
            return "Class Information";
          case 'teacher':
            return "Teacher";
          case 'total_students':
            return "Total Students";
          case 'view_classmates':
            return "View Classmates";
          case 'students':
            return "students";
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
          classData["className"],
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]?.withOpacity(0.2)
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[700]!
                      : Colors.blue[100]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData["className"],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[300]
                          : Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[800],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${_getLocalizedString('teacher', context)}: ${classData["teacherName"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[300]
                              : Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[800],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${classData["studentCount"]} ${_getLocalizedString('students', context)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[300]
                              : Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getLocalizedString('class_info', context),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[300]
                      : Colors.blue,
                ),
                title: Text(_getLocalizedString('teacher', context)),
                subtitle: Text(classData["teacherName"]),
              ),
            ),
            // Make Total Students card tappable
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentClassStudentsScreen(
                      classId: classData["classId"],
                      className: classData["className"],
                    ),
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLocalizedString('total_students', context),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            Text(
                              "${classData["studentCount"]} ${_getLocalizedString('students', context)}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentClassStudentsScreen(
                        classId: classData["classId"],
                        className: classData["className"],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[800]
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(_getLocalizedString('view_classmates', context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
