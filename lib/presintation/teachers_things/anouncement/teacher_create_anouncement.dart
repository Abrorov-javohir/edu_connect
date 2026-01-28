// create_announcement_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class AnnouncementCreateScreen extends StatefulWidget {
  const AnnouncementCreateScreen({super.key});

  @override
  State<AnnouncementCreateScreen> createState() => _AnnouncementCreateScreenState();
}

class _AnnouncementCreateScreenState extends State<AnnouncementCreateScreen> {
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
          case 'create_announcement': return "E'lon Yaratish";
          case 'title': return "Sarlavha";
          case 'enter_title': return "Sarlavhani kiriting";
          case 'content': return "Tarkib";
          case 'enter_content': return "Tarkibni kiriting";
          case 'select_class': return "Sinf Tanlang";
          case 'select_start_date': return "Boshlanish Sanasini Tanlang";
          case 'select_end_date': return "Tugash Sanasini Tanlang";
          case 'create_announcement_button': return "E'lon Yaratish";
          case 'please_fill_all_fields': return "Iltimos, barcha maydonchalarni to'ldiring";
          case 'end_date_after_start': return "Tugash sanasi boshlanish sanasidan keyin bo'lishi kerak";
          case 'announcement_created_success': return "E'lon muvaffaqiyatli yaratildi!";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'create_announcement': return "Создать Объявление";
          case 'title': return "Заголовок";
          case 'enter_title': return "Введите заголовок";
          case 'content': return "Содержание";
          case 'enter_content': return "Введите содержание";
          case 'select_class': return "Выбрать Класс";
          case 'select_start_date': return "Выбрать Дату Начала";
          case 'select_end_date': return "Выбрать Дату Окончания";
          case 'create_announcement_button': return "Создать Объявление";
          case 'please_fill_all_fields': return "Пожалуйста, заполните все поля";
          case 'end_date_after_start': return "Дата окончания должна быть после даты начала";
          case 'announcement_created_success': return "Объявление успешно создано!";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'create_announcement': return "Create Announcement";
          case 'title': return "Title";
          case 'enter_title': return "Enter title";
          case 'content': return "Content";
          case 'enter_content': return "Enter content";
          case 'select_class': return "Select Class";
          case 'select_start_date': return "Select Start Date";
          case 'select_end_date': return "Select End Date";
          case 'create_announcement_button': return "Create Announcement";
          case 'please_fill_all_fields': return "Please fill all fields";
          case 'end_date_after_start': return "End date must be after start date";
          case 'announcement_created_success': return "Announcement created successfully!";
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

  Future<void> _createAnnouncement() async {
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
      await FirebaseFirestore.instance.collection("announcements").add({
        "title": _titleController.text.trim(),
        "content": _contentController.text.trim(),
        "startDate": Timestamp.fromDate(_startDate!),
        "endDate": Timestamp.fromDate(_endDate!),
        "classId": _selectedClassId,
        "teacherId": FirebaseAuth.instance.currentUser?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('announcement_created_success')),
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
          _getLocalizedString('create_announcement'),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange[900]?.withOpacity(0.2)
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.orange[700]!
                          : Colors.orange[100]!,
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
                        _getLocalizedString('create_announcement'),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add title, content, event dates, and select class",
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
                            ? Colors.orange[300]!
                            : Colors.orange[700]!,
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
                            ? Colors.orange[300]!
                            : Colors.orange[700]!,
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
                          fillColor: Theme.of(context).brightness == Brightness.dark
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
                    leading: const Icon(Icons.event, color: Colors.orange),
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
                    leading: const Icon(Icons.event_available, color: Colors.orange),
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
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.orange[800]
                                : Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _createAnnouncement,
                          child: Text(
                            _getLocalizedString('create_announcement_button'),
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

