// language_selection_screen.dart
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {"code": "en", "name": "English", "flag": "🇺🇸"},
    {"code": "uz", "name": "O'zbek", "flag": "🇺🇿"},
    {"code": "ru", "name": "Русский", "flag": "🇷🇺"},
  ];

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'welcome':
            return "Til Tanlang";
          case 'choose_language':
            return "Tilni tanlang";
          case 'select_preferred_language':
            return "Sizning afzal ko'rgan tilizni tanlang";
          case 'continue':
            return "Davom etish";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'welcome':
            return "Выберите Язык";
          case 'choose_language':
            return "Выберите язык";
          case 'select_preferred_language':
            return "Выберите предпочтительный язык";
          case 'continue':
            return "Продолжить";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'welcome':
            return "Welcome";
          case 'choose_language':
            return "Choose Language";
          case 'select_preferred_language':
            return "Select your preferred language";
          case 'continue':
            return "Continue";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code');

    if (savedLanguage != null) {
      setState(() {
        _selectedLanguage = savedLanguage;
      });
    } else {
      // Default to English if no language is saved
      setState(() {
        _selectedLanguage = 'en';
      });
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    context.read<LanguageProvider>().setLanguage(languageCode);
    _saveLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A6CF7), Color(0xFF6C8CFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.language,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getLocalizedString('welcome'),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getLocalizedString('select_preferred_language'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Language Selection
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 800),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _languages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = _selectedLanguage == language["code"];

                      return GestureDetector(
                        onTap: () => _selectLanguage(language["code"]!),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[900]?.withOpacity(0.3)
                                      : Colors.blue[50]
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors.grey[800]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[600]!
                                        : Colors.blue[300]!)
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]!
                                        : Colors.grey[200]!),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color:
                                      (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.blue
                                              : Colors.blue)
                                          .withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    language["flag"]!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  language["name"]!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.blue[300]
                                              : Colors.blue[700])
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[300]
                                      : Colors.blue[700],
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Continue Button
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 800),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _selectedLanguage != null
                          ? () {
                              // Navigate to onboarding screen
                              Navigator.pushReplacementNamed(
                                context,
                                '/onboarding',
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedLanguage != null
                            ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[800]
                                  : Colors.blue
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        _getLocalizedString('continue'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
