import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class CoursesHeader extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onSortPressed;

  const CoursesHeader({
    super.key,
    required this.onSearchChanged,
    required this.onSortPressed,
  });

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'search_courses': return "Fanlarni qidirish...";
          case 'sort': return "Saralash";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'search_courses': return "Поиск курсов...";
          case 'sort': return "Сортировать";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'search_courses': return "Search courses...";
          case 'sort': return "Sort";
          default: return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.blue[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: _getLocalizedString('search_courses', context),
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[300]!
                          : Colors.blue[700]!,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]
                    : Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.sort,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onSortPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
