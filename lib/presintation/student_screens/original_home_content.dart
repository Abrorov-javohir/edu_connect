// widgets/student_home_content.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:edu_connect/presintation/student_screens/widget/courses_section.dart';
import 'package:edu_connect/presintation/student_screens/widget/home_appbar_widget.dart';
import 'package:edu_connect/presintation/student_screens/widget/leaderboard_dialog.dart';
import 'package:edu_connect/presintation/student_screens/widget/stats_card_section.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_profile.dart';
import 'package:edu_connect/presintation/student_screens/student_task_screen.dart';
import 'package:provider/provider.dart';

class StudentHomeContent extends StatefulWidget {
  const StudentHomeContent({super.key});

  @override
  State<StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<StudentHomeContent> {
  final StudentStatsService _statsService = StudentStatsService();

  // ✅ OPTIMIZED: Use separate loading states for better UX
  bool _loadingStats = true;
  bool _loadingCourses = true;

  StudentStats? _stats;
  List<CourseProgress> _courses = [];

  // Translation map
  Map<String, Map<String, String>> translations = {
    'en': {
      'welcomeBack': 'Welcome back 👋',
      'student': 'Student',
      'yourTasks': 'Your Tasks',
      'viewAll': 'View All',
      'noTasks': 'No tasks assigned yet. Check back later!',
      'loading': 'Loading...',
    },
    'uz': {
      'welcomeBack': 'Qaytganingiz bilan xush kelibsiz 👋',
      'student': 'Talaba',
      'yourTasks': 'Sizning vazifalaringiz',
      'viewAll': 'Barchasini ko\'rish',
      'noTasks': 'Hali hech qanday vazifa berilmagan. Keyinroq qayting!',
      'loading': 'Yuklanmoqda...',
    },
    'ru': {
      'welcomeBack': 'С возвращением 👋',
      'student': 'Студент',
      'yourTasks': 'Ваши задания',
      'viewAll': 'Посмотреть все',
      'noTasks': 'Заданий пока не назначено. Загляните позже!',
      'loading': 'Загрузка...',
    },
  };

  String translate(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return translations[languageProvider.currentLanguage]?[key] ??
        translations['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ✅ FIXED: Added proper mounted check before setState
  Future<void> _loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // ✅ OPTIMIZED: Load all data in PARALLEL with proper error handling
    final statsFuture = _loadStats(userId);
    final coursesFuture = _loadCourses(userId);

    // Wait for all futures to complete
    await Future.wait([statsFuture, coursesFuture]);
  }

  Future<void> _loadStats(String userId) async {
    if (!mounted) return; // ✅ FIXED: Check mounted before setState
    setState(() => _loadingStats = true);
    try {
      final stats = await _statsService.getStudentStats(userId);
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

  Future<void> _loadCourses(String userId) async {
    if (!mounted) return; // ✅ FIXED: Check mounted before setState
    setState(() => _loadingCourses = true);
    try {
      final courses = await _statsService.getStudentCourses(userId);
      if (mounted) {
        setState(() {
          _courses = courses;
          _loadingCourses = false;
        });
      }
    } catch (e) {
      print("Error loading courses: $e");
      if (mounted) {
        setState(() => _loadingCourses = false);
      }
    }
  }

  bool get _isLoading => _loadingStats || _loadingCourses;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF6F7FB);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 🎯 APP BAR SECTION
          HomeAppBar(
            onProfileTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentProfileScreen(),
                ),
              );
            },
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 20),

          // 🧩 STATS CARDS SECTION - Show immediately with skeleton
          _buildStatsCardsSection(isDarkMode),

          const SizedBox(height: 24),

          // 📚 COURSES SECTION - Show immediately with skeleton
          // _buildCoursesSection(isDarkMode),
          const SizedBox(height: 24),

          // 📋 TASKS SECTION - NEW SECTION
          _buildTasksSection(isDarkMode, textColor),

          // 🌀 FULL LOADING STATE (fallback)
          if (_isLoading && _courses.isEmpty)
            Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCardsSection(bool isDarkMode) {
    if (_loadingStats && _stats == null) {
      return _buildStatsSkeleton(isDarkMode);
    }

    return StatsCardsSection(
      stats: _stats,
      onLeaderboardTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardScreen(stats: _stats),
          ),
        );
      },
    );
  }

  // 📋 TASKS SECTION - NEW METHOD
  Widget _buildTasksSection(bool isDarkMode, Color textColor) {
    if (_loadingStats && _stats == null) {
      return _buildTasksSkeleton(isDarkMode);
    }

    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('yourTasks'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentTasksScreen(),
                      ),
                    );
                  },
                  child: Text(
                    translate('viewAll'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stats?.tasks.isEmpty ?? true)
              _buildEmptyTasks(isDarkMode)
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (_stats?.tasks.length ?? 0).clamp(0, 3),
                  itemBuilder: (context, index) {
                    final task = _stats!.tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 280,
                        child: FadeInRight(
                          delay: Duration(milliseconds: 100 * index),
                          duration: const Duration(milliseconds: 800),
                          child: _taskCard(task, isDarkMode),
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

  Widget _taskCard(TaskProgress task, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [task.color.withOpacity(0.05), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : task.color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: task.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.checklist, color: task.color, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
              ),
              Text(
                "${(task.progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: task.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.subject,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar with animation
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  width: constraints.maxWidth * task.progress,
                  decoration: BoxDecoration(
                    color: task.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.isCompleted ? "Completed" : "Pending",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasks(bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50];
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, color: textColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              translate('noTasks'),
              style: GoogleFonts.poppins(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SKELETON LOADERS FOR BETTER UX
  Widget _buildStatsSkeleton(bool isDarkMode) {
    final skeletonColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: List.generate(4, (index) {
          return Container(
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(24),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTasksSkeleton(bool isDarkMode) {
    final skeletonColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 120, height: 20, color: skeletonColor),
              Container(width: 80, height: 20, color: skeletonColor),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 280,
                    child: Container(
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
