// cubits/announcements_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/anouncement_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnnouncementsCubit() : super(AnnouncementsInitial());

  Future<void> loadAnnouncements() async {
    emit(AnnouncementsLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(AnnouncementsError('User not authenticated'));
        return;
      }

      final querySnapshot = await _firestore
          .collection("announcements")
          .where("teacherId", isEqualTo: userId)
          .get();

      emit(AnnouncementsLoaded(querySnapshot.docs));
    } catch (e) {
      emit(AnnouncementsError(e.toString()));
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore
          .collection("announcements")
          .doc(announcementId)
          .delete();
      loadAnnouncements(); // Refresh list
    } catch (e) {
      emit(AnnouncementsError(e.toString()));
    }
  }

  void searchAnnouncements(String query) {
    if (state is! AnnouncementsLoaded) return;
    
    final originalAnnouncements = (state as AnnouncementsLoaded).announcements;
    if (query.isEmpty) {
      emit(AnnouncementsLoaded(originalAnnouncements));
      return;
    }

    final filtered = originalAnnouncements.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data["title"] ?? "").toLowerCase();
      final content = (data["content"] ?? "").toLowerCase();
      return title.contains(query.toLowerCase()) ||
          content.contains(query.toLowerCase());
    }).toList();

    emit(AnnouncementsLoaded(filtered));
  }
}