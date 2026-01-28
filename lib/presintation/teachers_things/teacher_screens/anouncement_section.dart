// widgets/announcements_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/widget/empty_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementsSection extends StatelessWidget {
  final List<DocumentSnapshot> recentAnnouncements;
  final VoidCallback onAnnouncementTap;

  const AnnouncementsSection({
    super.key,
    required this.recentAnnouncements,
    required this.onAnnouncementTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Announcements",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildAnnouncementList(),
      ],
    );
  }

  Widget _buildAnnouncementList() {
    if (recentAnnouncements.isEmpty) {
      return const EmptySection(text: "No announcements");
    }

    return Column(
      children: recentAnnouncements.map((announcement) {
        final data = announcement.data() as Map<String, dynamic>;
        final createdAt = (data["createdAt"] as Timestamp?)?.toDate();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.orange[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: Text(
              "${data["title"] ?? "No Title"} - ${createdAt != null ? "${createdAt.day}/${createdAt.month}" : ""}",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            onTap: onAnnouncementTap,
          ),
        );
      }).toList(),
    );
  }
}