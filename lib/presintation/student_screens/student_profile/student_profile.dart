// screens/student_profile_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:edu_connect/presintation/student_screens/settings/settings_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_classes_section.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_profile_edit_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_all_classes_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final StudentStatsService _statsService = StudentStatsService();
  StudentStats? _stats;
  bool _loadingStats = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'profile':
            return "Profil";
          case 'not_logged_in':
            return "Kirilmagan";
          case 'login':
            return "Kirish";
          case 'no_profile_data':
            return "Profil ma'lumotlari topilmadi";
          case 'points':
            return "Ballar";
          case 'streak':
            return "Seriya";
          case 'days':
            return "kun";
          case 'tasks':
            return "Vazifalar";
          case 'rank':
            return "Reyting";
          case 'task_progress':
            return "Vazifa Rivoji";
          case 'completed':
            return "bajarildi";
          case 'total':
            return "jami";
          case 'email':
            return "Elektron pochta";
          case 'grade':
            return "Sinf";
          case 'phone':
            return "Telefon";
          case 'edit_profile':
            return "Profilni Tahrirlash";
          case 'logout':
            return "Chiqish";
          case 'confirm_logout':
            return "Chiqishni Tasdiqlang";
          case 'logout_confirm_message':
            return "Haqiqatan ham chiqishni xohlaysizmi?";
          case 'cancel':
            return "Bekor Qilish";
          case 'logout_button':
            return "Chiqish";
          case 'logout_failed':
            return "Chiqish amalga oshmadi: ";
          case 'view_all_classes':
            return "Barcha Sinfni Ko'rish";
          case 'logging_out':
            return "Chiqish...";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'profile':
            return "Профиль";
          case 'not_logged_in':
            return "Не вошел в систему";
          case 'login':
            return "Войти";
          case 'no_profile_data':
            return "Данные профиля не найдены";
          case 'points':
            return "Баллы";
          case 'streak':
            return "Серия";
          case 'days':
            return "дни";
          case 'tasks':
            return "Задания";
          case 'rank':
            return "Ранг";
          case 'task_progress':
            return "Прогресс Заданий";
          case 'completed':
            return "выполнено";
          case 'total':
            return "всего";
          case 'email':
            return "Электронная почта";
          case 'grade':
            return "Класс";
          case 'phone':
            return "Телефон";
          case 'edit_profile':
            return "Редактировать Профиль";
          case 'logout':
            return "Выйти";
          case 'confirm_logout':
            return "Подтвердить Выход";
          case 'logout_confirm_message':
            return "Вы уверены, что хотите выйти?";
          case 'cancel':
            return "Отмена";
          case 'logout_button':
            return "Выйти";
          case 'logout_failed':
            return "Выход не удался: ";
          case 'view_all_classes':
            return "Посмотреть Все Классы";
          case 'logging_out':
            return "Выход...";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'profile':
            return "Profile";
          case 'not_logged_in':
            return "Not logged in";
          case 'login':
            return "Login";
          case 'no_profile_data':
            return "No profile data found";
          case 'points':
            return "Points";
          case 'streak':
            return "Streak";
          case 'days':
            return "days";
          case 'tasks':
            return "Tasks";
          case 'rank':
            return "Rank";
          case 'task_progress':
            return "Task Progress";
          case 'completed':
            return "completed";
          case 'total':
            return "total";
          case 'email':
            return "Email";
          case 'grade':
            return "Grade";
          case 'phone':
            return "Phone";
          case 'edit_profile':
            return "Edit Profile";
          case 'logout':
            return "Log out";
          case 'confirm_logout':
            return "Confirm Logout";
          case 'logout_confirm_message':
            return "Are you sure you want to log out?";
          case 'cancel':
            return "Cancel";
          case 'logout_button':
            return "Logout";
          case 'logout_failed':
            return "Logout failed: ";
          case 'view_all_classes':
            return "View All Classes";
          case 'logging_out':
            return "Logging out...";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              _loadStats();
            }
          });
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && mounted) {
      setState(() => _loadingStats = true);
      try {
        final stats = await _statsService.getStudentStats(uid);
        if (mounted) {
          setState(() {
            _stats = stats;
            _loadingStats = false;
          });
        }
      } catch (e) {
        print("Error loading stats: $e");
        if (mounted) {
          setState(() => _loadingStats = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
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
                    Icons.error,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red[400]
                        : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _getLocalizedString('not_logged_in'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (Route<dynamic> route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[800]
                        : Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_getLocalizedString('login')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _getLocalizedString('profile'),
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
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[400]
                      : Colors.blue,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
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
                      _getLocalizedString('no_profile_data'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final fullName = data["name"] ?? data["displayName"] ?? "Student";
            final email = data["email"] ?? "";
            final phone = data["phone"] ?? "Not provided";
            final grade = data["grade"] ?? "Not set";
            final role = data["role"] ?? "student";
            final imageUrl =
                data["imageUrl"]?.toString() ??
                "https://images.icon-icons.com/2643/PNG/512/male_man_people_person_avatar_white_tone_icon_159363.png";

            return CustomScrollView(
              slivers: [
                // ===== SECTION 1: PROFILE HEADER WITH ELEVATED PICTURE =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 60),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[800]
                                    : Colors.blue[600],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== SECTION 2: STUDENT IDENTITY =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            role == "teacher" ? "Teacher" : grade,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), // Section separator
                      ],
                    ),
                  ),
                ),

                // ===== SECTION 3: CLASSES =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          child: StudentClassesSection(context: context),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StudentAllClassesScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.class_outlined, size: 20),
                              label: Text(
                                _getLocalizedString('view_all_classes'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[800]
                                    : Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), // Section separator
                      ],
                    ),
                  ),
                ),

                // ===== SECTION 4: STATS CARDS =====
                if (!_loadingStats)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 600),
                            child: Row(
                              children: [
                                _statCard(
                                  _getLocalizedString('points'),
                                  "${_stats?.totalPoints ?? 0}",
                                  Icons.star,
                                  Colors.orange[700]!,
                                ),
                                const SizedBox(width: 16),
                                _statCard(
                                  _getLocalizedString('streak'),
                                  "${_stats?.currentStreak ?? 0} ${_getLocalizedString('days')}",
                                  Icons.local_fire_department,
                                  Colors.red[700]!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            duration: const Duration(milliseconds: 600),
                            child: Row(
                              children: [
                                _statCard(
                                  _getLocalizedString('tasks'),
                                  "${_stats?.completedTasks ?? 0}/${_stats?.totalTasks ?? 1}",
                                  Icons.check_circle,
                                  Colors.green[700]!,
                                ),
                                const SizedBox(width: 16),
                                _statCard(
                                  _getLocalizedString('rank'),
                                  "#${_stats?.classRank ?? '--'}",
                                  Icons.leaderboard,
                                  Colors.blue[700]!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32), // Section separator
                        ],
                      ),
                    ),
                  ),

                // ===== SECTION 5: PROGRESS BAR =====
                if (!_loadingStats)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        duration: const Duration(milliseconds: 600),
                        child: _progressCard(),
                      ),
                    ),
                  ),

                // ===== SECTION 6: INFO CARDS =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          duration: const Duration(milliseconds: 600),
                          child: _infoCard(
                            _getLocalizedString('email'),
                            email,
                            Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 650),
                          duration: const Duration(milliseconds: 600),
                          child: _infoCard(
                            _getLocalizedString('grade'),
                            grade,
                            Icons.school_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 600),
                          child: _infoCard(
                            _getLocalizedString('phone'),
                            phone,
                            Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 32), // Section separator
                      ],
                    ),
                  ),
                ),

                // ===== SECTION 7: ACTION BUTTONS =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        FadeInUp(
                          delay: const Duration(milliseconds: 750),
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentEditScreen(),
                                  ),
                                ).then((_) => mounted ? _loadStats() : null);
                              },
                              icon: const Icon(Icons.edit, size: 20),
                              label: Text(
                                _getLocalizedString('edit_profile'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[800]
                                    : Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(Icons.logout, size: 20),
                              label: Text(
                                _getLocalizedString('logout'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.red[600]!
                                      : Colors.red.shade400!,
                                ),
                                foregroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.red[400]
                                    : Colors.red.shade400,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            _getLocalizedString('confirm_logout'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            _getLocalizedString('logout_confirm_message'),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                _getLocalizedString('cancel'),
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.red[800]
                    : Colors.red[700],
              ),
              child: Text(
                _getLocalizedString('logout_button'),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        // Show immediate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('logging_out')),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[800]
                : Colors.blue[700],
          ),
        );

        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('logout_failed')}$e"),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[800]
                : Colors.red[700],
          ),
        );
      }
    }
  }

  // ===== UNIFIED CARD COMPONENTS =====

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: color, size: 24)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedString('task_progress'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _stats?.overallProgress ?? 0.0,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_stats?.completedTasks ?? 0} ${_getLocalizedString('completed')}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              Text(
                "${_stats?.totalTasks ?? 1} ${_getLocalizedString('total')}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[300]
                      : Colors.blue[700],
                  size: 22,
                ),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
