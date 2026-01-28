// teacher_class_students_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/student_details_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherClassStudentsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<TeacherClassStudentsScreen> createState() =>
      _TeacherClassStudentsScreenState();
}

class _TeacherClassStudentsScreenState
    extends State<TeacherClassStudentsScreen> {
  List<DocumentSnapshot> _students = [];
  bool _loading = true;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'class_students':
            return "${widget.className} O'quvchilari";
          case 'no_students':
            return "Bu sinfda o'quvchilar yo'q";
          case 'student_details':
            return "O'quvchi Tafsilotlari";
          case 'view_details':
            return "Tafsilotlarni Ko'rish";
          case 'name':
            return "Ism";
          case 'email':
            return "Elektron pochta";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'class_students':
            return "Ученики ${widget.className}";
          case 'no_students':
            return "В этом классе нет учеников";
          case 'student_details':
            return "Детали Ученика";
          case 'view_details':
            return "Просмотреть Детали";
          case 'name':
            return "Имя";
          case 'email':
            return "Электронная почта";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'class_students':
            return "${widget.className} Students";
          case 'no_students':
            return "No students in this class";
          case 'student_details':
            return "Student Details";
          case 'view_details':
            return "View Details";
          case 'name':
            return "Name";
          case 'email':
            return "Email";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);

    try {
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("classId", isEqualTo: widget.classId)
          .get();

      setState(() {
        _students = studentsSnapshot.docs;
        _loading = false;
      });
    } catch (e) {
      print("Error loading students: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getLocalizedString('class_students'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[900]?.withOpacity(0.2)
                            : Colors.blue[50],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[700]!
                              : Colors.blue[100]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue
                                        : Colors.blue)
                                    .withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('no_students'),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: _students.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final studentDoc = _students[index];
                  final data = studentDoc.data() as Map<String, dynamic>;

                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    duration: const Duration(milliseconds: 600),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]!
                              : Colors.grey[200]!,
                        ),
                      ),
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[900]
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue[700]!
                                  : Colors.blue[100]!,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          data["studentName"] ?? "No Name",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          data["studentEmail"] ?? "No Email",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailsScreen(
                                studentId: data["studentId"],
                                studentName: data["studentName"] ?? "No Name",
                                studentEmail:
                                    data["studentEmail"] ?? "No Email",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
