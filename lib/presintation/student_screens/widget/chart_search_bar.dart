// widgets/chat_search_bar.dart
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const ChatSearchBar({super.key, required this.onSearchChanged});

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'search_hint':
            return "Sinfdoshlar va o'qituvchilarni qidirish...";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'search_hint':
            return "Поиск одноклассников и учителей...";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'search_hint':
            return "Search classmates and teachers...";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: _getLocalizedString('search_hint', context),
            hintStyle: GoogleFonts.poppins(
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[500],
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[500],
                size: 22,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.filter_list,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[500],
                size: 22,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 8,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
