// widgets/stats_card_section.dart
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StatsCardsSection extends StatefulWidget {
  final StudentStats? stats;
  final VoidCallback onLeaderboardTap;

  const StatsCardsSection({super.key, required this.stats, required this.onLeaderboardTap});

  @override
  State<StatsCardsSection> createState() => _StatsCardsSectionState();
}

class _StatsCardsSectionState extends State<StatsCardsSection> {
  // Translation map
  Map<String, Map<String, String>> translations = {
    'en': {
      'points': 'Points',
      'leaderboard': 'Leaderboard',
      'streak': 'Streak',
      'progress': 'Progress',
    },
    'uz': {
      'points': 'Ballar',
      'leaderboard': 'Reyting',
      'streak': 'Ketma-ketlik',
      'progress': 'Jarayon',
    },
    'ru': {
      'points': 'Очки',
      'leaderboard': 'Рейтинг',
      'streak': 'Серия',
      'progress': 'Прогресс',
    },
  };

  String translate(String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return translations[languageProvider.currentLanguage]?[key] ?? translations['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildStatCard(
              translate('points'),
              "${widget.stats?.totalPoints ?? 0}",
              Icons.star,
              Colors.orange[700]!,
              isDarkMode,
            ),
            _buildStatCard(
              translate('leaderboard'),
              "#${widget.stats?.classRank ?? '--'}",
              Icons.leaderboard,
              Colors.purple[700]!,
              isDarkMode,
            ),
            _buildStatCard(
              translate('streak'),
              "${widget.stats?.currentStreak ?? 0} days",
              Icons.local_fire_department,
              Colors.red[700]!,
              isDarkMode,
            ),
            _buildStatCard(
              translate('progress'),
              "${(widget.stats?.overallProgress ?? 0) * 100}%",
              Icons.show_chart,
              Colors.blue[700]!,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800];
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: title == translate('leaderboard') ? widget.onLeaderboardTap : null,
        child: MouseRegion(
          cursor: title == translate('leaderboard') ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 28)),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}