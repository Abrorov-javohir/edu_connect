// widgets/task_status_badge.dart
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TaskStatusBadge extends StatelessWidget {
  final String status;

  const TaskStatusBadge({super.key, required this.status});

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'completed':
            return "TUGATILDI";
          case 'proof_submitted':
            return "ISBAT YUBORILDI";
          case 'verified':
            return "TEKSHIRILDI";
          case 'rejected':
            return "QAYTARILDI";
          case 'pending':
            return "KUTISHDA";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'completed':
            return "ВЫПОЛНЕНО";
          case 'proof_submitted':
            return "ДОКАЗАТЕЛЬСТВО ОТПРАВЛЕНО";
          case 'verified':
            return "ПРОВЕРЕНО";
          case 'rejected':
            return "ОТКЛОНЕНО";
          case 'pending':
            return "В ОЖИДАНИИ";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'completed':
            return "COMPLETED";
          case 'proof_submitted':
            return "PROOF SUBMITTED";
          case 'verified':
            return "VERIFIED";
          case 'rejected':
            return "REJECTED";
          case 'pending':
            return "PENDING";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case "completed_unverified":
        text = _getLocalizedString('completed', context);
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "submitted":
        text = _getLocalizedString('proof_submitted', context);
        color = Colors.blue;
        icon = Icons.file_upload;
        break;
      case "verified":
        text = _getLocalizedString('verified', context);
        color = Colors.purple;
        icon = Icons.verified;
        break;
      case "rejected":
        text = _getLocalizedString('rejected', context);
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        text = _getLocalizedString('pending', context);
        color = Colors.grey;
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
