// screens/student_home_screen.dart
import 'package:edu_connect/presintation/student_screens/original_home_content.dart';
import 'package:edu_connect/presintation/student_screens/student_calendar_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_chat_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_profile.dart';
import 'package:edu_connect/presintation/student_screens/student_task_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_progress_screen.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StudentHomeContent(), // Home screen (index 0)
    const StudentCalendarScreen(), // Calendar screen (index 1)
    const StudentChatScreen(), // Chat screen (index 2)
    const StudentTasksScreen(), // Tasks screen (index 3)
    const StudentProgressScreen(), // Progress screen (index 4)
    const StudentProfileScreen(), // Profile screen (index 5)
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 24),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 24),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task, size: 24),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
