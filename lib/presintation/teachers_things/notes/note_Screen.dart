// lib/presintation/teachers_things/notes/note_screen.dart
import 'package:edu_connect/presintation/teachers_things/model/note_model.dart';
import 'package:edu_connect/presintation/teachers_things/notes/note_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/data/note_service.dart';

class TeacherNotesScreen extends StatefulWidget {
  const TeacherNotesScreen({super.key});

  @override
  State<TeacherNotesScreen> createState() => _TeacherNotesScreenState();
}

class _TeacherNotesScreenState extends State<TeacherNotesScreen> {
  final NoteService _noteService = NoteService();
  bool _isDeleting = false;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        return {
              'notes': 'Eslatmalar',
              'no_notes': 'Hali hech qanday eslatma yo\'q',
              'create_first': 'Birinchi eslatmani yarating!',
              'new_note': 'Yangi Eslatma',
              'delete_note': 'Eslatmani o\'chirish',
              'confirm_delete':
                  'Haqiqatan ham ushbu eslatmani o\'chirmoqchimisiz?',
              'cancel': 'Bekor qilish',
              'delete': 'O\'chirish',
            }[key] ??
            key;
      case 'ru':
        return {
              'notes': 'Заметки',
              'no_notes': 'Пока нет заметок',
              'create_first': 'Создайте свою первую заметку!',
              'new_note': 'Новая Заметка',
              'delete_note': 'Удалить заметку',
              'confirm_delete': 'Вы уверены, что хотите удалить эту заметку?',
              'cancel': 'Отмена',
              'delete': 'Удалить',
            }[key] ??
            key;
      default:
        return {
              'notes': 'Notes',
              'no_notes': 'No notes yet',
              'create_first': 'Create your first note!',
              'new_note': 'New Note',
              'delete_note': 'Delete Note',
              'confirm_delete': 'Are you sure you want to delete this note?',
              'cancel': 'Cancel',
              'delete': 'Delete',
            }[key] ??
            key;
    }
  }

  Future<void> _showDeleteDialog(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedString('delete_note')),
        content: Text(_getLocalizedString('confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getLocalizedString('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: Text(
              _getLocalizedString('delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && !_isDeleting) {
      setState(() => _isDeleting = true);
      try {
        await _noteService.deleteNote(note.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedString('notes'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Optional: Add search functionality later
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _noteService.getTeacherNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notes = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildNoteCard(note),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNoteDetail(),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue[800]
            : Colors.blue[600],
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[800]!
                      : Colors.blue[300]!,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[600]!
                      : Colors.blue[500]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.note_alt, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedString('no_notes'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getLocalizedString('create_first'),
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final noteColor = Color(int.parse(note.color.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: () => _navigateToNoteDetail(note),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              noteColor.withOpacity(0.15),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: noteColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: noteColor.withOpacity(0.4), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge with icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: noteColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(note.getCategoryIcon(), color: noteColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    note.getLocalizedCategory(langProvider),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: noteColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Content preview
                    Expanded(
                      child: Text(
                        note.content.isNotEmpty
                            ? note.content
                            : 'No content...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Date
                    Text(
                      _formatDateTime(note.updatedAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showDeleteDialog(note),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday =
        dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year;

    if (isToday) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return '${dateTime.day}/${dateTime.month}';
  }

  void _navigateToNoteDetail([Note? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherNoteDetailScreen(note: note),
      ),
    );
  }
}
