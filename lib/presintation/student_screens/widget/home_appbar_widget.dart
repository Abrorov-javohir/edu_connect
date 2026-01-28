// widgets/home_appbar_widget.dart
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatefulWidget {
  final VoidCallback onProfileTap;
  final bool isDarkMode;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    required this.isDarkMode,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _studentName = "Student";
  bool _loading = true;

  // Translation map
  Map<String, Map<String, String>> translations = {
    'en': {'welcomeBack': 'Welcome back 👋', 'student': 'Student'},
    'uz': {'welcomeBack': 'Xush Kelibsiz Dostim 👋', 'student': 'Talaba'},
    'ru': {'welcomeBack': 'С возвращением 👋', 'student': 'Студент'},
  };

  String translate(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return translations[languageProvider.currentLanguage]?[key] ??
        translations['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final name = data["name"] ?? data["displayName"] ?? "Student";
          setState(() {
            _studentName = name;
            _loading = false;
          });
        } else {
          setState(() {
            _loading = false;
          });
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.white70;
    final iconColor = widget.isDarkMode ? Colors.white : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6C8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          // Profile Section - Entire area is clickable
          GestureDetector(
            onTap: widget.onProfileTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Row(
                  children: [
                    // Circular Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Icon(Icons.person, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Welcome Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate('welcomeBack'),
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _loading ? "Loading..." : _studentName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Notifications Icon (Right)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications, color: iconColor, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
