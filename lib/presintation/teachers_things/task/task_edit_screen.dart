// teacher_task_edit_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherTaskEditScreen extends StatefulWidget {
  final String taskId;

  const TeacherTaskEditScreen({super.key, required this.taskId});

  @override
  State<TeacherTaskEditScreen> createState() => _TeacherTaskEditScreenState();
}

class _TeacherTaskEditScreenState extends State<TeacherTaskEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _deadline;
  String? _selectedClassId;
  List<DocumentSnapshot> _classes = [];
  bool _loading = true;
  bool _saving = false;

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'edit_task': return "Vazifani Tahrirlash";
          case 'task_title': return "Vazifa Sarlavhasi";
          case 'enter_title': return "Vazifa sarlavhasini kiriting";
          case 'description': return "Tavsif";
          case 'enter_description': return "Vazifa tavsifini kiriting";
          case 'select_class': return "Sinf Tanlang";
          case 'pick_deadline': return "Muddat Tanlang";
          case 'save_changes': return "O'zgarishlarni Saqlash";
          case 'please_select_class': return "Iltimos, sinf tanlang";
          case 'fill_all_fields': return "Iltimos, barcha maydonchalarni to'ldiring";
          case 'task_updated_success': return "Vazifa muvaffaqiyatli yangilandi!";
          case 'error_updating_task': return "Vazifani yangilashda xatolik: ";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'edit_task': return "Редактировать Задание";
          case 'task_title': return "Название Задания";
          case 'enter_title': return "Введите название задания";
          case 'description': return "Описание";
          case 'enter_description': return "Введите описание задания";
          case 'select_class': return "Выбрать Класс";
          case 'pick_deadline': return "Выбрать Срок";
          case 'save_changes': return "Сохранить Изменения";
          case 'please_select_class': return "Пожалуйста, выберите класс";
          case 'fill_all_fields': return "Пожалуйста, заполните все поля";
          case 'task_updated_success': return "Задание успешно обновлено!";
          case 'error_updating_task': return "Ошибка обновления задания: ";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'edit_task': return "Edit Task";
          case 'task_title': return "Task Title";
          case 'enter_title': return "Enter task title";
          case 'description': return "Description";
          case 'enter_description': return "Enter task description";
          case 'select_class': return "Select Class";
          case 'pick_deadline': return "Pick Deadline";
          case 'save_changes': return "Save Changes";
          case 'please_select_class': return "Please select a class";
          case 'fill_all_fields': return "Please fill all fields";
          case 'task_updated_success': return "Task updated successfully!";
          case 'error_updating_task': return "Error updating task: ";
          default: return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTask();
    _loadClasses();
  }

  Future<void> _loadTask() async {
    try {
      final taskDoc = await FirebaseFirestore.instance
          .collection("tasks")
          .doc(widget.taskId)
          .get();

      if (taskDoc.exists) {
        final data = taskDoc.data() as Map<String, dynamic>;
        _titleController.text = data["title"] ?? "";
        _descriptionController.text = data["description"] ?? "";
        _deadline = (data["deadline"] as Timestamp?)?.toDate();
        _selectedClassId = data["classId"];
      }
    } catch (e) {
      print("Error loading task: $e");
    } finally {
      setState(() => _loading = false);
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  Future<void> _saveTask() async {
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

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("tasks")
          .doc(widget.taskId)
          .update({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "deadline": Timestamp.fromDate(_deadline!),
        "classId": _selectedClassId,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('task_updated_success', context)),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('error_updating_task', context)}$e"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getLocalizedString('edit_task', context),
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

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _getLocalizedString('save_changes', context),
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

