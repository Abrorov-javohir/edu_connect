// teacher_task_create_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherTaskCreateScreen extends StatefulWidget {
  const TeacherTaskCreateScreen({super.key});

  @override
  State<TeacherTaskCreateScreen> createState() => _TeacherTaskCreateScreenState();
}

class _TeacherTaskCreateScreenState extends State<TeacherTaskCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _deadline;
  String? _selectedClassId;
  List<DocumentSnapshot> _classes = [];
  bool _loading = false;

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'create_task': return "Vazifa Yaratish";
          case 'task_title': return "Vazifa Sarlavhasi";
          case 'enter_title': return "Vazifa sarlavhasini kiriting";
          case 'description': return "Tavsif";
          case 'enter_description': return "Vazifa tavsifini kiriting";
          case 'select_class': return "Sinf Tanlang";
          case 'pick_deadline': return "Muddat Tanlang";
          case 'create_task_button': return "Vazifa Yaratish";
          case 'please_select_class': return "Iltimos, sinf tanlang";
          case 'fill_all_fields': return "Iltimos, barcha maydonchalarni to'ldiring";
          case 'task_created_success': return "Vazifa muvaffaqiyatli yaratildi!";
          case 'error_creating_task': return "Vazifa yaratishda xatolik: ";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'create_task': return "Создать Задание";
          case 'task_title': return "Название Задания";
          case 'enter_title': return "Введите название задания";
          case 'description': return "Описание";
          case 'enter_description': return "Введите описание задания";
          case 'select_class': return "Выбрать Класс";
          case 'pick_deadline': return "Выбрать Срок";
          case 'create_task_button': return "Создать Задание";
          case 'please_select_class': return "Пожалуйста, выберите класс";
          case 'fill_all_fields': return "Пожалуйста, заполните все поля";
          case 'task_created_success': return "Задание успешно создано!";
          case 'error_creating_task': return "Ошибка создания задания: ";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'create_task': return "Create Task";
          case 'task_title': return "Task Title";
          case 'enter_title': return "Enter task title";
          case 'description': return "Description";
          case 'enter_description': return "Enter task description";
          case 'select_class': return "Select Class";
          case 'pick_deadline': return "Pick Deadline";
          case 'create_task_button': return "Create Task";
          case 'please_select_class': return "Please select a class";
          case 'fill_all_fields': return "Please fill all fields";
          case 'task_created_success': return "Task created successfully!";
          case 'error_creating_task': return "Error creating task: ";
          default: return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _deadline == null ||
        _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('fill_all_fields', context)),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("tasks").add({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "deadline": Timestamp.fromDate(_deadline!),
        "classId": _selectedClassId,
        "teacherId": userId,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('task_created_success', context)),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('error_creating_task', context)}$e"),
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
        title: Text(
          _getLocalizedString('create_task', context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('task_title', context),
                  hintText: _getLocalizedString('enter_title', context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('description', context),
                  hintText: _getLocalizedString('enter_description', context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Class Selection
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
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
                            ? Colors.grey[800]
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
                        setState(() => _selectedClassId = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Deadline Picker
              InkWell(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _deadline == null
                            ? _getLocalizedString('pick_deadline', context)
                            : "Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}",
                        style: GoogleFonts.poppins(
                          color: _deadline == null
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _getLocalizedString('create_task_button', context),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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