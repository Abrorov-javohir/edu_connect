// screens/teacher_students_list_screen.dart (Beautiful UI with Add to Class Feature)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/student_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/students_state.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherStudentsListScreen extends StatefulWidget {
  const TeacherStudentsListScreen({super.key});

  @override
  State<TeacherStudentsListScreen> createState() =>
      _TeacherStudentsListScreenState();
}

class _TeacherStudentsListScreenState extends State<TeacherStudentsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentsCubit>().loadStudents();
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'students':
            return "O'quvchilar";
          case 'no_students_found':
            return "Hech qanday o'quvchi topilmadi";
          case 'unknown_student':
            return "Noma'lum O'quvchi";
          case 'view_details':
            return "Tafsilotlarni Ko'rish";
          case 'add_to_class':
            return "Sinfga Qo'shish";
          case 'loading_students':
            return "O'quvchilar yuklanmoqda...";
          case 'error_loading':
            return "Yuklashda xato: ";
          case 'student_name':
            return "O'quvchi Ismi";
          case 'email':
            return "Elektron pochta";
          case 'select_class':
            return "Sinf Tanlang";
          case 'add_student':
            return "O'quvchini Qo'shish";
          case 'student_added_success':
            return "O'quvchi muvaffaqiyatli qo'shildi!";
          case 'student_already_exists':
            return "O'quvchi allaqachon bu sinfda mavjud";
          case 'no_classes_available':
            return "Hech qanday sinf mavjud emas";
          case 'create_class_first':
            return "Avval sinf yarating";
          case 'success':
            return "Muvaffaqiyat";
          case 'error':
            return "Xato";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'teacher_students':
            return "Ученики";
          case 'no_students_found':
            return "Студенты не найдены";
          case 'unknown_student':
            return "Неизвестный Студент";
          case 'view_details':
            return "Просмотреть Детали";
          case 'add_to_class':
            return "Добавить в Класс";
          case 'loading_students':
            return "Загрузка студентов...";
          case 'error_loading':
            return "Ошибка загрузки: ";
          case 'student_name':
            return "Имя студента";
          case 'email':
            return "Электронная почта";
          case 'select_class':
            return "Выбрать Класс";
          case 'add_student':
            return "Добавить Студента";
          case 'student_added_success':
            return "Студент успешно добавлен!";
          case 'student_already_exists':
            return "Студент уже существует в этом классе";
          case 'no_classes_available':
            return "Нет доступных классов";
          case 'create_class_first':
            return "Сначала создайте класс";
          case 'success':
            return "Успех";
          case 'error':
            return "Ошибка";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'students':
            return "Students";
          case 'no_students_found':
            return "No students found";
          case 'unknown_student':
            return "Unknown Student";
          case 'view_details':
            return "View Details";
          case 'add_to_class':
            return "Add to Class";
          case 'loading_students':
            return "Loading students...";
          case 'error_loading':
            return "Error loading: ";
          case 'student_name':
            return "Student Name";
          case 'email':
            return "Email";
          case 'select_class':
            return "Select Class";
          case 'add_student':
            return "Add Student";
          case 'student_added_success':
            return "Student added successfully!";
          case 'student_already_exists':
            return "Student already exists in this class";
          case 'no_classes_available':
            return "No classes available";
          case 'create_class_first':
            return "Create a class first";
          case 'success':
            return "Success";
          case 'error':
            return "Error";
          default:
            return key;
        }
    }
  }

  // Method to show Add to Class dialog
  void _showAddToClassDialog(String studentId, String studentName) {
    List<DocumentSnapshot> classes = [];
    String? selectedClassId;

    _loadTeacherClasses().then((loadedClasses) {
      classes = loadedClasses;

      if (classes.isEmpty) {
        _showNoClassesDialog(context);
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext builderContext, StateSetter setState) {
              return AlertDialog(
                title: Text(
                  _getLocalizedString('add_to_class'),
                  style: GoogleFonts.poppins(),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${_getLocalizedString('select_class_for')} $studentName",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: selectedClassId,
                      hint: Text(
                        _getLocalizedString('select_class'),
                        style: GoogleFonts.poppins(),
                      ),
                      items: classes.map((classDoc) {
                        final data = classDoc.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: classDoc.id,
                          child: Text(
                            data["className"] ?? "No Name",
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClassId = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      _getLocalizedString('cancel'),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedClassId == null
                        ? null
                        : () async {
                            await _addStudentToClass(
                              dialogContext,
                              selectedClassId!,
                              studentId,
                              studentName,
                            );
                            Navigator.pop(dialogContext);
                            _showSuccessDialog(dialogContext, studentName);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[800]
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _getLocalizedString('add_student'),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  Future<List<DocumentSnapshot>> _loadTeacherClasses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      final classesSnapshot = await FirebaseFirestore.instance
          .collection("classes")
          .where("teacherId", isEqualTo: userId)
          .get();

      return classesSnapshot.docs;
    } catch (e) {
      print("Error loading classes: $e");
      return [];
    }
  }

  Future<void> _addStudentToClass(
    BuildContext context,
    String classId,
    String studentId,
    String studentName,
  ) async {
    try {
      // Check if student is already in class
      final existingStudent = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("classId", isEqualTo: classId)
          .where("studentId", isEqualTo: studentId)
          .get();

      if (existingStudent.docs.isNotEmpty) {
        _showErrorDialog(
          context,
          _getLocalizedString('student_already_exists'),
        );
        return;
      }

      // Add student to class
      await FirebaseFirestore.instance.collection("classStudents").add({
        "classId": classId,
        "studentId": studentId,
        "studentName": studentName,
        "studentEmail": "", // You can get this from student doc if needed
        "joinedAt": FieldValue.serverTimestamp(),
      });

      // Update student count in class
      final classRef = FirebaseFirestore.instance
          .collection("classes")
          .doc(classId);
      final classDoc = await classRef.get();
      final currentCount = (classDoc.data()?["studentCount"] ?? 0) as int;
      await classRef.update({"studentCount": currentCount + 1});
    } catch (e) {
      print("Error adding student to class: $e");
      _showErrorDialog(context, "Failed to add student to class");
    }
  }

  void _showNoClassesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedString('error'), style: GoogleFonts.poppins()),
        content: Text(
          _getLocalizedString('no_classes_available'),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('success'),
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          "$studentName ${_getLocalizedString('student_added_success')}",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedString('error'), style: GoogleFonts.poppins()),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          _getLocalizedString('students'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<StudentsCubit, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        Icons.school,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('loading_students'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StudentsError) {
            return Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[900]?.withOpacity(0.2)
                            : Colors.red[50],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.red[700]!
                              : Colors.red[200]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.red
                                        : Colors.red)
                                    .withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[300]
                            : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "${_getLocalizedString('error_loading')} ${state.error}",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StudentsLoaded) {
            final students = state.students;

            if (students.isEmpty) {
              return Center(
                child: FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[50],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getLocalizedString('no_students_found'),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "You'll be able to see your students here once they join your classes.",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final data = student.data() as Map<String, dynamic>;

                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  duration: const Duration(milliseconds: 600),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue[900]?.withOpacity(0.2)
                                  : Colors.blue[50],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[700]!
                                    : Colors.blue[100]!,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"] ??
                                      _getLocalizedString('unknown_student'),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data["email"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ADD TO CLASS BUTTON
                          ElevatedButton(
                            onPressed: () {
                              _showAddToClassDialog(
                                student.id,
                                data["name"] ?? "Unknown Student",
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.green[800]
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _getLocalizedString('add_to_class'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
