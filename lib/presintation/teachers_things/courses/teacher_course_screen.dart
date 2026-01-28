// teacher_courses_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/courses/teacher_create_courses.dart';
import 'package:edu_connect/presintation/teachers_things/courses/teacher_edit_courses.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/course_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/course_state.dart';
import 'package:edu_connect/presintation/teachers_things/courses/Teacher_course_header.dart';
import 'package:edu_connect/presintation/teachers_things/courses/teacher_course_list.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'date', 'room'
  bool _sortAscending = true;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'courses': return "Fanlar";
          case 'no_courses_found': return "Hech qanday fan topilmadi";
          case 'create_course': return "Fan Yaratish";
          case 'sort_by': return "Saralash";
          case 'course_name': return "Fan Nomi";
          case 'creation_date': return "Yaratilgan Sana";
          case 'room_number': return "Xona Raqami";
          case 'ascending': return "O'sish Bo'yicha";
          case 'descending': return "Kamayish Bo'yicha";
          case 'edit': return "Tahrirlash";
          case 'delete': return "O'chirish";
          case 'search_courses': return "Fanlarni qidirish...";
          case 'sort_options': return "Saralash Sozlamalari";
          case 'loading_class': return "Sinf yuklanmoqda...";
          case 'unknown_class': return "Noma'lum Sinf";
          case 'created_on': return "Yaratilgan";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'teacher_courses': return "Мои Курсы";
          case 'no_courses_found': return "Курсы не найдены";
          case 'create_course': return "Создать Курс";
          case 'sort_by': return "Сортировать по";
          case 'course_name': return "Название Курса";
          case 'creation_date': return "Дата Создания";
          case 'room_number': return "Номер Комнаты";
          case 'ascending': return "По возрастанию";
          case 'descending': return "По убыванию";
          case 'edit': return "Редактировать";
          case 'delete': return "Удалить";
          case 'search_courses': return "Поиск курсов...";
          case 'sort_options': return "Параметры Сортировки";
          case 'loading_class': return "Загрузка класса...";
          case 'unknown_class': return "Неизвестный Класс";
          case 'created_on': return "Создан";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'courses': return "Courses";
          case 'no_courses_found': return "No courses found";
          case 'create_course': return "Create Course";
          case 'sort_by': return "Sort By";
          case 'course_name': return "Course Name";
          case 'creation_date': return "Creation Date";
          case 'room_number': return "Room Number";
          case 'ascending': return "Ascending";
          case 'descending': return "Descending";
          case 'edit': return "Edit";
          case 'delete': return "Delete";
          case 'search_courses': return "Search courses...";
          case 'sort_options': return "Sort Options";
          case 'loading_class': return "Loading class...";
          case 'unknown_class': return "Unknown Class";
          case 'created_on': return "Created on";
          default: return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().loadCourses();
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
          _getLocalizedString('courses'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
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
                  builder: (context) => const TeacherCourseCreateScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesError) {
            return Center(child: Text("Error: ${state.error}"));
          } else if (state is CoursesLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CoursesHeader(
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      context.read<CoursesCubit>().searchCourses(value);
                    },
                    onSortPressed: _showSortOptions,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: CoursesList(
                      courses: state.courses,
                      onDelete: (courseId) {
                        context.read<CoursesCubit>().deleteCourse(courseId);
                      },
                      onEdit: (context, courseId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseEditScreen(courseId: courseId),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("No courses"));
        },
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
                              _getLocalizedString('course_name'),
                              style: GoogleFonts.poppins(),
                            ),
                            value: 'name',
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
                              _getLocalizedString('creation_date'),
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
                          RadioListTile<String>(
                            title: Text(
                              _getLocalizedString('room_number'),
                              style: GoogleFonts.poppins(),
                            ),
                            value: 'room',
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
    if (context.read<CoursesCubit>().state is! CoursesLoaded) return;
    
    final courses = (context.read<CoursesCubit>().state as CoursesLoaded).courses;
    context.read<CoursesCubit>().sortCourses(
      courses: courses,
      sortBy: _sortBy,
      sortAscending: _sortAscending,
    );
  }
}

