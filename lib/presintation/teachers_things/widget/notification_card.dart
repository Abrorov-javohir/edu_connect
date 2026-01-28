// widgets/notification_card.dart (Beautiful UI with Localization)
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class NotificationCard extends StatelessWidget {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String taskId;
  final String studentId;
  final Function(String) onMarkAsRead;
  final Function(String, String, String) onAction;

  const NotificationCard({
    super.key,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.taskId,
    required this.studentId,
    required this.onMarkAsRead,
    required this.onAction,
  });

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'new':
            return "Yangi";
          case 'task_completed':
            return "Vazifa bajarildi";
          case 'proof_submitted':
            return "Izoh yuborildi";
          case 'verified':
            return "Tekshirildi";
          case 'rejected':
            return "Rad etildi";
          case 'days_ago':
            return "kun oldin";
          case 'hours_ago':
            return "soat oldin";
          case 'minutes_ago':
            return "daqiqa oldin";
          case 'just_now':
            return "hozir";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'new_badge':
            return "Новое";
          case 'task_completed':
            return "Задание выполнено";
          case 'proof_submitted':
            return "Подтверждение отправлено";
          case 'verified':
            return "Проверено";
          case 'rejected':
            return "Отклонено";
          case 'days_ago':
            return "дней назад";
          case 'hours_ago':
            return "часов назад";
          case 'minutes_ago':
            return "минут назад";
          case 'just_now':
            return "только что";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'new':
            return "New";
          case 'task_completed':
            return "Task Completed";
          case 'proof_submitted':
            return "Proof Submitted";
          case 'verified':
            return "Verified";
          case 'rejected':
            return "Rejected";
          case 'days_ago':
            return "days ago";
          case 'hours_ago':
            return "hours ago";
          case 'minutes_ago':
            return "minutes ago";
          case 'just_now':
            return "just now";
          default:
            return key;
        }
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case "task_completed":
        return Colors.green;
      case "proof_submitted":
        return Colors.blue;
      case "verified":
        return Colors.purple;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case "task_completed":
        return Icons.check_circle_outline;
      case "proof_submitted":
        return Icons.cloud_upload_outlined;
      case "verified":
        return Icons.verified_user_outlined;
      case "rejected":
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0)
      return "${difference.inDays} ${_getLocalizedString('days_ago', context)}";
    if (difference.inHours > 0)
      return "${difference.inHours} ${_getLocalizedString('hours_ago', context)}";
    if (difference.inMinutes > 0)
      return "${difference.inMinutes} ${_getLocalizedString('minutes_ago', context)}";
    return _getLocalizedString('just_now', context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isRead ? 0 : 2,
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _getTypeColor().withOpacity(isRead ? 0.1 : 0.3),
            width: isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (!isRead) onMarkAsRead(notificationId);
            onAction(taskId, studentId, type);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isRead
                  ? null
                  : LinearGradient(
                      colors: [
                        _getTypeColor().withOpacity(0.05),
                        isDarkMode ? Colors.grey[800]! : Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getTypeColor().withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: _getTypeColor(),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getLocalizedString(type, context),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(),
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getLocalizedString('new', context),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimestamp(timestamp, context),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
