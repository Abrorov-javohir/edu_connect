// teacher_task_detail_screen.dart (Fixed)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/task/task_edit_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherTaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TeacherTaskDetailScreen({super.key, required this.taskId});

  String _getLocalizedString(String key, BuildContext context) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'task_details':
            return "Vazifa Tafsilotlari";
          case 'no_task_found':
            return "Vazifa topilmadi ❌";
          case 'deadline':
            return "Muddat";
          case 'task_information':
            return "Vazifa Haqida Ma'lumot";
          case 'created_at':
            return "Yaratilgan";
          case 'edit_task':
            return "Vazifani Tahrirlash";
          case 'delete_task':
            return "Vazifani O'chirish";
          case 'confirm_delete':
            return "O'chirishni Tasdiqlang";
          case 'delete_confirm_message':
            return "Haqiqatan ham ushbu vazifani o'chirmoqchimisiz?";
          case 'cancel':
            return "Bekor Qilish";
          case 'delete':
            return "O'chirish";
          case 'class':
            return "Sinf";
          case 'unknown_class':
            return "Noma'lum Sinf";
          case 'loading_class':
            return "Sinf yuklanmoqda...";
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
          case 'unknown_date':
            return "Noma'lum sana";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'task_details':
            return "Детали Задания";
          case 'no_task_found':
            return "Задание не найдено ❌";
          case 'deadline':
            return "Срок";
          case 'task_information':
            return "Информация о задании";
          case 'created_at':
            return "Создано";
          case 'edit_task':
            return "Редактировать Задание";
          case 'delete_task':
            return "Удалить Задание";
          case 'confirm_delete':
            return "Подтвердите Удаление";
          case 'delete_confirm_message':
            return "Вы уверены, что хотите удалить это задание?";
          case 'cancel':
            return "Отмена";
          case 'delete':
            return "Удалить";
          case 'class':
            return "Класс";
          case 'unknown_class':
            return "Неизвестный Класс";
          case 'loading_class':
            return "Загрузка класса...";
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
          case 'unknown_date':
            return "Неизвестная дата";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'task_details':
            return "Task Details";
          case 'no_task_found':
            return "Task not found ❌";
          case 'deadline':
            return "Deadline";
          case 'task_information':
            return "Task Information";
          case 'created_at':
            return "Created At";
          case 'edit_task':
            return "Edit Task";
          case 'delete_task':
            return "Delete Task";
          case 'confirm_delete':
            return "Confirm Delete";
          case 'delete_confirm_message':
            return "Are you sure you want to delete this task?";
          case 'cancel':
            return "Cancel";
          case 'delete':
            return "Delete";
          case 'class':
            return "Class";
          case 'unknown_class':
            return "Unknown Class";
          case 'loading_class':
            return "Loading class...";
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
          case 'unknown_date':
            return "Unknown Date";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getLocalizedString('task_details', context),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("tasks")
            .doc(taskId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
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
                            ? Colors.red[900]?.withOpacity(0.2)
                            : Colors.red[50],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.red[700]!
                              : Colors.red[200]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[300]
                            : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedString('no_task_found', context),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final doc = snapshot.data!;
          final task = doc.data() as Map<String, dynamic>?;

          if (task == null) {
            return Center(
              child: Text(
                "Task data not available",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            );
          }

          final deadlineTimestamp = task["deadline"] as Timestamp?;
          if (deadlineTimestamp == null) {
            return Center(
              child: Text(
                _getLocalizedString('no_deadline_set', context),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            );
          }

          final deadline = deadlineTimestamp.toDate();
          final now = DateTime.now();
          final isOverdue = deadline.isBefore(now);
          final daysLeft = deadline.difference(now).inDays;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isOverdue
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.red[900]!
                                    : Colors.red[50]!)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFF4A6CF7)),
                          isOverdue
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.red[800]!
                                    : Colors.red[100]!)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF42A5F5)
                                    : const Color(0xFF6C8CFF)),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isOverdue
                                      ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.red
                                            : Colors.red)
                                      : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.blue
                                            : Colors.blue))
                                  .withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task["title"] ??
                              _getLocalizedString('no_title', context),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.red[700]?.withOpacity(0.3)
                                      : Colors.red[200])
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.green[700]?.withOpacity(0.3)
                                      : Colors.green[200]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isOverdue
                                ? _getLocalizedString('overdue', context)
                                : daysLeft == 0
                                ? _getLocalizedString('due_today', context)
                                : "$daysLeft${_getLocalizedString('days_left', context)}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isOverdue
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.red[200]
                                        : Colors.red[800])
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.green[200]
                                        : Colors.green[800]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    _getLocalizedString('description', context),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      task["description"] ??
                          _getLocalizedString('no_description', context),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Task Information Section
                  Text(
                    _getLocalizedString('task_information', context),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Deadline Card
                  _buildInfoCard(
                    context,
                    Icons.calendar_today,
                    _getLocalizedString('deadline', context),
                    "${deadline.day}/${deadline.month}/${deadline.year}",
                    isOverdue
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.red[700]!
                              : Colors.red[600]!)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[700]!
                              : Colors.blue[600]!),
                  ),
                  const SizedBox(height: 12),

                  // Class Info
                  if (task["classId"] != null)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("classes")
                          .doc(task["classId"])
                          .get(),
                      builder: (context, classSnapshot) {
                        if (classSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoCard(
                            context,
                            Icons.class_,
                            _getLocalizedString('class', context),
                            _getLocalizedString('loading_class', context),
                            Colors.grey[600]!,
                          );
                        }

                        if (classSnapshot.hasData &&
                            classSnapshot.data!.exists) {
                          final classData =
                              classSnapshot.data!.data()
                                  as Map<String, dynamic>;
                          return _buildInfoCard(
                            context,
                            Icons.class_,
                            _getLocalizedString('class', context),
                            classData["className"] ??
                                _getLocalizedString('unknown_class', context),
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[700]!
                                : Colors.blue[600]!,
                          );
                        }

                        return _buildInfoCard(
                          context,
                          Icons.class_,
                          _getLocalizedString('class', context),
                          _getLocalizedString('unknown_class', context),
                          Colors.grey[600]!,
                        );
                      },
                    ),
                  const SizedBox(height: 12),

                  // Created At
                  _buildInfoCard(
                    context,
                    Icons.access_time,
                    _getLocalizedString('created_at', context),
                    (task["createdAt"] as Timestamp?)
                            ?.toDate()
                            .toString()
                            .split(' ')[0] ??
                        _getLocalizedString('unknown_date', context),
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]!
                        : Colors.grey[600]!,
                  ),

                  const Spacer(),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherTaskEditScreen(taskId: taskId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue[300]
                                  : Colors.blue[700],
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _getLocalizedString('edit_task', context),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.red[600]!
                                  : Colors.red[400]!,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.red[900]
                                  : Colors.red[50],
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.red[300]
                                  : Colors.red[700],
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    _getLocalizedString(
                                      'confirm_delete',
                                      context,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    _getLocalizedString(
                                      'delete_confirm_message',
                                      context,
                                    ),
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(
                                        _getLocalizedString('cancel', context),
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.red[800]
                                            : Colors.red[700],
                                      ),
                                      child: Text(
                                        _getLocalizedString('delete', context),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                await FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(taskId)
                                    .delete();

                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              _getLocalizedString('delete_task', context),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
