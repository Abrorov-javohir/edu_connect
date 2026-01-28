// screens/settings_screen.dart
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'settings': return "Sozlamalar";
          case 'language': return "Til";
          case 'english': return "Inglizcha";
          case 'russian': return "Ruscha";
          case 'uzbek': return "O'zbekcha";
          case 'appearance': return "Ko'rinish";
          case 'system_default': return "Tizim standarti";
          case 'light_mode': return "Yorqin rejim";
          case 'dark_mode': return "Qorong'i rejim";
          case 'about': return "Ilova haqida";
          case 'version': return "Versiya 1.0.0";
          case 'description': return "Talabalar va o'qituvchilar uchun eng yaxshi ta'lim kompanioni.";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'settings': return "Настройки";
          case 'language': return "Язык";
          case 'english': return "Английский";
          case 'russian': return "Русский";
          case 'uzbek': return "Узбекский";
          case 'appearance': return "Внешний вид";
          case 'system_default': return "Системный по умолчанию";
          case 'light_mode': return "Светлый режим";
          case 'dark_mode': return "Темный режим";
          case 'about': return "О приложении";
          case 'version': return "Версия 1.0.0";
          case 'description': return "Ваш идеальный образовательный компаньон для студентов и преподавателей.";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'settings': return "Settings";
          case 'language': return "Language";
          case 'english': return "English";
          case 'russian': return "Russian";
          case 'uzbek': return "Uzbek";
          case 'appearance': return "Appearance";
          case 'system_default': return "System Default";
          case 'light_mode': return "Light Mode";
          case 'dark_mode': return "Dark Mode";
          case 'about': return "About";
          case 'version': return "Version 1.0.0";
          case 'description': return "Your ultimate educational companion for students and teachers.";
          default: return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          _getLocalizedString('settings', context),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              _buildSectionHeader(_getLocalizedString('language', context)),
              const SizedBox(height: 16),
              _buildLanguageOption(context, 'en', _getLocalizedString('english', context), '🇺🇸'),
              const SizedBox(height: 12),
              _buildLanguageOption(context, 'uz', _getLocalizedString('uzbek', context), '🇺🇿'),
              const SizedBox(height: 12),
              _buildLanguageOption(context, 'ru', _getLocalizedString('russian', context), '🇷🇺'),
              const SizedBox(height: 32),

              // Theme Section
              _buildSectionHeader(_getLocalizedString('appearance', context)),
              const SizedBox(height: 16),
              _buildThemeOption(context, 'system', _getLocalizedString('system_default', context), Icons.brightness_auto),
              const SizedBox(height: 12),
              _buildThemeOption(context, 'light', _getLocalizedString('light_mode', context), Icons.light_mode),
              const SizedBox(height: 12),
              _buildThemeOption(context, 'dark', _getLocalizedString('dark_mode', context), Icons.dark_mode),
              const SizedBox(height: 32),

              // About Section
              _buildSectionHeader(_getLocalizedString('about', context)),
              const SizedBox(height: 16),
              _buildAboutCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name, String flag) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () => languageProvider.setLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!
                    : Colors.grey[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              if (languageProvider.currentLanguage == code)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[400]
                        : Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String code, String name, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () {
          switch (code) {
            case 'light':
              themeProvider.setTheme(ThemeMode.light);
              break;
            case 'dark':
              themeProvider.setTheme(ThemeMode.dark);
              break;
            case 'system':
            default:
              themeProvider.setTheme(ThemeMode.system);
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!
                    : Colors.grey[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, 
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]
                        : Colors.blue[700], 
                    size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              if ((code == 'system' && themeProvider.themeMode == ThemeMode.system) ||
                  (code == 'light' && themeProvider.themeMode == ThemeMode.light) ||
                  (code == 'dark' && themeProvider.themeMode == ThemeMode.dark))
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[400]
                        : Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[900]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.info, 
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[300]
                          : Colors.blue[700], 
                      size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "EduConnect",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getLocalizedString('version', context),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getLocalizedString('description', context),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}