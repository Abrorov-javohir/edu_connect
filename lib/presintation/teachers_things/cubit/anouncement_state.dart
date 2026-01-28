// cubits/announcements_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AnnouncementsState {}

class AnnouncementsInitial extends AnnouncementsState {}

class AnnouncementsLoading extends AnnouncementsState {}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<DocumentSnapshot> announcements;

  AnnouncementsLoaded(this.announcements);
}

class AnnouncementsError extends AnnouncementsState {
  final String error;

  AnnouncementsError(this.error);
}