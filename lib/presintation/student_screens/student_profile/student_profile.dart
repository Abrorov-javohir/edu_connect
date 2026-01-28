// screens/student_profile_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:edu_connect/presintation/student_screens/settings/settings_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_classes_section.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_profile_edit_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_all_classes_screen.dart'; // Import the new screen
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
          case 'settings':
            return "Sozlamalar";
          case 'language_appearance':
            return "Til & Ko'rinish";
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
          case 'view_all_classes': // New localization
            return "Barcha Sinfni Ko'rish";
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
          case 'settings':
            return "Настройки";
          case 'language_appearance':
            return "Язык & Внешний вид";
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
          case 'view_all_classes': // New localization
            return "Посмотреть Все Классы";
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
          case 'settings':
            return "Settings";
          case 'language_appearance':
            return "Language & Appearance";
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
          case 'view_all_classes': // New localization
            return "View All Classes";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();

    // Set up user data subscription
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots()
          .listen((snapshot) {
            // User data changed, refresh stats if needed
            if (snapshot.exists) {
              // You can add logic here to refresh stats when user data changes
            }
          });
    }
  }

  @override
  void dispose() {
    // Clean up subscription to prevent memory leaks
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

    // Handle null user
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
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: Theme.of(
                    context,
                  ).appBarTheme.backgroundColor,
                  foregroundColor: Theme.of(
                    context,
                  ).appBarTheme.foregroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _getLocalizedString('profile'),
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    background: Container(
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
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFF4A6CF7),
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF42A5F5)
                                        : const Color(0xFF6C8CFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          // Profile picture
                          Positioned(
                            top: 120,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(70),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[300]
                                              : Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            role == "teacher" ? "Teacher" : grade,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Classes Section
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          child: StudentClassesSection(context: context),
                        ),

                        // NEW: View All Classes Button
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to the new screen showing all classes
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentAllClassesScreen(),
                                  ),
                                );
                              },
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
                                elevation: 3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Stats Cards - NOW WITH REAL DATA!
                        if (_loadingStats)
                          Center(
                            child: CircularProgressIndicator(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue[400]
                                  : Colors.blue,
                            ),
                          )
                        else
                          Column(
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
                            ],
                          ),
                        const SizedBox(height: 32),

                        // Progress Section - NOW WITH REAL DATA!
                        if (!_loadingStats)
                          FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 600),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]!
                                        : Colors.grey[50]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getLocalizedString('task_progress'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: _stats?.overallProgress ?? 0.0,
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]!
                                        : Colors.grey[200]!,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green[700]!,
                                    ),
                                    minHeight: 10,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Info Cards
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

                        const SizedBox(height: 24),

                        // Settings Card - NEW
                        FadeInUp(
                          delay: const Duration(milliseconds: 720),
                          duration: const Duration(milliseconds: 600),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]!
                                        : Colors.grey[50]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.blue[900]
                                          : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.settings,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.blue[300]
                                            : Colors.blue[700],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getLocalizedString('settings'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getLocalizedString(
                                            'language_appearance',
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Action Buttons
                        FadeInUp(
                          delay: const Duration(milliseconds: 750),
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to edit screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentEditScreen(),
                                  ),
                                ).then((_) {
                                  // Refresh stats when returning from edit screen
                                  if (mounted) {
                                    _loadStats();
                                  }
                                });
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
                                elevation: 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // ✅ FIXED LOGOUT BUTTON
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
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
                                        _getLocalizedString(
                                          'logout_confirm_message',
                                        ),
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
                                            _getLocalizedString(
                                              'logout_button',
                                            ),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && mounted) {
                                    // Sign out from Firebase
                                    await FirebaseAuth.instance.signOut();

                                    // Navigate to login screen and clear all previous routes
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
                                }
                              },
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
                                elevation: 2,
                              ),
                            ),
                          ),
                        ),
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: FadeIn(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, color: color, size: 24)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String subtitle, IconData icon) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[300]
                      : Colors.blue[700],
                  size: 24,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
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
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
