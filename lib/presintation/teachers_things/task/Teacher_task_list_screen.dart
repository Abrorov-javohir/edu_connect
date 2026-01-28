// teacher_task_list_screen.dart (Fixed Navigation)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/task/task_create_screen.dart';
import 'package:edu_connect/presintation/teachers_things/task/teacher_task_detail_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherTaskListScreen extends StatelessWidget {
  const TeacherTaskListScreen({super.key});

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'my_tasks':
            return "Mening Vazifalarim";
          case 'no_tasks_yet':
            return "Hali vazifalar yo'q";
          case 'create_first_task':
            return "Birinchi vazifangizni yarating";
          case 'create_task':
            return "Vazifa Yaratish";
          case 'view_details':
            return "Tafsilotlarni Ko'rish";
          case 'overdue':
            return "Kechikdi";
          case 'due_today':
            return "Bugun muddati";
          case 'days_left':
            return " kun qoldi";
          case 'no_description':
            return "Tavsif mavjud emas";
          case 'no_title':
            return "Sarlavha yo'q";
          case 'class':
            return "Sinf";
          case 'unknown_class':
            return "Noma'lum Sinf";
          case 'loading_class':
            return "Sinf yuklanmoqda...";
          case 'create_task_button':
            return "Vazifa Yaratish";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'teacher_tasks':
            return "Мои Задания";
          case 'no_tasks_found':
            return "Задания не найдены";
          case 'create_first_task':
            return "Создайте свое первое задание";
          case 'create_task':
            return "Создать Задание";
          case 'view_details':
            return "Просмотреть Детали";
          case 'overdue':
            return "Просрочено";
          case 'due_today':
            return "Срок сегодня";
          case 'days_left':
            return " дней осталось";
          case 'no_description':
            return "Описание отсутствует";
          case 'no_title':
            return "Нет заголовка";
          case 'class':
            return "Класс";
          case 'unknown_class':
            return "Неизвестный Класс";
          case 'loading_class':
            return "Загрузка класса...";
          case 'create_task_button':
            return "Создать Задание";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'my_tasks':
            return "My Tasks";
          case 'no_tasks_yet':
            return "No tasks yet";
          case 'create_first_task':
            return "Create your first task";
          case 'create_task':
            return "Create Task";
          case 'view_details':
            return "View Details";
          case 'overdue':
            return "Overdue";
          case 'due_today':
            return "Due Today";
          case 'days_left':
            return " days left";
          case 'no_description':
            return "No description provided";
          case 'no_title':
            return "No Title";
          case 'class':
            return "Class";
          case 'unknown_class':
            return "Unknown Class";
          case 'loading_class':
            return "Loading class...";
          case 'create_task_button':
            return "Create Task";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getLocalizedString('my_tasks', context),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue[800]
            : Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherTaskCreateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tasks")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
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
                        Icons.task_outlined,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('no_tasks_yet', context),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _getLocalizedString('create_first_task', context),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TeacherTaskCreateScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[800]
                            : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getLocalizedString('create_task_button', context),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>?;
              if (data == null) return const SizedBox.shrink();

              final deadlineTimestamp = data["deadline"] as Timestamp?;
              if (deadlineTimestamp == null) return const SizedBox.shrink();

              final deadline = deadlineTimestamp.toDate();
              final now = DateTime.now();
              final isOverdue = deadline.isBefore(now);
              final daysLeft = deadline.difference(now).inDays;

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                duration: const Duration(milliseconds: 600),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isOverdue
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.red[700]!
                                : Colors.red[200]!)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data["title"] ??
                                    _getLocalizedString('no_title', context),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.red[900]?.withOpacity(0.2)
                                          : Colors.red[50])
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green[900]?.withOpacity(0.2)
                                          : Colors.green[50]),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOverdue
                                      ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.red[700]!
                                            : Colors.red[200]!)
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green[700]!
                                            : Colors.green[200]!),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                isOverdue
                                    ? _getLocalizedString('overdue', context)
                                    : daysLeft == 0
                                    ? _getLocalizedString('due_today', context)
                                    : "$daysLeft${_getLocalizedString('days_left', context)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isOverdue
                                      ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.red[300]
                                            : Colors.red[700])
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green[300]
                                            : Colors.green[700]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data["description"] ??
                              _getLocalizedString('no_description', context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
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
                              if (classSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[900]?.withOpacity(0.2)
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.blue[700]!
                                          : Colors.blue[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getLocalizedString(
                                      'loading_class',
                                      context,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.blue[300]
                                          : Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }

                              if (classSnapshot.hasData &&
                                  classSnapshot.data!.exists) {
                                final classData =
                                    classSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[900]?.withOpacity(0.2)
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.blue[700]!
                                          : Colors.blue[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "${_getLocalizedString('class', context)}: ${classData["className"] ?? _getLocalizedString('unknown_class', context)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
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
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[900]?.withOpacity(0.2)
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[700]!
                                        : Colors.blue[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "${_getLocalizedString('class', context)}: ${_getLocalizedString('unknown_class', context)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[300]
                                        : Colors.blue[700],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: isOverdue
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.red[300]
                                        : Colors.red[600])
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[300]
                                        : Colors.blue[600]),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${_getLocalizedString('deadline', context)}: ${deadline.day}/${deadline.month}/${deadline.year}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isOverdue
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.red[300]
                                          : Colors.red[600])
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              // ✅ FIXED: Correct navigation to task detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TeacherTaskDetailScreen(taskId: task.id),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.blue[900]?.withOpacity(0.2)
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.blue[700]!
                                      : Colors.blue[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getLocalizedString(
                                      'view_details',
                                      context,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.blue[300]
                                          : Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.blue[300]
                                        : Colors.blue[700],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
