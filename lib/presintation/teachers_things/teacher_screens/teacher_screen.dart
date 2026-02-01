import 'package:edu_connect/presintation/teachers_things/chats/teacher_chat_screen.dart';
import 'package:edu_connect/presintation/teachers_things/notes/note_Screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/home_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_profile_screen.dart';
import 'package:edu_connect/presintation/teachers_things/task/Teacher_task_list_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const TeacherTaskListScreen(),
    const TeacherChatScreen(),
    const TeacherNotesScreen(),
    const TeacherProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? Colors.blue[300]! : Colors.blue[800]!;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              // ✅ CRITICAL FIX: Bounds checking
              if (index >= 0 && index < _pages.length) {
                setState(() => _currentIndex = index);
              }
            },
            backgroundColor: bgColor,
            selectedItemColor: activeColor,
            unselectedItemColor: inactiveColor,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: [
              _buildNavItem(
                icon: Icons.home_rounded,
                activeIcon: Icons.home,
                label: langProvider.translate('home'),
                isActive: _currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                icon: Icons.assignment_rounded,
                activeIcon: Icons.assignment,
                label: langProvider.translate('tasks'),
                isActive: _currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: langProvider.translate('chat'),
                isActive: _currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                icon: Icons.note_alt_outlined,
                activeIcon: Icons.note_alt,
                label: langProvider.translate('notes'),
                isActive: _currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: langProvider.translate('profile'),
                isActive: _currentIndex == 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24, color: isActive ? activeColor : inactiveColor),
      activeIcon: Icon(activeIcon, size: 28, color: activeColor),
      label: label,
      tooltip: label,
    );
  }
}
