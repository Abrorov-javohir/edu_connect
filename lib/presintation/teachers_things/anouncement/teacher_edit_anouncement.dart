// teacher_announcement_edit_screen.dart (Fixed with Beautiful UI)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherAnnouncementEditScreen extends StatefulWidget {
  final String announcementId;

  const TeacherAnnouncementEditScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<TeacherAnnouncementEditScreen> createState() =>
      _TeacherAnnouncementEditScreenState();
}

class _TeacherAnnouncementEditScreenState
    extends State<TeacherAnnouncementEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedClassId;
  List<DocumentSnapshot> _classes = [];
  bool _loading = false;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'edit_announcement':
            return "E'lonni Tahrirlash";
          case 'title':
            return "Sarlavha";
          case 'enter_title':
            return "Sarlavhani kiriting";
          case 'content':
            return "Tarkib";
          case 'enter_content':
            return "Tarkibni kiriting";
          case 'select_class':
            return "Sinf Tanlang";
          case 'select_start_date':
            return "Boshlanish Sanasini Tanlang";
          case 'select_end_date':
            return "Tugash Sanasini Tanlang";
          case 'update_announcement':
            return "E'lonni Yangilash";
          case 'please_fill_all_fields':
            return "Iltimos, barcha maydonchalarni to'ldiring";
          case 'end_date_after_start':
            return "Tugash sanasi boshlanish sanasidan keyin bo'lishi kerak";
          case 'announcement_updated_success':
            return "E'lon muvaffaqiyatli yangilandi!";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'edit_announcement':
            return "Редактировать Объявление";
          case 'title':
            return "Заголовок";
          case 'enter_title':
            return "Введите заголовок";
          case 'content':
            return "Содержание";
          case 'enter_content':
            return "Введите содержание";
          case 'select_class':
            return "Выбрать Класс";
          case 'select_start_date':
            return "Выбрать Дату Начала";
          case 'select_end_date':
            return "Выбрать Дату Окончания";
          case 'update_announcement':
            return "Обновить Объявление";
          case 'please_fill_all_fields':
            return "Пожалуйста, заполните все поля";
          case 'end_date_after_start':
            return "Дата окончания должна быть после даты начала";
          case 'announcement_updated_success':
            return "Объявление успешно обновлено!";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'edit_announcement':
            return "Edit Announcement";
          case 'title':
            return "Title";
          case 'enter_title':
            return "Enter title";
          case 'content':
            return "Content";
          case 'enter_content':
            return "Enter content";
          case 'select_class':
            return "Select Class";
          case 'select_start_date':
            return "Select Start Date";
          case 'select_end_date':
            return "Select End Date";
          case 'update_announcement':
            return "Update Announcement";
          case 'please_fill_all_fields':
            return "Please fill all fields";
          case 'end_date_after_start':
            return "End date must be after start date";
          case 'announcement_updated_success':
            return "Announcement updated successfully!";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
    _loadClasses();
  }

  Future<void> _loadAnnouncement() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("announcements")
          .doc(widget.announcementId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _titleController.text = data["title"] ?? "";
        _contentController.text = data["content"] ?? "";
        _startDate = (data["startDate"] as Timestamp?)?.toDate();
        _endDate = (data["endDate"] as Timestamp?)?.toDate();
        _selectedClassId = data["classId"];
      }
    } catch (e) {
      print("Error loading announcement: $e");
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

  Future<void> _updateAnnouncement() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('please_fill_all_fields')),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    // Validate date range
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('end_date_after_start')),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection("announcements")
          .doc(widget.announcementId)
          .update({
            "title": _titleController.text.trim(),
            "content": _contentController.text.trim(),
            "startDate": Timestamp.fromDate(_startDate!),
            "endDate": Timestamp.fromDate(_endDate!),
            "classId": _selectedClassId,
            "updatedAt": FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('announcement_updated_success')),
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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Automatically set end date to start date if not set
        if (_endDate == null) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
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
          _getLocalizedString('edit_announcement'),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFF4A6CF7),
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF42A5F5)
                            : const Color(0xFF6C8CFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue
                                    : Colors.blue)
                                .withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedString('edit_announcement'),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Update your announcement details and class",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _getLocalizedString('title'),
                    hintText: _getLocalizedString('enter_title'),
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
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: _getLocalizedString('content'),
                    hintText: _getLocalizedString('enter_content'),
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
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedString('select_class'),
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
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[50],
                        ),
                        value: _selectedClassId,
                        hint: Text(
                          _getLocalizedString('select_class'),
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
                const SizedBox(height: 16),
                // Start Date Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event, color: Colors.blue),
                    title: Text(
                      _startDate != null
                          ? "Start: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                          : _getLocalizedString('select_start_date'),
                      style: GoogleFonts.poppins(
                        color: _startDate != null
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                      ),
                    ),
                    onTap: _selectStartDate,
                  ),
                ),
                const SizedBox(height: 16),
                // End Date Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_available,
                      color: Colors.blue,
                    ),
                    title: Text(
                      _endDate != null
                          ? "End: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                          : _getLocalizedString('select_end_date'),
                      style: GoogleFonts.poppins(
                        color: _endDate != null
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                      ),
                    ),
                    onTap: _selectEndDate,
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
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[800]
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _updateAnnouncement,
                          child: Text(
                            _getLocalizedString('update_announcement'),
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
      ),
    );
  }
}
