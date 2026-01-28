// screens/student_progress_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final StudentStatsService _statsService = StudentStatsService();
  StudentStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final stats = await _statsService.getStudentStats(userId);
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      print("Error loading progress data: $e");
      setState(() => _loading = false);
    }
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'my_progress':
            return "Mening Rivojim";
          case 'overall_progress':
            return "Umumiy Rivoj";
          case 'stars_and_streaks':
            return "Yulduzlar & Seriyalar";
          case 'total_stars':
            return "Jami Yulduzlar";
          case 'earned_points':
            return "Olingan ballar";
          case 'current_streak':
            return "Joriy Seriya";
          case 'best_streak':
            return "Eng Yaxshi Seriya";
          case 'days':
            return "kun";
          case 'task_progress':
            return "Vazifa Rivoji";
          case 'achievements':
            return "Yutuqlar";
          case 'star_student':
            return "Yulduz O'quvchi";
          case 'fire_streak':
            return "Olovli Seriya";
          case 'top_performer':
            return "Eng Zo'r Bajaruvchi";
          case 'no_tasks_yet':
            return "Hali Vazifa Yo'q";
          case 'earn_stars':
            return "Yulduzlar olish va seriyani uzaytirish uchun vazifalarni bajaring!";
          case 'completed':
            return "Bajarildi";
          case 'overdue':
            return "Kechikdi";
          case 'due_soon':
            return "Tez kunda";
          case 'pending':
            return "Kutilmoqda";
          case 'outstanding':
            return "🌟 A'lo! Siz barcha fanlarda a'lo bajarinyapsiz!";
          case 'great_job':
            return "👍 A'lo! A'lo ish davom ettiring!";
          case 'good_progress':
            return "💪 Yaxshi rivoj! Siz to'g'ri yo'nalishda ketyapsiz!";
          case 'keep_going':
            return "🚀 Davom eting! Har bir vazifa sizni muvaffaqiyatga yaqinlashtiradi!";
          case 'start_today':
            return "✨ Bugun boshlang! Kichik qadamlar katta yutuqlarga olib chiqadi!";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'my_progress':
            return "Мой Прогресс";
          case 'overall_progress':
            return "Общий Прогресс";
          case 'stars_and_streaks':
            return "Звезды & Серии";
          case 'total_stars':
            return "Всего Звезд";
          case 'earned_points':
            return "Заработанные баллы";
          case 'current_streak':
            return "Текущая Серия";
          case 'best_streak':
            return "Лучшая Серия";
          case 'days':
            return "дней";
          case 'task_progress':
            return "Прогресс Заданий";
          case 'achievements':
            return "Достижения";
          case 'star_student':
            return "Звездный Студент";
          case 'fire_streak':
            return "Огненная Серия";
          case 'top_performer':
            return "Лучший Исполнитель";
          case 'no_tasks_yet':
            return "Пока Нет Заданий";
          case 'earn_stars':
            return "Выполняйте задания, чтобы заработать звезды и увеличить серию!";
          case 'completed':
            return "Выполнено";
          case 'overdue':
            return "Просрочено";
          case 'due_soon':
            return "Скоро срок";
          case 'pending':
            return "В ожидании";
          case 'outstanding':
            return "🌟 Отлично! Вы отлично справляетесь со всеми предметами!";
          case 'great_job':
            return "👍 Отличная работа! Продолжайте в том же духе!";
          case 'good_progress':
            return "💪 Хороший прогресс! Вы на правильном пути!";
          case 'keep_going':
            return "🚀 Продолжайте! Каждое задание приближает вас к успеху!";
          case 'start_today':
            return "✨ Начните сегодня! Маленькие шаги ведут к большим достижениям!";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'my_progress':
            return "My Progress";
          case 'overall_progress':
            return "Overall Progress";
          case 'stars_and_streaks':
            return "Stars & Streaks";
          case 'total_stars':
            return "Total Stars";
          case 'earned_points':
            return "Earned points";
          case 'current_streak':
            return "Current Streak";
          case 'best_streak':
            return "Best Streak";
          case 'days':
            return "days";
          case 'task_progress':
            return "Task Progress";
          case 'achievements':
            return "Achievements";
          case 'star_student':
            return "Star Student";
          case 'fire_streak':
            return "Fire Streak";
          case 'top_performer':
            return "Top Performer";
          case 'no_tasks_yet':
            return "No Tasks Assigned Yet";
          case 'earn_stars':
            return "Complete tasks to earn stars and build your streak!";
          case 'completed':
            return "COMPLETED";
          case 'overdue':
            return "OVERDUE";
          case 'due_soon':
            return "DUE SOON";
          case 'pending':
            return "PENDING";
          case 'outstanding':
            return "🌟 Outstanding! You're excelling in all subjects!";
          case 'great_job':
            return "👍 Great job! Keep up the excellent work!";
          case 'good_progress':
            return "💪 Good progress! You're on the right track!";
          case 'keep_going':
            return "🚀 Keep going! Every task brings you closer to success!";
          case 'start_today':
            return "✨ Start today! Small steps lead to big achievements!";
          default:
            return key;
        }
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
          _getLocalizedString('my_progress'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[400]
                      : Colors.blue,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => _loadProgressData(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🌟 OVERALL PROGRESS SECTION
                      _buildOverallProgressSection(),

                      const SizedBox(height: 28),

                      // ⭐ STARS & STREAKS SECTION
                      _buildStarsAndStreaksSection(),

                      const SizedBox(height: 28),

                      // 📚 TASK PROGRESS SECTION
                      _buildTaskProgressSection(),

                      const SizedBox(height: 28),

                      // 🏆 ACHIEVEMENTS SECTION
                      _buildAchievementsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // 🌟 OVERALL PROGRESS SECTION
  Widget _buildOverallProgressSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.blue[50]!,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[800]!
                : Colors.blue[100]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue
                          : Colors.blue)
                      .withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedString('overall_progress'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(
                      _stats?.overallProgress ?? 0.0,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getProgressColor(
                        _stats?.overallProgress ?? 0.0,
                      ).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProgressIcon(_stats?.overallProgress ?? 0.0),
                        size: 18,
                        color: _getProgressColor(
                          _stats?.overallProgress ?? 0.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${((_stats?.overallProgress ?? 0.0) * 100).toInt()}%",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _getProgressColor(
                            _stats?.overallProgress ?? 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _stats?.overallProgress ?? 0.0,
                    strokeWidth: 12,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(_stats?.overallProgress ?? 0.0),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${((_stats?.overallProgress ?? 0.0) * 100).toInt()}",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _getProgressColor(
                              _stats?.overallProgress ?? 0.0,
                            ),
                          ),
                        ),
                        Text(
                          "out of 100",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              _getMotivationalMessage(_stats?.overallProgress ?? 0.0),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getProgressColor(_stats?.overallProgress ?? 0.0),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green[700]!;
    if (progress >= 0.5) return Colors.blue[700]!;
    return Colors.orange[700]!;
  }

  IconData _getProgressIcon(double progress) {
    if (progress >= 0.8) return Icons.emoji_events;
    if (progress >= 0.5) return Icons.trending_up;
    return Icons.hourglass_bottom;
  }

  // ⭐ STARS & STREAKS SECTION
  Widget _buildStarsAndStreaksSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedString('stars_and_streaks'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.purple[900]?.withOpacity(0.2)
                        : Colors.purple[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple[700]!
                          : Colors.purple[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.purple[300]
                            : Colors.purple[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_stats?.totalPoints ?? 0} PTS",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.purple[300]
                              : Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  title: _getLocalizedString('total_stars'),
                  value: "${_stats?.totalPoints ?? 0}",
                  icon: Icons.star,
                  color: Colors.orange[700]!,
                  subtitle: _getLocalizedString('earned_points'),
                ),
                _buildStatCard(
                  title: _getLocalizedString('current_streak'),
                  value: "${_stats?.currentStreak ?? 0}",
                  icon: Icons.whatshot,
                  color: Colors.red[700]!,
                  subtitle: _getLocalizedString('days'),
                ),
                _buildStatCard(
                  title: _getLocalizedString('best_streak'),
                  value: "${_stats?.longestStreak ?? 0}",
                  icon: Icons.local_fire_department,
                  color: Colors.purple[700]!,
                  subtitle: _getLocalizedString('days'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return FadeIn(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 📚 TASK PROGRESS SECTION
  Widget _buildTaskProgressSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedString('task_progress'),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          if (_stats?.tasks.isEmpty ?? true)
            _buildEmptyState()
          else
            Container(
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ..._stats!.tasks.mapIndexed(
                    (index, task) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _taskProgressItem(task),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _taskProgressItem(TaskProgress task) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: task.color.withOpacity(0.03),
        border: Border.all(color: task.color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: task.color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: task.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Icon(
                    _getSubjectIcon(task.subject),
                    color: task.color,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.subject,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${(task.progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: task.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth * (task.progress ?? 0.0),
                  decoration: BoxDecoration(
                    color: task.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Status indicator
          _buildStatusIndicator(task),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(TaskProgress task) {
    // Calculate days left or overdue
    final now = DateTime.now();
    final daysDifference = task.deadline.difference(now).inDays;

    if (task.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.green[900]?.withOpacity(0.2)
              : Colors.green[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getLocalizedString('completed'),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.green[300]
                : Colors.green[700],
          ),
        ),
      );
    } else if (daysDifference < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.red[900]?.withOpacity(0.2)
              : Colors.red[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getLocalizedString('overdue'),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[300]
                : Colors.red[700],
          ),
        ),
      );
    } else if (daysDifference <= 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange[900]?.withOpacity(0.2)
              : Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getLocalizedString('due_soon'),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.orange[300]
                : Colors.orange[700],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.blue[900]?.withOpacity(0.2)
              : Colors.blue[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getLocalizedString('pending'),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[300]
                : Colors.blue[700],
          ),
        ),
      );
    }
  }

  // 🏆 ACHIEVEMENTS SECTION
  Widget _buildAchievementsSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedString('achievements'),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _achievementBadge(
                  _getLocalizedString('star_student'),
                  Icons.star,
                  Colors.orange[700]!,
                ),
                _achievementBadge(
                  _getLocalizedString('fire_streak'),
                  Icons.local_fire_department,
                  Colors.red[700]!,
                ),
                _achievementBadge(
                  _getLocalizedString('top_performer'),
                  Icons.emoji_events,
                  Colors.blue[700]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(36),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[900]?.withOpacity(0.2)
                  : Colors.blue[50],
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[700]!
                    : Colors.blue[100]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue
                              : Colors.blue)
                          .withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.school,
              size: 56,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[300]
                  : Colors.blue[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedString('no_tasks_yet'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getLocalizedString('earn_stars'),
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history;
      case 'english':
        return Icons.book;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'physics':
        return Icons.auto_fix_high;
      case 'chemistry':
        return Icons.science_outlined;
      case 'biology':
        return Icons.eco;
      default:
        return Icons.school;
    }
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 0.9) {
      return _getLocalizedString('outstanding');
    } else if (progress >= 0.7) {
      return _getLocalizedString('great_job');
    } else if (progress >= 0.5) {
      return _getLocalizedString('good_progress');
    } else if (progress >= 0.3) {
      return _getLocalizedString('keep_going');
    } else {
      return _getLocalizedString('start_today');
    }
  }
}

// Extension to add mapIndexed method
extension MapIndexedExtension<T> on Iterable<T> {
  List<R> mapIndexed<R>(R Function(int index, T element) f) {
    final List<R> result = [];
    var index = 0;
    for (final element in this) {
      result.add(f(index, element));
      index++;
    }
    return result;
  }
}
