import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // --- Global Dictionary ---
  // lib/providers/language_provider.dart

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'EduConnect',
      'search_hint': 'Search courses, tasks...',
      'quick_actions': 'Quick Actions',
      'courses': 'Courses',
      'tasks': 'Tasks',
      'students': 'Students',
      'announcements': 'Announcements',
      'upcoming_tasks': 'Upcoming Tasks',
      'recent_students': 'Recent Students',
    },
    'uz': {
      'app_title': 'EduConnect',
      'search_hint': 'Kurslar va vazifalarni qidirish...',
      'quick_actions': 'Tezkor Amallar',
      'courses': 'Kurslar',
      'tasks': 'Vazifalar',
      'students': 'Talabalar',
      'announcements': 'E\'lonlar',
      'upcoming_tasks': 'Yaqindagi vazifalar',
      'recent_students': 'Yaqinda qo\'shilgan talabalar',
    },
    'ru': {
      'app_title': 'EduConnect',
      'search_hint': 'Поиск курсов и задач...',
      'quick_actions': 'Быстрые действия',
      'courses': 'Курсы',
      'tasks': 'Задачи',
      'students': 'Студенты',
      'announcements': 'Объявления',
      'upcoming_tasks': 'Предстоящие задачи',
      'recent_students': 'Недавние студенты',
    },
  };

  // ✅ Safe Translation Method (Fixes the Null Error)
  String translate(String key) {
    // 1. Try current language
    final text = _localizedStrings[_currentLanguage]?[key];
    if (text != null) return text;

    // 2. Fallback to English
    final fallback = _localizedStrings['en']?[key];
    if (fallback != null) return fallback;

    // 3. Last resort: return the key name so the app doesn't crash
    return key;
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    _currentLanguage = language;
    notifyListeners();
  }
}
