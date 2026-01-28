import 'package:edu_connect/presintation/teachers_things/teacher_screens/home_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_profile_screen.dart';
import 'package:edu_connect/presintation/teachers_things/task/Teacher_task_list_screen.dart';
import 'package:edu_connect/providers/language_provider.dart'; // ✅ Import Provider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider package

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  // We move the pages list inside the build method or use a getter
  // to ensure they rebuild when theme/language changes.
  final List<Widget> _pages = [
    const HomeScreen(),
    const TeacherTaskListScreen(),
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Listen to Language Provider
    final lang = Provider.of<LanguageProvider>(context);

    // 2. Check for Dark Mode to adjust the bar background
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // IndexedStack keeps the state (scroll position, etc.) of your pages alive
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        // ✅ Theme Awareness
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,

        type: BottomNavigationBarType.fixed,

        // ✅ Language Awareness
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: lang.translate(
              'home',
            ), // Ensure 'home' is in your provider dictionary
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_rounded),
            label: lang.translate('tasks'), // Uses 'tasks' from your dictionary
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: lang.translate(
              'profile',
            ), // Ensure 'profile' is in your provider dictionary
          ),
        ],
      ),
    );
  }
}
