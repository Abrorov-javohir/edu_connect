// widgets/task_card.dart
import 'package:edu_connect/presintation/student_screens/cubit/task_cubit.dart';
import 'package:edu_connect/presintation/student_screens/model/task_model.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Accessing currentLanguage safely
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguage;

    final now = DateTime.now();
    final isOverdue = task.deadline.isBefore(now) && !task.isCompleted;
    final daysLeft = task.deadline.difference(now).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? Colors.green[200]!
              : isOverdue
              ? Colors.red[200]!
              : Colors.grey[200]!,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubjectBadge(task.subject),
                if (task.isCompleted)
                  _buildStatusChip(
                    _translate('completed', currentLanguage),
                    Colors.green,
                  )
                else if (isOverdue)
                  _buildStatusChip(
                    _translate('overdue', currentLanguage),
                    Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    context.read<TasksCubit>().completeTask(
                      task.id,
                      value ?? false,
                    );
                  },
                  activeColor: Colors.green[600],
                  checkColor: Colors.white,
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: task.isCompleted
                          ? FontWeight.w500
                          : FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.calendar_today,
                  size: 16,
                  color: isOverdue ? Colors.red[600] : Colors.blue[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getDeadlineText(currentLanguage, isOverdue, daysLeft),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isOverdue ? Colors.red[700] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            _buildHomeworkSimulation(context, task, isOverdue, currentLanguage),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubjectBadge(String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSubjectColor(subject),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSubjectIcon(subject), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            subject,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDeadlineText(String lang, bool isOverdue, int daysLeft) {
    if (isOverdue) {
      return "${_translate('overdue_by_days', lang)} ${daysLeft.abs()} ${_translate('due_in_days', lang)}";
    } else if (daysLeft == 0) {
      return _translate('due_today', lang);
    } else if (daysLeft == 1) {
      return _translate('due_tomorrow', lang);
    } else {
      return "$daysLeft ${_translate('due_in_days', lang)}";
    }
  }

  Widget _buildHomeworkSimulation(
    BuildContext context,
    TaskModel task,
    bool isOverdue,
    String lang,
  ) {
    final progress = context.read<TasksCubit>().calculateHomeworkProgress(
      isCompleted: task.isCompleted,
      isOverdue: isOverdue,
      deadline: task.deadline,
    );

    String statusText;
    if (task.isCompleted) {
      statusText = _translate('completed_homework', lang);
    } else if (isOverdue) {
      statusText =
          "${(progress * 100).toInt()}% - ${_translate('late_submission', lang)}";
    } else {
      final daysToDeadline = task.deadline.difference(DateTime.now()).inDays;
      final statusKey = daysToDeadline <= 3
          ? 'deadline_approaching'
          : 'keep_working';
      statusText =
          "${(progress * 100).toInt()}% - ${_translate(statusKey, lang)}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _translate('homework_progress', lang),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: task.isCompleted
              ? Colors.green[500]
              : (isOverdue ? Colors.red[300] : Colors.blue[300]),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              task.isCompleted
                  ? "✓ +10${_translate('pts', lang)}"
                  : isOverdue
                  ? "⚠ -5${_translate('pts', lang)}"
                  : "+5${_translate('pts', lang)}",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: task.isCompleted
                    ? Colors.green[600]
                    : (isOverdue ? Colors.red[600] : Colors.blue[600]),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return Colors.orange[600]!;
      case 'science':
        return Colors.green[600]!;
      case 'history':
        return Colors.brown[600]!;
      case 'english':
        return Colors.blue[600]!;
      case 'art':
        return Colors.pink[600]!;
      case 'music':
        return Colors.purple[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history;
      case 'english':
        return Icons.book;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      default:
        return Icons.school;
    }
  }

  String _translate(String key, String language) {
    final Map<String, Map<String, String>> localizedValues = {
      'uz': {
        'completed': "Tugatildi",
        'overdue': "Kechikdi",
        'homework_progress': "Vazifa jarayoni",
        'late_submission': "Kechikib topshirish",
        'deadline_approaching': "Muddat yaqin",
        'keep_working': "Davom eting",
        'late': "Kech",
        'pts': " ball",
        'completed_homework': "Vazifa bajarildi!",
        'due_today': "Bugun oxirgi muddat",
        'due_tomorrow': "Ertaga oxirgi muddat",
        'due_in_days': "kun qoldi",
        'overdue_by_days': "Kechikdi:",
      },
      'ru': {
        'completed': "Выполнено",
        'overdue': "Просрочено",
        'homework_progress': "Прогресс",
        'late_submission': "Поздняя сдача",
        'deadline_approaching': "Срок подходит",
        'keep_working': "Работайте дальше",
        'late': "Поздно",
        'pts': " очков",
        'completed_homework': "Выполнено!",
        'due_today': "Срок сегодня",
        'due_tomorrow': "Срок завтра",
        'due_in_days': "дней осталось",
        'overdue_by_days': "Просрочено на",
      },
      'en': {
        'completed': "Completed",
        'overdue': "Overdue",
        'homework_progress': "Homework Progress",
        'late_submission': "Late submission",
        'deadline_approaching': "Deadline approaching",
        'keep_working': "Keep working",
        'late': "Late",
        'pts': " pts",
        'completed_homework': "Homework completed!",
        'due_today': "Due today",
        'due_tomorrow': "Due tomorrow",
        'due_in_days': "days due",
        'overdue_by_days': "Overdue by",
      },
    };
    return localizedValues[language]?[key] ?? localizedValues['en']![key]!;
  }
}
