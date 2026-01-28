// widgets/task_actions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'submit_proof_dialog.dart';

class TaskActions extends StatefulWidget {
  final String taskId;
  final String status;
  final VoidCallback onTaskUpdated;

  const TaskActions({
    super.key,
    required this.taskId,
    required this.status,
    required this.onTaskUpdated,
  });

  @override
  State<TaskActions> createState() => _TaskActionsState();
}

class _TaskActionsState extends State<TaskActions> {
  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'task_done': return "✅ Vazifa bajarildi! +5 ball";
          case 'excellent': return "✅ Ajoyib! Vazifangiz o'qituvchingiz tomonidan tekshirildi.";
          case 'rejected_msg': return "❌ Vazifangiz qaytarildi. Iltimos, tuzatmalar bilan qayta yuboring.";
          case 'already_completed': return "✅ ALREADY COMPLETED";
          case 'mark_completed': return "✅ MARK AS COMPLETED";
          case 'resubmit_proof': return "📎 RESUBMIT PROOF";
          case 'submit_proof_optional': return "📎 SUBMIT PROOF (Optional)";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'task_done': return "✅ Задание выполнено! +5 очков";
          case 'excellent': return "✅ Отлично! Ваше задание проверено учителем.";
          case 'rejected_msg': return "❌ Ваше задание отклонено. Пожалуйста, отправьте снова с исправлениями.";
          case 'already_completed': return "✅ УЖЕ ВЫПОЛНЕНО";
          case 'mark_completed': return "✅ ОТМЕТИТЬ КАК ВЫПОЛНЕНО";
          case 'resubmit_proof': return "📎 ПОВТОРНО ОТПРАВИТЬ ДОКАЗАТЕЛЬСТВО";
          case 'submit_proof_optional': return "📎 ОТПРАВИТЬ ДОКАЗАТЕЛЬСТВО (необязательно)";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'task_done': return "✅ Task marked as done! +5 points";
          case 'excellent': return "✅ Excellent! Your task has been verified by your teacher.";
          case 'rejected_msg': return "❌ Your task was rejected. Please resubmit with corrections.";
          case 'already_completed': return "✅ ALREADY COMPLETED";
          case 'mark_completed': return "✅ MARK AS COMPLETED";
          case 'resubmit_proof': return "📎 RESUBMIT PROOF";
          case 'submit_proof_optional': return "📎 SUBMIT PROOF (Optional)";
          default: return key;
        }
    }
  }

  Future<void> _markAsDone() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName ?? "Student";
      if (userId == null) return;

      // Get task details
      final taskDoc = await FirebaseFirestore.instance
          .collection("tasks")
          .doc(widget.taskId)
          .get();
      
      final taskData = taskDoc.data() as Map<String, dynamic>?;
      final taskTitle = taskData?["title"] ?? "Task";

      // Check if submission exists
      final submissionsQuery = await FirebaseFirestore.instance
          .collection("taskSubmissions")
          .where("taskId", isEqualTo: widget.taskId)
          .where("studentId", isEqualTo: userId)
          .limit(1)
          .get();

      Map<String, dynamic> submissionData;
      String docId;
      
      if (submissionsQuery.docs.isNotEmpty) {
        submissionData = {
          "status": "completed_unverified",
          "completedAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        };
        docId = submissionsQuery.docs.first.id;
      } else {
        submissionData = {
          "taskId": widget.taskId,
          "studentId": userId,
          "status": "completed_unverified",
          "completedAt": FieldValue.serverTimestamp(),
          "createdAt": FieldValue.serverTimestamp(),
          "studentName": userName,
          "taskTitle": taskTitle,
        };
        final newDoc = await FirebaseFirestore.instance.collection("taskSubmissions").add(submissionData);
        docId = newDoc.id;
      }

      // Update or create submission
      if (submissionsQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("taskSubmissions")
            .doc(docId)
            .update(submissionData);
      } else {
        await FirebaseFirestore.instance.collection("taskSubmissions").doc(docId).set(submissionData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _getLocalizedString('task_done'),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
        ),
      );

      widget.onTaskUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text("Error: $e", style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For verified tasks, show success message
    if (widget.status == "verified") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: Colors.green[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getLocalizedString('excellent'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For rejected tasks, show resubmit option
    if (widget.status == "rejected") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getLocalizedString('rejected_msg'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[800],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 🔹 MARK AS DONE BUTTON (Primary action)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.status != "completed_unverified" 
                ? _markAsDone 
                : null,
            icon: const Icon(Icons.check_circle, size: 18),
            label: Text(
              widget.status == "completed_unverified" 
                  ? _getLocalizedString('already_completed') 
                  : _getLocalizedString('mark_completed'),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.status == "completed_unverified" 
                  ? Colors.green[300] 
                  : Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 🔹 SUBMIT PROOF BUTTON (Secondary action)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSubmitProofDialog(),
            icon: const Icon(Icons.file_upload, size: 18),
            label: Text(
              widget.status == "submitted" 
                  ? _getLocalizedString('resubmit_proof') 
                  : _getLocalizedString('submit_proof_optional'),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSubmitProofDialog() {
    showDialog(
      context: context,
      builder: (context) => SubmitProofDialog(
        taskId: widget.taskId,
        onSubmitted: widget.onTaskUpdated,
      ),
    );
  }
}
