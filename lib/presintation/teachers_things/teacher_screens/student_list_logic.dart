// student_list_logic.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentListLogic {
  static void showAddToClassDialog(BuildContext context, String studentId, String studentName) {
    List<DocumentSnapshot> classes = [];
    String? selectedClassId;

    // Load teacher's classes
    _loadTeacherClasses().then((loadedClasses) {
      classes = loadedClasses;
      
      if (classes.isEmpty) {
        _showNoClassesDialog(context);
        return;
      }

      // Show beautiful dialog
      showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (builderContext, setState) {
              return FadeIn(
                duration: const Duration(milliseconds: 600),
                child: AlertDialog(
                  title: Text(
                    _getLocalizedString('add_to_class', context),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_getLocalizedString('select_class_for', context)} $studentName",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          value: selectedClassId,
                          hint: Text(
                            _getLocalizedString('select_class', context),
                            style: GoogleFonts.poppins(),
                          ),
                          items: classes.map((classDoc) {
                            final data = classDoc.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: classDoc.id,
                              child: Text(
                                data["className"] ?? _getLocalizedString('no_class_name', context),
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
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                      child: Text(
                        _getLocalizedString('cancel', context),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedClassId == null ? null : () async {
                        await _addStudentToClass(
                          dialogContext,
                          selectedClassId!,
                          studentId,
                          studentName,
                        );
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[800]
                            : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _getLocalizedString('add', context),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  static Future<List<DocumentSnapshot>> _loadTeacherClasses() async {
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

  static Future<void> _addStudentToClass(
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
        _showErrorDialog(context, _getLocalizedString('student_already_exists', context));
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
      final classRef = FirebaseFirestore.instance.collection("classes").doc(classId);
      final classDoc = await classRef.get();
      final currentCount = (classDoc.data()?["studentCount"] ?? 0) as int;
      await classRef.update({
        "studentCount": currentCount + 1,
      });

      _showSuccessDialog(context, studentName);
    } catch (e) {
      print("Error adding student to class: $e");
      _showErrorDialog(context, _getLocalizedString('failed_add_student', context));
    }
  }

  static void _showNoClassesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('no_classes', context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          _getLocalizedString('create_class_first', context),
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  static void _showSuccessDialog(BuildContext context, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('success', context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
        content: Text(
          "$studentName ${_getLocalizedString('added_to_class', context)}",
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('error', context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  static String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'add_to_class': return "Sinfga Qo'shish";
          case 'select_class_for': return "Quyidagi sinf uchun tanlang:";
          case 'select_class': return "Sinf Tanlang";
          case 'no_class_name': return "Nomaviy Sinf";
          case 'cancel': return "Bekor Qilish";
          case 'add': return "Qo'shish";
          case 'no_classes': return "Hech qanday sinf yo'q";
          case 'create_class_first': return "Avval sinf yarating.";
          case 'student_already_exists': return "O'quvchi allaqachon bu sinfda mavjud.";
          case 'failed_add_student': return "O'quvchini sinfga qo'shishda xato yuz berdi.";
          case 'success': return "Muvaffaqiyat";
          case 'error': return "Xato";
          case 'added_to_class': return "sinfga qo'shildi!";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'add_to_class': return "Добавить в Класс";
          case 'select_class_for': return "Выберите класс для:";
          case 'select_class': return "Выбрать Класс";
          case 'no_class_name': return "Без Названия";
          case 'cancel': return "Отмена";
          case 'add': return "Добавить";
          case 'no_classes': return "Нет классов";
          case 'create_class_first': return "Сначала создайте класс.";
          case 'student_already_exists': return "Студент уже существует в этом классе.";
          case 'failed_add_student': return "Не удалось добавить студента в класс.";
          case 'success': return "Успех";
          case 'error': return "Ошибка";
          case 'added_to_class': return "добавлен в класс!";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'add_to_class': return "Add to Class";
          case 'select_class_for': return "Select a class for:";
          case 'select_class': return "Select Class";
          case 'no_class_name': return "No Name Class";
          case 'cancel': return "Cancel";
          case 'add': return "Add";
          case 'no_classes': return "No Classes";
          case 'create_class_first': return "Create a class first.";
          case 'student_already_exists': return "Student already exists in this class.";
          case 'failed_add_student': return "Failed to add student to class.";
          case 'success': return "Success";
          case 'error': return "Error";
          case 'added_to_class': return "has been added to the class!";
          default: return key;
        }
    }
  }
}