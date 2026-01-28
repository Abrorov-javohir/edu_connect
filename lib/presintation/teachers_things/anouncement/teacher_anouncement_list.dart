// announcement_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class AnnouncementsList extends StatelessWidget {
  final List<DocumentSnapshot> announcements;
  final Function(String) onDelete;
  final Function(BuildContext, String) onEdit;

  const AnnouncementsList({
    super.key,
    required this.announcements,
    required this.onDelete,
    required this.onEdit,
  });

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'no_announcements_found': return "Hech qanday e'lon topilmadi";
          case 'class': return "Sinf";
          case 'loading_class': return "Sinf yuklanmoqda...";
          case 'unknown_class': return "Noma'lum Sinf";
          case 'event_dates': return "Tadbir Sanalari";
          case 'posted_on': return "Joylandi";
          case 'edit': return "Tahrirlash";
          case 'delete': return "O'chirish";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'no_announcements_found': return "Объявления не найдены";
          case 'class': return "Класс";
          case 'loading_class': return "Загрузка класса...";
          case 'unknown_class': return "Неизвестный Класс";
          case 'event_dates': return "Даты Событий";
          case 'posted_on': return "Опубликовано";
          case 'edit': return "Редактировать";
          case 'delete': return "Удалить";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'no_announcements_found': return "No announcements found";
          case 'class': return "Class";
          case 'loading_class': return "Loading class...";
          case 'unknown_class': return "Unknown Class";
          case 'event_dates': return "Event Dates";
          case 'posted_on': return "Posted on";
          case 'edit': return "Edit";
          case 'delete': return "Delete";
          default: return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange[900]?.withOpacity(0.2)
                      : Colors.orange[50],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange[700]!
                        : Colors.orange[100]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.campaign,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange[300]
                      : Colors.orange[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getLocalizedString('no_announcements_yet', context),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _getLocalizedString('create_first_announcement', context),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        final data = announcement.data() as Map<String, dynamic>;

        final startDate = (data["startDate"] as Timestamp?)?.toDate();
        final endDate = (data["endDate"] as Timestamp?)?.toDate();

        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 600),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[200]!,
                width: 1,
              ),
            ),
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnnouncementHeader(
                    context,
                    data,
                    announcement.id,
                    startDate,
                    endDate,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data["content"] ?? "No content provided",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                  // SHOW CLASS NAME
                  if (data["classId"] != null)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("classes")
                          .doc(data["classId"])
                          .get(),
                      builder: (context, classSnapshot) {
                        if (classSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[900]?.withOpacity(0.2)
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[700]!
                                    : Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getLocalizedString('loading_class', context),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[300]
                                    : Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        if (classSnapshot.hasData && classSnapshot.data!.exists) {
                          final classData = classSnapshot.data!.data() as Map<String, dynamic>;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[900]?.withOpacity(0.2)
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[700]!
                                    : Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "${_getLocalizedString('class', context)}: ${classData["className"] ?? _getLocalizedString('unknown_class', context)}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blue[300]
                                    : Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[900]?.withOpacity(0.2)
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[700]!
                                  : Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "${_getLocalizedString('class', context)}: ${_getLocalizedString('unknown_class', context)}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[300]
                                  : Colors.blue[700],
                            ),
                          ),
                        );
                      },
                    ),
                  if (startDate != null && endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange[900]?.withOpacity(0.2)
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.orange[700]!
                                : Colors.orange[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.orange[300]
                                  : Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_getLocalizedString('event_dates', context)}: ${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.orange[300]
                                    : Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${_getLocalizedString('posted_on', context)}: ${(data["createdAt"] as Timestamp?)?.toDate().day ?? ""}/${(data["createdAt"] as Timestamp?)?.toDate().month ?? ""}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementHeader(
    BuildContext context,
    Map<String, dynamic> data,
    String announcementId,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.orange[900]?.withOpacity(0.2)
                : Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange[700]!
                  : Colors.orange[100]!,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.campaign,
            color: Colors.orange,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["title"] ?? "No Title",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data["content"]?.toString().substring(
                      0,
                      (data["content"]?.length ?? 0) > 50
                          ? 50
                          : (data["content"]?.length ?? 0),
                    ) ??
                    "No Content",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          onSelected: (value) {
            if (value == 'edit') {
              onEdit(context, announcementId);
            } else if (value == 'delete') {
              onDelete(announcementId);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(
                _getLocalizedString('edit', context),
                style: GoogleFonts.poppins(),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                _getLocalizedString('delete', context),
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

