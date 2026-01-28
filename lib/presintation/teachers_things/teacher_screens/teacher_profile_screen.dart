// teacher_profile_screen.dart (Beautiful UI with Settings)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_classes_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/settings/teacher_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'teacher_profile_edit_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    String _getLocalizedString(String key) {
      final language = context.read<LanguageProvider>().currentLanguage;
      switch (language) {
        case 'uz':
          switch (key) {
            case 'teacher_profile':
              return "O'qituvchi Profili";
            case 'email':
              return "Elektron pochta";
            case 'phone':
              return "Telefon";
            case 'role':
              return "Rol";
            case 'manage_classes':
              return "Sinfni Boshqarish";
            case 'edit_profile':
              return "Profilni Tahrirlash";
            case 'settings':
              return "Sozlamalar";
            case 'logout':
              return "Chiqish";
            case 'logging_out':
              return "Chiqish...";
            case 'logout_failed':
              return "Chiqish amalga oshmadi: ";
            case 'confirm_logout':
              return "Chiqishni Tasdiqlang";
            case 'logout_confirm_message':
              return "Haqiqatan ham chiqishni xohlaysizmi?";
            case 'cancel':
              return "Bekor Qilish";
            case 'logout_button':
              return "Chiqish";
            default:
              return key;
          }
        case 'ru':
          switch (key) {
            case 'teacher_profile':
              return "Профиль Учителя";
            case 'email':
              return "Электронная почта";
            case 'phone':
              return "Телефон";
            case 'role':
              return "Роль";
            case 'manage_classes':
              return "Управление Классами";
            case 'edit_profile':
              return "Редактировать Профиль";
            case 'settings':
              return "Настройки";
            case 'logout':
              return "Выйти";
            case 'logging_out':
              return "Выход...";
            case 'logout_failed':
              return "Выход не удался: ";
            case 'confirm_logout':
              return "Подтвердить Выход";
            case 'logout_confirm_message':
              return "Вы уверены, что хотите выйти?";
            case 'cancel':
              return "Отмена";
            case 'logout_button':
              return "Выйти";
            default:
              return key;
          }
        case 'en':
        default:
          switch (key) {
            case 'teacher_profile':
              return "Teacher Profile";
            case 'email':
              return "Email";
            case 'phone':
              return "Phone";
            case 'role':
              return "Role";
            case 'manage_classes':
              return "Manage Classes";
            case 'edit_profile':
              return "Edit Profile";
            case 'settings':
              return "Settings";
            case 'logout':
              return "Log out";
            case 'logging_out':
              return "Logging out...";
            case 'logout_failed':
              return "Logout failed: ";
            case 'confirm_logout':
              return "Confirm Logout";
            case 'logout_confirm_message':
              return "Are you sure you want to log out?";
            case 'cancel':
              return "Cancel";
            case 'logout_button':
              return "Logout";
            default:
              return key;
          }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _getLocalizedString('teacher_profile'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const TeacherSettingsScreen(), // Changed to teacher settings
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No profile data found",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final fullName = data["name"] ?? data["fullName"] ?? "No Name";
          final phone = data["phone"] ?? "No Phone";
          final email = data["email"] ?? "";
          final imageUrl =
              data["imageUrl"] ??
              "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"; // Fixed URL

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(imageUrl),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      "Teacher",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 600),
                    child: _buildInfoCard(
                      context,
                      _getLocalizedString('email'),
                      email,
                      Icons.email_outlined,
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: _buildInfoCard(
                      context,
                      _getLocalizedString('phone'),
                      phone,
                      Icons.phone_outlined,
                    ),
                  ),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: _buildInfoCard(
                      context,
                      _getLocalizedString('role'),
                      "Teacher",
                      Icons.person_outlined,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // MANAGE CLASSES BUTTON
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherClassesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.class_outlined),
                        label: Text(
                          _getLocalizedString('manage_classes'),
                          style: GoogleFonts.poppins(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.green[800]
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeacherEditScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(
                          _getLocalizedString('edit_profile'),
                          style: GoogleFonts.poppins(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[800]
                              : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherSettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: Text(
                          _getLocalizedString('settings'),
                          style: GoogleFonts.poppins(),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                          ),
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ✅ FIXED LOGOUT BUTTON
                  FadeInUp(
                    delay: const Duration(milliseconds: 900),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  _getLocalizedString('confirm_logout'),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: Text(
                                  _getLocalizedString('logout_confirm_message'),
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      _getLocalizedString('cancel'),
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.red[800]
                                          : Colors.red[700],
                                    ),
                                    child: Text(
                                      _getLocalizedString('logout_button'),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Show immediate feedback without blocking
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _getLocalizedString('logging_out'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[800]
                                      : Colors.blue,
                                ),
                              );

                              // Perform logout
                              await FirebaseAuth.instance.signOut();

                              // Navigate to login screen immediately after logout
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${_getLocalizedString('logout_failed')}$e",
                                ),
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.red[800]
                                    : Colors.red[700],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(
                          _getLocalizedString('logout'),
                          style: GoogleFonts.poppins(),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.red[600]!
                                : Colors.red.shade400!,
                          ),
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.red[400]
                              : Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
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
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey.shade200,
        ),
      ),
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}
