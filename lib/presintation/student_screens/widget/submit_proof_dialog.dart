
// widgets/submit_proof_dialog.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class SubmitProofDialog extends StatefulWidget {
  final String taskId;
  final VoidCallback onSubmitted;

  const SubmitProofDialog({super.key, required this.taskId, required this.onSubmitted});

  @override
  State<SubmitProofDialog> createState() => _SubmitProofDialogState();
}

class _SubmitProofDialogState extends State<SubmitProofDialog> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  bool _loading = false;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'submit_proof': return "Isbot Yuborish";
          case 'describe_work': return "Ishlaringizni tavsiflang, izohlar qo'shing yoki yuborilgan materialingiz haqida eslatmalar qiling...";
          case 'supporting_evidence': return "Ariza Hujjatlari";
          case 'upload_instructions': return "Uyga vazifangiz rasmlarini, skrinshotlarni, diagrammalarni yoki boshqa isbot hujjatlarini yuklang";
          case 'add_photo': return "📸 Rasm Qo'shish";
          case 'photo_added': return "✅ Rasm Qo'shildi";
          case 'cancel': return "Bekor Qilish";
          case 'submit_proof_btn': return "Isbot Yuborish";
          case 'success': return "✅ Isbot muvaffaqiyatli yuborildi!";
          case 'error': return "Xato: ";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'submit_proof': return "Отправить Подтверждение";
          case 'describe_work': return "Опишите свою работу, добавьте объяснения или заметки о вашей работе...";
          case 'supporting_evidence': return "Подтверждающие документы";
          case 'upload_instructions': return "Загрузите фотографии домашнего задания, скриншоты, диаграммы или любые другие доказательства вашей работы";
          case 'add_photo': return "📸 Добавить Фото";
          case 'photo_added': return "✅ Фото Добавлено";
          case 'cancel': return "Отмена";
          case 'submit_proof_btn': return "Отправить Подтверждение";
          case 'success': return "✅ Подтверждение успешно отправлено!";
          case 'error': return "Ошибка: ";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'submit_proof': return "Submit Proof";
          case 'describe_work': return "Describe your work, add explanations, or notes about your submission...";
          case 'supporting_evidence': return "Supporting Evidence";
          case 'upload_instructions': return "Upload photos of your homework, screenshots, diagrams, or any other proof of your work";
          case 'add_photo': return "📸 Add Photo";
          case 'photo_added': return "✅ Photo Added";
          case 'cancel': return "Cancel";
          case 'submit_proof_btn': return "Submit Proof";
          case 'success': return "✅ Proof submitted successfully!";
          case 'error': return "Error: ";
          default: return key;
        }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitProof() async {
    setState(() => _loading = true);
    
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

      // Create submission document
      final submissionData = <String, dynamic>{
        "taskId": widget.taskId,
        "studentId": userId,
        "status": "submitted",
        "text": _textController.text.trim(),
        "submittedAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "studentName": userName,
        "taskTitle": taskTitle,
      };

      // Add image reference if selected
      if (_selectedImage != null) {
        submissionData["imageUrl"] = "proof_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
      }

      // Check if submission already exists
      final existingSubmissions = await FirebaseFirestore.instance
          .collection("taskSubmissions")
          .where("taskId", isEqualTo: widget.taskId)
          .where("studentId", isEqualTo: userId)
          .limit(1)
          .get();

      String docId;
      if (existingSubmissions.docs.isNotEmpty) {
        // Update existing submission
        docId = existingSubmissions.docs.first.id;
        await FirebaseFirestore.instance
            .collection("taskSubmissions")
            .doc(docId)
            .update(submissionData);
      } else {
        // Create new submission
        final newDoc = await FirebaseFirestore.instance.collection("taskSubmissions").add(submissionData);
        docId = newDoc.id;
      }

      Navigator.pop(context);
      widget.onSubmitted();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.file_upload, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("✅ Proof submitted successfully!", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.blue[700],
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text("${_getLocalizedString('error')}$e", style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedString('submit_proof'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey[900],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.grey),

            const SizedBox(height: 20),

            // Text description
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _getLocalizedString('describe_work'),
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[500],
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]!
                        : Colors.grey,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
                isDense: true,
              ),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),

            // Image upload section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedString('supporting_evidence'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getLocalizedString('upload_instructions'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUploadButton(),
                  const SizedBox(height: 16),
                  if (_selectedImage != null)
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : null,
                          colorBlendMode: BlendMode.modulate,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!
                            : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getLocalizedString('cancel'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitProof,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[800]
                          : Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _getLocalizedString('submit_proof_btn'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
  }

  Widget _buildUploadButton() {
    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.add_a_photo, size: 18),
      label: Text(
        _selectedImage != null 
            ? _getLocalizedString('photo_added') 
            : _getLocalizedString('add_photo'),
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _selectedImage != null 
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[300]
                  : Colors.green[700])
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[700]),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: _selectedImage != null 
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[600]!
                  : Colors.green[300]!)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey[300]!),
          width: 1.5,
        ),
      ),
    );
  }
}