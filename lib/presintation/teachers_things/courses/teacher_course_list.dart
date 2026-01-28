// courses_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class CoursesList extends StatelessWidget {
  final List<DocumentSnapshot> courses;
  final Function(String) onDelete;
  final Function(BuildContext, String) onEdit;

  const CoursesList({
    super.key,
    required this.courses,
    required this.onDelete,
    required this.onEdit,
  });

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'no_courses_found': return "Hech qanday fan topilmadi";
          case 'class': return "Sinf";
          case 'loading_class': return "Sinf yuklanmoqda...";
          case 'unknown_class': return "Noma'lum Sinf";
          case 'created_on': return "Yaratilgan";
          case 'edit': return "Tahrirlash";
          case 'delete': return "O'chirish";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'no_courses_found': return "Курсы не найдены";
          case 'class': return "Класс";
          case 'loading_class': return "Загрузка класса...";
          case 'unknown_class': return "Неизвестный Класс";
          case 'created_on': return "Создан";
          case 'edit': return "Редактировать";
          case 'delete': return "Удалить";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'no_courses_found': return "No courses found";
          case 'class': return "Class";
          case 'loading_class': return "Loading class...";
          case 'unknown_class': return "Unknown Class";
          case 'created_on': return "Created on";
          case 'edit': return "Edit";
          case 'delete': return "Delete";
          default: return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
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
                      ? Colors.blue[900]?.withOpacity(0.2)
                      : Colors.blue[50],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[700]!
                        : Colors.blue[100]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[300]
                      : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getLocalizedString('no_courses_found', context),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final data = course.data() as Map<String, dynamic>;

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
                  _buildCourseHeader(
                    context,
                    data,
                    course.id,
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${_getLocalizedString('created_on', context)}: ${(data["createdAt"] as Timestamp?)?.toDate().day ?? ""}/${(data["createdAt"] as Timestamp?)?.toDate().month ?? ""}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseHeader(
    BuildContext context,
    Map<String, dynamic> data,
    String courseId,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[900]?.withOpacity(0.2)
                : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[700]!
                  : Colors.blue[100]!,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.book,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["courseName"] ?? "No Name",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Room: ${data["roomNumber"] ?? "N/A"}",
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
              onEdit(context, courseId);
            } else if (value == 'delete') {
              onDelete(courseId);
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

