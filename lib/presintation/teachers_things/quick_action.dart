import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onCoursesPressed;
  final VoidCallback onTasksPressed;
  final VoidCallback onStudentsPressed;
  final VoidCallback onAnnouncementsPressed;
  final VoidCallback onNotesPressed; // ✅ NEW: Notes action

  const QuickActionsSection({
    super.key,
    required this.onCoursesPressed,
    required this.onTasksPressed,
    required this.onStudentsPressed,
    required this.onAnnouncementsPressed,
    required this.onNotesPressed, // ✅ Required now
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardOpacity = isDark ? 0.2 : 0.1;
    final placeholderColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        // Row 1
        _buildActionCard(
          context,
          Icons.book_outlined,
          langProvider.translate('courses'),
          Colors.blue,
          onCoursesPressed,
          textColor,
          cardOpacity,
        ),
        _buildActionCard(
          context,
          Icons.task_outlined,
          langProvider.translate('tasks'),
          Colors.green,
          onTasksPressed,
          textColor,
          cardOpacity,
        ),
        
        // Row 2
        _buildActionCard(
          context,
          Icons.people_outlined,
          langProvider.translate('students'),
          Colors.orange,
          onStudentsPressed,
          textColor,
          cardOpacity,
        ),
        _buildActionCard(
          context,
          Icons.campaign_outlined,
          langProvider.translate('announcements'),
          Colors.purple,
          onAnnouncementsPressed,
          textColor,
          cardOpacity,
        ),
        
        // Row 3 (centered items)
        _buildActionCard(
          context,
          Icons.note_alt_outlined,
          langProvider.translate('notes'), // ✅ NEW ACTION
          Colors.amber,
          onNotesPressed,
          textColor,
          cardOpacity,
        ),
        // Subtle placeholder to balance the grid (invisible but maintains layout)
        Container(
          decoration: BoxDecoration(
            color: placeholderColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: placeholderColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(Icons.add_circle_outline, size: 32, color: Colors.grey),
          ),
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
    Color textColor,
    double opacity,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(opacity * 1.5),
                color.withOpacity(opacity * 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}