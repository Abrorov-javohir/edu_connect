// lib/data/note_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/model/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Note>> getTeacherNotes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('notes')
        .where('teacherId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Note.fromFirestore).toList());
  }

  Future<void> createNote(String title, String content, String category) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final note = Note(
      id: '',
      teacherId: userId,
      title: title.trim().isNotEmpty ? title.trim() : 'Untitled Note',
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
      category: category,
      color: Note.generateColor(category),
    );

    await _firestore.collection('notes').add(note.toFirestore());
  }

  Future<void> updateNote(String noteId, String title, String content, String category) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('notes').doc(noteId).update({
      'title': title.trim().isNotEmpty ? title.trim() : 'Untitled Note',
      'content': content.trim(),
      'category': category,
      'color': Note.generateColor(category),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('notes').doc(noteId).delete();
  }
}