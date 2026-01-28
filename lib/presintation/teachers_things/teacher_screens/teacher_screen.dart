import 'package:edu_connect/presintation/teachers_things/chats/teacher_chat_screen.dart';
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

// Import the screen at the top

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const TeacherTaskListScreen(),
    const TeacherChatScreen(), // ✅ Added Chat Screen
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: lang.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_rounded),
            label: lang.translate('tasks'),
          ),
          // ✅ Added Chat Item
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_rounded),
            label: lang.translate('chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: lang.translate('profile'),
          ),
        ],
      ),
    );
  }
}
