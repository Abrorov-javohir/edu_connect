import 'package:edu_connect/presintation/teachers_things/anouncement/teacher_anouncement_screen.dart';
import 'package:edu_connect/presintation/teachers_things/courses/teacher_course_screen.dart';
import 'package:edu_connect/presintation/teachers_things/quick_action.dart';
import 'package:edu_connect/presintation/teachers_things/task/Teacher_task_list_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/anouncement_section.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/student_section.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/task_sectino.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_profile_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_student_list_screen.dart';
import 'package:edu_connect/presintation/teachers_things/widget/notification_badge.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _upcomingTasks = [];
  List<DocumentSnapshot> _newTasks = [];
  List<DocumentSnapshot> _recentAnnouncements = [];
  List<DocumentSnapshot> _recentStudents = [];

  @override
  void initState() {
    super.initState();
    _loadTasksAnnouncementsAndStudents();
  }

  Future<void> _loadTasksAnnouncementsAndStudents() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Logic for loading Tasks, Announcements, and Students...
      final allTasksSnapshot = await FirebaseFirestore.instance
          .collection("tasks")
          .where("teacherId", isEqualTo: userId)
          .get();

      final sortedTasks = allTasksSnapshot.docs
        ..sort((a, b) {
          final deadlineA =
              (a.data() as Map<String, dynamic>)["deadline"] as Timestamp?;
          final deadlineB =
              (b.data() as Map<String, dynamic>)["deadline"] as Timestamp?;
          if (deadlineA == null) return 1;
          if (deadlineB == null) return -1;
          return deadlineA.compareTo(deadlineB);
        });

      if (mounted) {
        setState(() {
          _upcomingTasks = sortedTasks.take(3).toList();
          _newTasks = allTasksSnapshot.docs
              .take(3)
              .toList(); // Simplified for brevity
        });
      }

      // Announcements
      final announcementsSnapshot = await FirebaseFirestore.instance
          .collection("announcements")
          .where("teacherId", isEqualTo: userId)
          .get();

      if (mounted) {
        setState(() {
          _recentAnnouncements = announcementsSnapshot.docs.take(3).toList();
        });
      }

      // Students (Logic remains as per your original file)
      // ... (OMITTED FOR BREVITY - KEEP YOUR EXISTING STUDENT LOADING CODE HERE) ...
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Access LanguageProvider
    final languageProvider = Provider.of<LanguageProvider>(context);

    // 2. Define Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF6F7FB);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        elevation: 2,
        title: Text(
          languageProvider.translate(
            'app_title',
          ), // ✅ Fixed: Calling from Provider
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        actions: [
          NotificationBadge(
            onPressed: () =>
                Navigator.pushNamed(context, '/teacher_notifications'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue[200],
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  // ✅ Navigate to TeacherProfileScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH FIELD
            TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: languageProvider.translate('search_hint'), // ✅ Fixed
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: hintColor),
                prefixIcon: Icon(Icons.search, color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QUICK ACTIONS TITLE
            Text(
              languageProvider.translate('quick_actions'), // ✅ Fixed
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // QUICK ACTIONS SECTION
            QuickActionsSection(
              onCoursesPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherCoursesScreen(),
                ),
              ),
              onTasksPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherTaskListScreen(),
                ),
              ),
              onStudentsPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherStudentsListScreen(),
                ),
              ),
              onAnnouncementsPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherAnnouncementScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // OTHER SECTIONS (Tasks, Students, Announcements)
            TasksSection(
              upcomingTasks: _upcomingTasks,
              newTasks: _newTasks,
              onTaskTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherTaskListScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            StudentsSection(recentStudents: _recentStudents),
            const SizedBox(height: 20),
            AnnouncementsSection(
              recentAnnouncements: _recentAnnouncements,
              onAnnouncementTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherAnnouncementScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
