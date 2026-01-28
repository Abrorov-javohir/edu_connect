// teacher_classes_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/class_student_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  List<DocumentSnapshot> _allClasses = [];
  List<DocumentSnapshot> _filteredClasses = [];
  String _searchQuery = '';
  bool _loading = true;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'my_classes':
            return "Mening Sinfim";
          case 'search_classes':
            return "Sinf qidirish...";
          case 'no_classes_created':
            return "Hali hech qanday sinf yaratilmagan";
          case 'create_new_class':
            return "Yangi Sinf Yaratish";
          case 'enter_class_name':
            return "Sinf nomini kiriting";
          case 'cancel':
            return "Bekor Qilish";
          case 'create':
            return "Yaratish";
          case 'students':
            return "o'quvchi";
          case 'add_class':
            return "Sinf Qo'shish";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'teacher_classes':
            return "Мои Классы";
          case 'search_classes':
            return "Поиск классов...";
          case 'no_classes_created':
            return "Классы еще не созданы";
          case 'create_new_class':
            return "Создать Новый Класс";
          case 'enter_class_name':
            return "Введите название класса";
          case 'cancel':
            return "Отмена";
          case 'create':
            return "Создать";
          case 'students':
            return "учащихся";
          case 'add_class':
            return "Добавить Класс";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'my_classes':
            return "My Classes";
          case 'search_classes':
            return "Search classes...";
          case 'no_classes_created':
            return "No classes created yet";
          case 'create_new_class':
            return "Create New Class";
          case 'enter_class_name':
            return "Enter class name";
          case 'cancel':
            return "Cancel";
          case 'create':
            return "Create";
          case 'students':
            return "students";
          case 'add_class':
            return "Add Class";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final classesSnapshot = await FirebaseFirestore.instance
          .collection("classes")
          .where("teacherId", isEqualTo: userId)
          .get();

      setState(() {
        _allClasses = classesSnapshot.docs;
        _filteredClasses = classesSnapshot.docs;
        _loading = false;
      });
    } catch (e) {
      print("Error loading classes: $e");
      setState(() => _loading = false);
    }
  }

  void _createClassDialog() {
    final classNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedString('create_new_class'),
          style: GoogleFonts.poppins(),
        ),
        content: TextField(
          controller: classNameController,
          decoration: InputDecoration(
            hintText: _getLocalizedString('enter_class_name'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getLocalizedString('cancel'),
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (classNameController.text.trim().isNotEmpty && mounted) {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  await FirebaseFirestore.instance.collection("classes").add({
                    "className": classNameController.text.trim(),
                    "teacherId": userId,
                    "studentCount": 0,
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  // Close dialog and refresh
                  Navigator.pop(context);
                  _loadClasses();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              _getLocalizedString('create'),
              style: GoogleFonts.poppins(),
            ),
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
        title: Text(
          _getLocalizedString('my_classes'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createClassDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    if (value.isEmpty) {
                      _filteredClasses = _allClasses;
                    } else {
                      _filteredClasses = _allClasses.where((classDoc) {
                        final data = classDoc.data() as Map<String, dynamic>;
                        return (data["className"] as String?)
                                ?.toLowerCase()
                                .contains(value.toLowerCase()) ??
                            false;
                      }).toList();
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: _getLocalizedString('search_classes'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Classes List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClasses.isEmpty
                  ? Center(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
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
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.class_,
                                size: 64,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[300]
                                    : Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _getLocalizedString('no_classes_created'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredClasses.length,
                      itemBuilder: (context, index) {
                        final classDoc = _filteredClasses[index];
                        final data = classDoc.data() as Map<String, dynamic>;

                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          duration: const Duration(milliseconds: 600),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!,
                              ),
                            ),
                            elevation: 0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
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
                                child: Icon(
                                  Icons.class_,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[300]
                                      : Colors.blue[700],
                                ),
                              ),
                              title: Text(
                                data["className"] ?? "No Name",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                "${data["studentCount"] ?? 0} ${_getLocalizedString('students')}",
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
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeacherClassStudentsScreen(
                                      classId: classDoc.id,
                                      className: data["className"] ?? "No Name",
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
          ],
        ),
      ),
    );
  }
}
