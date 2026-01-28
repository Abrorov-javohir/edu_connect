import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';

class EmptySection extends StatelessWidget {
  final String text;

  const EmptySection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // 1. Access Provider
    final lang = Provider.of<LanguageProvider>(context);

    // 2. Define Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic styling based on Brightness
    final containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final textColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        // Add a subtle border for dark mode visibility
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Center(
        child: Text(
          // ✅ We use translate here to ensure the passed key becomes localized text
          lang.translate(text),
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
