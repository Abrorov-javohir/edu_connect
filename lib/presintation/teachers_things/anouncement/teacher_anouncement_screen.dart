// teacher_announcement_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/anouncement/teacher_anouncement_header.dart';
import 'package:edu_connect/presintation/teachers_things/anouncement/teacher_anouncement_list.dart';
import 'package:edu_connect/presintation/teachers_things/anouncement/teacher_create_anouncement.dart';
import 'package:edu_connect/presintation/teachers_things/anouncement/teacher_edit_anouncement.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/anouncement_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/anouncement_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';

class TeacherAnnouncementScreen extends StatefulWidget {
  const TeacherAnnouncementScreen({super.key});

  @override
  State<TeacherAnnouncementScreen> createState() =>
      _TeacherAnnouncementScreenState();
}

class _TeacherAnnouncementScreenState extends State<TeacherAnnouncementScreen> {
  String _searchQuery = '';
  String _sortBy = 'date'; // 'title', 'date'
  bool _sortAscending = false; // Most recent first

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'announcements':
            return "E'lonlar";
          case 'create_announcement':
            return "E'lon Yaratish";
          case 'search_announcements':
            return "E'lonlarni qidirish...";
          case 'sort_by':
            return "Saralash";
          case 'title':
            return "Sarlavha";
          case 'date':
            return "Sana";
          case 'ascending':
            return "O'suvchi";
          case 'descending':
            return "Kamayuvchi";
          case 'edit':
            return "Tahrirlash";
          case 'delete':
            return "O'chirish";
          case 'no_announcements':
            return "Hech qanday e'lon topilmadi";
          case 'no_announcements_yet':
            return "Hali e'lonlar yo'q";
          case 'create_first_announcement':
            return "Birinchi e'loningizni yarating";
          case 'class':
            return "Sinf";
          case 'loading_class':
            return "Sinf yuklanmoqda...";
          case 'unknown_class':
            return "Noma'lum Sinf";
          case 'event_dates':
            return "Tadbir Sanalari";
          case 'posted_on':
            return "Joylandi";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'teacher_announcements':
            return "Объявления Учителя";
          case 'create_announcement':
            return "Создать Объявление";
          case 'search_announcements':
            return "Поиск объявлений...";
          case 'sort_by':
            return "Сортировать по";
          case 'title':
            return "Заголовок";
          case 'date':
            return "Дата";
          case 'ascending':
            return "По возрастанию";
          case 'descending':
            return "По убыванию";
          case 'edit':
            return "Редактировать";
          case 'delete':
            return "Удалить";
          case 'no_announcements':
            return "Объявления не найдены";
          case 'no_announcements_yet':
            return "Объявлений пока нет";
          case 'create_first_announcement':
            return "Создайте свое первое объявление";
          case 'class':
            return "Класс";
          case 'loading_class':
            return "Загрузка класса...";
          case 'unknown_class':
            return "Неизвестный Класс";
          case 'event_dates':
            return "Даты Событий";
          case 'posted_on':
            return "Опубликовано";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'announcements':
            return "Announcements";
          case 'create_announcement':
            return "Create Announcement";
          case 'search_announcements':
            return "Search announcements...";
          case 'sort_by':
            return "Sort By";
          case 'title':
            return "Title";
          case 'date':
            return "Date";
          case 'ascending':
            return "Ascending";
          case 'descending':
            return "Descending";
          case 'edit':
            return "Edit";
          case 'delete':
            return "Delete";
          case 'no_announcements':
            return "No announcements found";
          case 'no_announcements_yet':
            return "No announcements yet";
          case 'create_first_announcement':
            return "Create your first announcement";
          case 'class':
            return "Class";
          case 'loading_class':
            return "Loading class...";
          case 'unknown_class':
            return "Unknown Class";
          case 'event_dates':
            return "Event Dates";
          case 'posted_on':
            return "Posted on";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AnnouncementsCubit>().loadAnnouncements();
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
          _getLocalizedString('announcements'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Theme.of(context).appBarTheme.foregroundColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementCreateScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnnouncementsHeader(
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                context.read<AnnouncementsCubit>().searchAnnouncements(value);
              },
              onSortPressed: _showSortOptions,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
                builder: (context, state) {
                  if (state is AnnouncementsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AnnouncementsError) {
                    return Center(child: Text("Error: ${state.error}"));
                  } else if (state is AnnouncementsLoaded) {
                    return AnnouncementsList(
                      announcements: state.announcements,
                      onDelete: (announcementId) {
                        context.read<AnnouncementsCubit>().deleteAnnouncement(
                          announcementId,
                        );
                      },
                      onEdit: (context, announcementId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherAnnouncementEditScreen(
                              announcementId: announcementId,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text(_getLocalizedString('no_announcements')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('sort_options'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          RadioListTile<String>(
                            title: Text(
                              _getLocalizedString('title'),
                              style: GoogleFonts.poppins(),
                            ),
                            value: 'title',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                              _applySorting();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<String>(
                            title: Text(
                              _getLocalizedString('date'),
                              style: GoogleFonts.poppins(),
                            ),
                            value: 'date',
                            groupValue: _sortBy,
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                              _applySorting();
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(
                              _sortAscending
                                  ? _getLocalizedString('ascending')
                                  : _getLocalizedString('descending'),
                              style: GoogleFonts.poppins(),
                            ),
                            value: _sortAscending,
                            onChanged: (value) {
                              setState(() {
                                _sortAscending = value;
                              });
                              _applySorting();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applySorting() {
    if (context.read<AnnouncementsCubit>().state is! AnnouncementsLoaded)
      return;

    final announcements =
        (context.read<AnnouncementsCubit>().state as AnnouncementsLoaded)
            .announcements;
    final sorted = List<DocumentSnapshot>.from(announcements);

    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      int result = 0;
      switch (_sortBy) {
        case 'title':
          result = (dataA["title"] ?? "").toLowerCase().compareTo(
            (dataB["title"] ?? "").toLowerCase(),
          );
          break;
        case 'date':
          final dateA =
              (dataA["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
          final dateB =
              (dataB["createdAt"] as Timestamp?)?.toDate() ?? DateTime(0);
          result = dateA.compareTo(dateB);
          break;
      }
      return _sortAscending ? result : -result;
    });

    context.read<AnnouncementsCubit>().emit(AnnouncementsLoaded(sorted));
  }
}
