// screens/leaderboard_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final StudentStats? stats;

  const LeaderboardScreen({super.key, required this.stats});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Translation map
  Map<String, Map<String, String>> translations = {
    'en': {
      'leaderboard': 'Leaderboard',
      'classLeaderboard': 'Class Leaderboard',
      'globalLeaderboard': 'Global Leaderboard',
      'top3': '🥇 Top 3',
      'top10': '🥈 Top 10',
      'top50': '🥉 Top 50',
      'loading': 'Loading...',
      'error': 'Error loading data',
    },
    'uz': {
      'leaderboard': 'Reyting',
      'classLeaderboard': 'Sinf reytingi',
      'globalLeaderboard': 'Global reyting',
      'top3': '🥇 Yuqori 3',
      'top10': '🥈 Yuqori 10',
      'top50': '🥉 Yuqori 50',
      'loading': 'Yuklanmoqda...',
      'error': 'Ma\'lumotlarni yuklashda xatolik',
    },
    'ru': {
      'leaderboard': 'Рейтинг',
      'classLeaderboard': 'Рейтинг класса',
      'globalLeaderboard': 'Глобальный рейтинг',
      'top3': '🥇 Топ 3',
      'top10': '🥈 Топ 10',
      'top50': '🥉 Топ 50',
      'loading': 'Загрузка...',
      'error': 'Ошибка загрузки данных',
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

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FC);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final legendColor = isDarkMode ? Colors.grey[800] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: Text(
          translate('leaderboard'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Class Leaderboard
            _buildLeaderboardSection(
              translate('classLeaderboard'),
              widget.stats?.classRank ?? 0,
              widget.stats?.totalPoints ?? 0,
              isDarkMode,
              cardColor,
              textColor,
            ),

            const SizedBox(height: 32),

            // Global Leaderboard
            _buildGlobalLeaderboardSection(
              translate('globalLeaderboard'),
              widget.stats?.globalRank ?? 0,
              widget.stats?.totalPoints ?? 0,
              isDarkMode,
              cardColor,
              textColor,
            ),

            const SizedBox(height: 32),

            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: legendColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(translate('top3'), Colors.orange[700]!, isDarkMode),
                  _buildLegendItem(translate('top10'), Colors.grey[700]!, isDarkMode),
                  _buildLegendItem(translate('top50'), Colors.brown[700]!, isDarkMode),
                ],
              ),
            ),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(String title, int userRank, int userPoints, bool isDarkMode, Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getClassLeaderboard(userRank, userPoints),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                '${translate('error')}: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            }

            final leaders = snapshot.data ?? [];

            return Column(
              children: leaders.map((leader) {
                return _buildLeaderRow(leader, Colors.blue[700]!, isDarkMode, cardColor, textColor);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlobalLeaderboardSection(
    String title,
    int userRank,
    int userPoints,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.purple[700],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getGlobalLeaderboard(userRank, userPoints),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.purple[400] : Colors.purple[700],
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                '${translate('error')}: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              );
            }

            final leaders = snapshot.data ?? [];

            return Column(
              children: leaders.map((leader) {
                return _buildLeaderRow(leader, Colors.purple[700]!, isDarkMode, cardColor, textColor);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getClassLeaderboard(
    int userRank,
    int userPoints,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      // Get classes this student is enrolled in
      final classStudentsSnapshot = await FirebaseFirestore.instance
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) return [];

      final Set<String> classIds = {};
      for (final doc in classStudentsSnapshot.docs) {
        classIds.add(doc["classId"] as String);
      }

      // Get all students in these classes
      final allStudentsInClasses = await FirebaseFirestore.instance
          .collection("classStudents")
          .get();

      final Map<String, int> studentPoints = {};

      for (final studentDoc in allStudentsInClasses.docs) {
        final studentId = studentDoc["studentId"] as String;
        final studentPointsCount = await _calculateStudentPoints(studentId);
        studentPoints[studentId] = studentPointsCount;
      }

      // Sort by points (descending)
      final studentPointsList = studentPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Create leaderboard entries with real names
      final List<Map<String, dynamic>> leaderboard = [];
      for (int i = 0; i < studentPointsList.length; i++) {
        final studentId = studentPointsList[i].key;
        final points = studentPointsList[i].value;

        // Get student name from users collection
        String name = "Unknown Student";
        try {
          final studentDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(studentId)
              .get();

          if (studentDoc.exists) {
            final data = studentDoc.data() as Map<String, dynamic>;
            // Try different possible fields for name
            if (data.containsKey("displayName")) {
              name = data["displayName"] as String;
            } else if (data.containsKey("name")) {
              name = data["name"] as String;
            } else if (data.containsKey("firstName") &&
                data.containsKey("lastName")) {
              name = "${data["firstName"]} ${data["lastName"]}";
            } else if (data.containsKey("email")) {
              // Extract name from email if no other info available
              final email = data["email"] as String;
              name = email
                  .split('@')[0]
                  .split('.')
                  .map((part) => part[0].toUpperCase() + part.substring(1))
                  .join(' ');
            }
          }
        } catch (e) {
          print("Error getting student name: $e");
          name = "Unknown Student";
        }

        leaderboard.add({
          "name": name,
          "points": points,
          "rank": i + 1,
          "isCurrentUser": studentId == userId,
        });
      }

      return leaderboard;
    } catch (e) {
      print("Error fetching class leaderboard: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getGlobalLeaderboard(
    int userRank,
    int userPoints,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      // Get all students
      final allStudentsSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .get();

      final Map<String, int> studentPoints = {};

      for (final studentDoc in allStudentsSnapshot.docs) {
        final studentId = studentDoc.id;
        final studentPointsCount = await _calculateStudentPoints(studentId);
        studentPoints[studentId] = studentPointsCount;
      }

      // Sort by points (descending)
      final studentPointsList = studentPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Create leaderboard entries with real names
      final List<Map<String, dynamic>> leaderboard = [];
      for (int i = 0; i < studentPointsList.length; i++) {
        final studentId = studentPointsList[i].key;
        final points = studentPointsList[i].value;

        // Get student name
        String name = "Unknown Student";
        try {
          final studentDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(studentId)
              .get();

          if (studentDoc.exists) {
            final data = studentDoc.data() as Map<String, dynamic>;
            // Try different possible fields for name
            if (data.containsKey("displayName")) {
              name = data["displayName"] as String;
            } else if (data.containsKey("name")) {
              name = data["name"] as String;
            } else if (data.containsKey("firstName") &&
                data.containsKey("lastName")) {
              name = "${data["firstName"]} ${data["lastName"]}";
            } else if (data.containsKey("email")) {
              // Extract name from email if no other info available
              final email = data["email"] as String;
              name = email
                  .split('@')[0]
                  .split('.')
                  .map((part) => part[0].toUpperCase() + part.substring(1))
                  .join(' ');
            }
          }
        } catch (e) {
          print("Error getting student name: $e");
          name = "Unknown Student";
        }

        leaderboard.add({
          "name": name,
          "points": points,
          "rank": i + 1,
          "isCurrentUser": studentId == userId,
        });
      }

      return leaderboard;
    } catch (e) {
      print("Error fetching global leaderboard: $e");
      return [];
    }
  }

  Future<int> _calculateStudentPoints(String userId) async {
    int points = 0;

    // Get classes this student is enrolled in
    final classStudentsSnapshot = await FirebaseFirestore.instance
        .collection("classStudents")
        .where("studentId", isEqualTo: userId)
        .get();

    if (classStudentsSnapshot.docs.isEmpty) {
      return 0;
    }

    final Set<String> classIds = {};
    for (final doc in classStudentsSnapshot.docs) {
      classIds.add(doc["classId"] as String);
    }

    // Calculate points
    for (final classId in classIds) {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection("tasks")
          .where("classId", isEqualTo: classId)
          .get();

      for (final taskDoc in tasksSnapshot.docs) {
        final taskId = taskDoc.id;

        // Check if student has completed this task
        final submissionQuery = await FirebaseFirestore.instance
            .collection("taskSubmissions")
            .where("taskId", isEqualTo: taskId)
            .where("studentId", isEqualTo: userId)
            .where(
              "status",
              whereIn: ["completed_unverified", "submitted", "verified"],
            )
            .limit(1)
            .get();

        if (submissionQuery.docs.isNotEmpty) {
          points += 5; // 5 points per completed task
        }
      }
    }

    return points;
  }

  Widget _buildLeaderRow(Map<String, dynamic> leader, Color sectionColor, bool isDarkMode, Color cardColor, Color textColor) {
    final isCurrentUser = leader["isCurrentUser"] as bool;
    final rank = leader["rank"] as int;
    final points = leader["points"] as int;
    final name = leader["name"] as String;

    Color rankColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = Colors.orange[700]!;
      rankIcon = Icons.military_tech;
    } else if (rank == 2) {
      rankColor = Colors.grey[700]!;
      rankIcon = Icons.star;
    } else if (rank == 3) {
      rankColor = Colors.brown[700]!;
      rankIcon = Icons.rocket_launch;
    } else {
      rankColor = sectionColor;
      rankIcon = Icons.emoji_events;
    }

    final rowCardColor = isCurrentUser 
        ? (isDarkMode ? Colors.blue[900] : Colors.blue[50]) 
        : cardColor;
    final rowBorderColor = isCurrentUser 
        ? (isDarkMode ? Colors.blue[700]! : Colors.blue[200]!) 
        : (isDarkMode ? Colors.grey[700]! : Colors.grey[200]!);
    final rowTextColor = isCurrentUser 
        ? (isDarkMode ? Colors.blue[200] : Colors.blue[800]) 
        : textColor;
    final pointsColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: rowCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: rowBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(rankIcon, color: rankColor, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                color: rowTextColor,
              ),
            ),
          ),
          Text(
            "${points} pts",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: pointsColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color, bool isDarkMode) {
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final textColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Icon(Icons.circle, color: color, size: 14)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: textColor),
        ),
      ],
    );
  }
}