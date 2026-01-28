// screens/student_tasks_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/student_screens/widget/task_card2.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentTasksScreen extends StatefulWidget {
  const StudentTasksScreen({super.key});

  @override
  State<StudentTasksScreen> createState() => _StudentTasksScreenState();
}

class _StudentTasksScreenState extends State<StudentTasksScreen> {
  List<DocumentSnapshot> _allTasks = [];
  Map<String, Map<String, dynamic>> _taskSubmissions = {};
  bool _loading = true;
  int _completedTasks = 0;
  int _totalTasks = 0;
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      final classIds = await _getStudentClassIds();
      if (classIds.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      // Load tasks
      final tasksQuery = await FirebaseFirestore.instance
          .collection("tasks")
          .where("classId", whereIn: classIds)
          .orderBy("deadline", descending: false)
          .get();

      // Load submission statuses
      final submissionsQuery = await FirebaseFirestore.instance
          .collection("taskSubmissions")
          .where("studentId", isEqualTo: userId)
          .get();

      final submissionsMap = <String, Map<String, dynamic>>{};
      for (final doc in submissionsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        submissionsMap[data["taskId"] as String] = {...data, "id": doc.id};
      }

      // Calculate stats
      final completedCount = submissionsQuery.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data["status"] as String?;
        return status == "completed_unverified" ||
            status == "submitted" ||
            status == "verified";
      }).length;

      setState(() {
        _allTasks = tasksQuery.docs;
        _taskSubmissions = submissionsMap;
        _totalTasks = tasksQuery.docs.length;
        _completedTasks = completedCount;
        _completionPercentage = _totalTasks > 0
            ? (_completedTasks / _totalTasks) * 100
            : 0.0;
        _loading = false;
      });
    } catch (e) {
      print("Error loading tasks: $e");
      setState(() => _loading = false);
    }
  }

  Future<List<String>> _getStudentClassIds() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final classesQuery = await FirebaseFirestore.instance
        .collection("classStudents")
        .where("studentId", isEqualTo: userId)
        .get();

    return classesQuery.docs.map((doc) => doc["classId"] as String).toList();
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'my_tasks':
            return "Mening Vazifalarim";
          case 'task_progress':
            return "Vazifa Rejasi";
          case 'outstanding':
            return "🌟 Ajoyib! Siz deyarli tugatdingiz!";
          case 'great_job':
            return "👍 A'lo! A'lo ish davom ettiring!";
          case 'good_progress':
            return "💪 Yaxshi rivoj! Siz yarmini tugatdingiz!";
          case 'keep_going':
            return "🚀 Davom eting! Har bir vazifa muvaffaqiyatga yaqinlashtiradi!";
          case 'start_today':
            return "✨ Bugun boshlang! Kichik qadamlar katta yutuqlarga olib chiqadi!";
          case 'no_tasks':
            return "Vazifa Tayanmagan";
          case 'task_description':
            return "O'qituvchingiz bu yerda vazifalarni tayinlaydi. Ballarni yig'ish va rivojingizni kuzatish uchun ularni bajaring!";
          case 'contact_teacher':
            return "O'qituvchi Bilan Bog'lanish";
          case 'request_tasks':
            return "Vazifalarni so'rash uchun o'qituvchingiz bilan bog'laning!";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'my_tasks':
            return "Мои Задания";
          case 'task_progress':
            return "Прогресс Заданий";
          case 'outstanding':
            return "🌟 Отлично! Вы почти закончили!";
          case 'great_job':
            return "👍 Отличная работа! Продолжайте в том же духе!";
          case 'good_progress':
            return "💪 Хороший прогресс! Вы на полпути!";
          case 'keep_going':
            return "🚀 Продолжайте! Каждое задание приближает вас к успеху!";
          case 'start_today':
            return "✨ Начните сегодня! Маленькие шаги приводят к большим достижениям!";
          case 'no_tasks':
            return "Нет Назначенных Заданий";
          case 'task_description':
            return "Ваши учителя будут назначать задания здесь. Выполняйте их, чтобы зарабатывать баллы и отслеживать свой прогресс!";
          case 'contact_teacher':
            return "Связаться с Учителем";
          case 'request_tasks':
            return "Свяжитесь с учителем, чтобы запросить задания!";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'my_tasks':
            return "My Tasks";
          case 'task_progress':
            return "Task Progress";
          case 'outstanding':
            return "🌟 Outstanding! You're almost done!";
          case 'great_job':
            return "👍 Great job! Keep up the excellent work!";
          case 'good_progress':
            return "💪 Good progress! You're halfway there!";
          case 'keep_going':
            return "🚀 Keep going! Every task brings you closer to success!";
          case 'start_today':
            return "✨ Start today! Small steps lead to big achievements!";
          case 'no_tasks':
            return "No Tasks Assigned";
          case 'task_description':
            return "Your teachers will assign tasks here. Complete them to earn points and track your progress!";
          case 'contact_teacher':
            return "Contact Teacher";
          case 'request_tasks':
            return "Contact your teacher to request tasks!";
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
        title: Text(
          _getLocalizedString('my_tasks'),
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).appBarTheme.foregroundColor,
              size: 26,
            ),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[400]
                    : Colors.blue,
              ),
            )
          : _allTasks.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async => _loadTasks(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildTaskList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFFFFFFF),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue
                          : Colors.blue)
                      .withOpacity(0.05),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color:
                  (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.grey)
                      .withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF444444)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _getLocalizedString('task_progress'),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            // Progress Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _completionPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _completionPercentage >= 80
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.green[400]!
                                : Colors.green[700]!)
                          : _completionPercentage >= 50
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[400]!
                                : Colors.blue[700]!)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.orange[400]!
                                : Colors.orange[700]!),
                    ),
                  ),
                ),
                Text(
                  "${_completedTasks}/${_totalTasks}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Text
            Text(
              "${_completionPercentage.toStringAsFixed(1)}% Complete",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _completionPercentage >= 80
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[400]
                          : Colors.green[700])
                    : _completionPercentage >= 50
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[400]
                          : Colors.blue[700])
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.orange[400]
                          : Colors.orange[700]),
              ),
            ),
            const SizedBox(height: 16),
            // Motivational Message
            Text(
              textAlign: TextAlign.center,
              _getMotivationalMessage(_completionPercentage),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 90) {
      return _getLocalizedString('outstanding');
    } else if (progress >= 70) {
      return _getLocalizedString('great_job');
    } else if (progress >= 50) {
      return _getLocalizedString('good_progress');
    } else if (progress >= 30) {
      return _getLocalizedString('keep_going');
    } else {
      return _getLocalizedString('start_today');
    }
  }

  Widget _buildTaskList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _allTasks.length,
      itemBuilder: (context, index) {
        final task = _allTasks[index];
        final data = task.data() as Map<String, dynamic>;
        final deadline = (data["deadline"] as Timestamp).toDate();
        final now = DateTime.now();
        final isOverdue = deadline.isBefore(now);
        final daysLeft = deadline.difference(now).inDays;

        // Get task status
        final submission = _taskSubmissions[task.id];
        final status = submission?["status"] ?? "pending";

        return FadeInUp(
          delay: Duration(milliseconds: 150 * index),
          duration: const Duration(milliseconds: 600),
          child: TaskCard2(
            task: task,
            data: data,
            isOverdue: isOverdue,
            daysLeft: daysLeft,
            status: status,
            taskId: task.id,
            onTaskUpdated: _loadTasks,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
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
              ),
              child: Icon(
                Icons.task_alt,
                size: 80,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue[800],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _getLocalizedString('no_tasks'),
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _getLocalizedString('task_description'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Quick Action Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to chat or contact teacher
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_getLocalizedString('request_tasks')),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  _getLocalizedString('contact_teacher'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
