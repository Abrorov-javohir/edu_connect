// widgets/anouncement_section.dart
import 'package:edu_connect/presintation/student_screens/model/anouncement_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class AnnouncementsSection extends StatelessWidget {
  final List<Announcement> announcements;

  const AnnouncementsSection({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          final dateText = _formatDate(announcement.createdAt);

          return FadeIn(
            delay: Duration(milliseconds: 200 * index),
            child: BounceIn(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue[100]!, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.campaign,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.content,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "$dateText • ${announcement.teacherName}",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            announcement.className,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
