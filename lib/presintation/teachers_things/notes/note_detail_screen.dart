// lib/presintation/teachers_things/notes/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/data/note_service.dart';

import '../model/note_model.dart';

class TeacherNoteDetailScreen extends StatefulWidget {
  final Note? note;

  const TeacherNoteDetailScreen({super.key, this.note});

  @override
  State<TeacherNoteDetailScreen> createState() => _TeacherNoteDetailScreenState();
}

class _TeacherNoteDetailScreenState extends State<TeacherNoteDetailScreen> {
  final NoteService _noteService = NoteService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'other';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedCategory = widget.note!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        return {
          'new_note': 'Yangi Eslatma',
          'edit_note': 'Eslatmani Tahrirlash',
          'title': 'Sarlavha',
          'content': 'Tavsif',
          'category': 'Turkum',
          'lesson': 'Dars',
          'homework': 'Uy vazifasi',
          'reminder': 'Eslatma',
          'meeting': 'Uchrashuv',
          'other': 'Boshqa',
          'save': 'Saqlash',
          'saving': 'Saqlanmoqda...',
          'saved': 'Saqlandi!',
          'error_saving': 'Saqlashda xatolik yuz berdi',
        }[key] ?? key;
      case 'ru':
        return {
          'new_note': 'Новая Заметка',
          'edit_note': 'Редактировать Заметку',
          'title': 'Заголовок',
          'content': 'Содержание',
          'category': 'Категория',
          'lesson': 'Урок',
          'homework': 'Домашнее задание',
          'reminder': 'Напоминание',
          'meeting': 'Встреча',
          'other': 'Другое',
          'save': 'Сохранить',
          'saving': 'Сохранение...',
          'saved': 'Сохранено!',
          'error_saving': 'Ошибка при сохранении',
        }[key] ?? key;
      default:
        return {
          'new_note': 'New Note',
          'edit_note': 'Edit Note',
          'title': 'Title',
          'content': 'Content',
          'category': 'Category',
          'lesson': 'Lesson',
          'homework': 'Homework',
          'reminder': 'Reminder',
          'meeting': 'Meeting',
          'other': 'Other',
          'save': 'Save',
          'saving': 'Saving...',
          'saved': 'Saved!',
          'error_saving': 'Error saving note',
        }[key] ?? key;
    }
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getLocalizedString('content') + ' cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.note != null) {
        await _noteService.updateNote(widget.note!.id, title, content, _selectedCategory);
      } else {
        await _noteService.createNote(title, content, _selectedCategory);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedString('saved'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getLocalizedString('error_saving')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? _getLocalizedString('new_note')
              : _getLocalizedString('edit_note'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveNote,
            child: Text(
              _isSaving ? _getLocalizedString('saving') : _getLocalizedString('save'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.blue[400],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title field
              TextField(
                controller: _titleController,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: _getLocalizedString('title'),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 20,
                    color: hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Category selector
              Row(
                children: [
                  Text(
                    _getLocalizedString('category'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                      items: [
                        'lesson', 'homework', 'reminder', 'meeting', 'other'
                      ].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getLocalizedString(category)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content field
              TextField(
                controller: _contentController,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: _getLocalizedString('content'),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: hintColor?.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}