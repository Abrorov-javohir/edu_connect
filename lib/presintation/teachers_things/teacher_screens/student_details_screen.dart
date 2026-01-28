// student_detail_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentEmail;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          _getLocalizedString('student_details'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
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
                      ),
                      child: Icon(
                        Icons.person_off,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[300]
                            : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('student_not_found'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.studentName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Student",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Student Information
                  Text(
                    _getLocalizedString('student_information'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    Icons.person,
                    _getLocalizedString('name'),
                    widget.studentName,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.email,
                    _getLocalizedString('email'),
                    widget.studentEmail,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.phone,
                    _getLocalizedString('phone'),
                    data["phone"] ?? _getLocalizedString('not_provided'),
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.school,
                    _getLocalizedString('grade'),
                    data["grade"] ?? _getLocalizedString('not_set'),
                    Colors.purple,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? color.withOpacity(0.3)
                      : color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'student_details':
            return "O'quvchi Tafsilotlari";
          case 'student_not_found':
            return "O'quvchi topilmadi";
          case 'student_information':
            return "O'quvchi Haqida Ma'lumot";
          case 'name':
            return "Ism";
          case 'email':
            return "Elektron pochta";
          case 'phone':
            return "Telefon";
          case 'grade':
            return "Sinf";
          case 'not_provided':
            return "Berilmagan";
          case 'not_set':
            return "O'rnatilmagan";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'student_details':
            return "Детали Студента";
          case 'student_not_found':
            return "Студент не найден";
          case 'student_information':
            return "Информация о Студенте";
          case 'name':
            return "Имя";
          case 'email':
            return "Электронная почта";
          case 'phone':
            return "Телефон";
          case 'grade':
            return "Класс";
          case 'not_provided':
            return "Не указано";
          case 'not_set':
            return "Не установлено";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'student_details':
            return "Student Details";
          case 'student_not_found':
            return "Student not found";
          case 'student_information':
            return "Student Information";
          case 'name':
            return "Name";
          case 'email':
            return "Email";
          case 'phone':
            return "Phone";
          case 'grade':
            return "Grade";
          case 'not_provided':
            return "Not provided";
          case 'not_set':
            return "Not set";
          default:
            return key;
        }
    }
  }
}
