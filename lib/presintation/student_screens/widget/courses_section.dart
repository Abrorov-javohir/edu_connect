// widgets/courses_section.dart
import 'package:edu_connect/data/student_stat_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class CoursesSection extends StatelessWidget {
  final List<CourseProgress> courses;

  const CoursesSection({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Courses",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 280,
                      child: FadeInRight(
                        delay: Duration(milliseconds: 100 * index),
                        duration: const Duration(milliseconds: 800),
                        child: _buildInteractiveCard(
                          child: _courseCard(
                            course.title,
                            course.progress,
                            _getCourseColor(course.title),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCard({required Widget child}) {
    return GestureDetector(
      onTap: () {
        // Add your tap functionality here
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(1.0),

          child: child,
        ),
      ),
    );
  }

  Widget _courseCard(String title, double progress, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(Icons.book, color: color, size: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar with animation
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress * 100).toInt()}% completed",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getCourseColor(String course) {
    switch (course.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Colors.orange[700]!;
      case 'science':
        return Colors.green[700]!;
      case 'history':
        return Colors.brown[700]!;
      case 'english':
        return Colors.blue[700]!;
      case 'art':
        return Colors.pink[700]!;
      case 'music':
        return Colors.purple[700]!;
      default:
        return Colors.blueGrey[700]!;
    }
  }
}