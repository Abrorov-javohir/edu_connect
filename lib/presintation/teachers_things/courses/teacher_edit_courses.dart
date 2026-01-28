// course_edit_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class CourseEditScreen extends StatefulWidget {
  final String courseId;

  const CourseEditScreen({super.key, required this.courseId});

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  String? _selectedClassId;
  List<DocumentSnapshot> _classes = [];
  bool _loading = false;

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'edit_course': return "Fanni Tahrirlash";
          case 'course_name': return "Fan Nomi";
          case 'enter_course_name': return "Fan nomini kiriting";
          case 'room_number': return "Xona Raqami";
          case 'enter_room_number': return "Xona raqamini kiriting";
          case 'select_class': return "Sinf Tanlang";
          case 'update_course': return "Fanni Yangilash";
          case 'please_fill_all_fields': return "Iltimos, barcha maydonchalarni to'ldiring";
          case 'course_updated_success': return "Fan muvaffaqiyatli yangilandi!";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'edit_course': return "Редактировать Курс";
          case 'course_name': return "Название Курса";
          case 'enter_course_name': return "Введите название курса";
          case 'room_number': return "Номер Комнаты";
          case 'enter_room_number': return "Введите номер комнаты";
          case 'select_class': return "Выбрать Класс";
          case 'update_course': return "Обновить Курс";
          case 'please_fill_all_fields': return "Пожалуйста, заполните все поля";
          case 'course_updated_success': return "Курс успешно обновлен!";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'edit_course': return "Edit Course";
          case 'course_name': return "Course Name";
          case 'enter_course_name': return "Enter course name";
          case 'room_number': return "Room Number";
          case 'enter_room_number': return "Enter room number";
          case 'select_class': return "Select Class";
          case 'update_course': return "Update Course";
          case 'please_fill_all_fields': return "Please fill all fields";
          case 'course_updated_success': return "Course updated successfully!";
          default: return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCourse();
    _loadClasses();
  }

  Future<void> _loadCourse() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.courseId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data["courseName"] ?? "";
        _roomController.text = data["roomNumber"] ?? "";
        _selectedClassId = data["classId"];
      }
    } catch (e) {
      print("Error loading course: $e");
    }
  }

  Future<void> _loadClasses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final classesSnapshot = await FirebaseFirestore.instance
          .collection("classes")
          .where("teacherId", isEqualTo: userId)
          .get();

      setState(() {
        _classes = classesSnapshot.docs;
      });
    } catch (e) {
      print("Error loading classes: $e");
    }
  }

  Future<void> _updateCourse() async {
    if (_nameController.text.trim().isEmpty ||
        _roomController.text.trim().isEmpty ||
        _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('please_fill_all_fields', context)),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.courseId)
          .update({
        "courseName": _nameController.text.trim(),
        "roomNumber": _roomController.text.trim(),
        "classId": _selectedClassId,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('course_updated_success', context)),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
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
          _getLocalizedString('edit_course', context),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.blue[100]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedString('edit_course', context),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Update course name, room number, and class",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('course_name', context),
                  hintText: _getLocalizedString('enter_course_name', context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[300]!
                          : Colors.blue[700]!,
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('room_number', context),
                  hintText: _getLocalizedString('enter_room_number', context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[300]!
                          : Colors.blue[700]!,
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              // CLASS SELECTION
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedString('select_class', context),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[50],
                      ),
                      value: _selectedClassId,
                      hint: Text(
                        _getLocalizedString('select_class', context),
                        style: GoogleFonts.poppins(),
                      ),
                      items: _classes.map((classDoc) {
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
                          _selectedClassId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[800]
                              : Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _updateCourse,
                        child: Text(
                          _getLocalizedString('update_course', context),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}