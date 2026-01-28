import 'package:edu_connect/providers/language_provider.dart'; // ✅ Import Provider
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider package

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onCoursesPressed;
  final VoidCallback onTasksPressed;
  final VoidCallback onStudentsPressed;
  final VoidCallback onAnnouncementsPressed;

  const QuickActionsSection({
    super.key,
    required this.onCoursesPressed,
    required this.onTasksPressed,
    required this.onStudentsPressed,
    required this.onAnnouncementsPressed,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Listen to Language Provider
    final langProvider = Provider.of<LanguageProvider>(context);
    
    // ✅ 2. Check for Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    // Optional: Adjust card background opacity for dark mode visibility
    final cardOpacity = isDark ? 0.2 : 0.1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          context,
          Icons.book,
          langProvider.translate('courses'), // ✅ Dynamic Text
          Colors.blue,
          onCoursesPressed,
          textColor,
          cardOpacity,
        ),
        _buildActionCard(
          context,
          Icons.task,
          langProvider.translate('tasks'), // ✅ Dynamic Text
          Colors.green,
          onTasksPressed,
          textColor,
          cardOpacity,
        ),
        _buildActionCard(
          context,
          Icons.people,
          langProvider.translate('students'), // ✅ Dynamic Text
          Colors.orange,
          onStudentsPressed,
          textColor,
          cardOpacity,
        ),
        _buildActionCard(
          context,
          Icons.campaign,
          langProvider.translate('announcements'), // ✅ Dynamic Text
          Colors.purple,
          onAnnouncementsPressed,
          textColor,
          cardOpacity,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
    Color textColor, // ✅ Pass dynamic text color
    double opacity,  // ✅ Pass dynamic opacity
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(opacity), // ✅ Use dynamic opacity
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor, // ✅ Apply dynamic color
              ),
            ),
          ],
        ),
      ),
    );
  }
}