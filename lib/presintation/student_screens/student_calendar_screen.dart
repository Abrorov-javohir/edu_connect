// screens/student_calendar_screen.dart
import 'package:edu_connect/presintation/student_screens/model/calendar_model.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CalendarEvent> _allEvents = [];
  bool _loading = true;

  // Translation map
  Map<String, Map<String, String>> translations = {
    'en': {
      'academicSchedule': 'Academic Schedule',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'upcoming': 'Upcoming Events',
      'noEvents': 'No events scheduled',
      'loading': 'Loading...',
      'refresh': 'Pull to refresh',
    },
    'uz': {
      'academicSchedule': 'Akademik Jadval',
      'today': 'Bugun',
      'tomorrow': 'Ertaga',
      'upcoming': 'Kutilayotgan tadbirlar',
      'noEvents': 'Hech qanday tadbir rejalashtirilmagan',
      'loading': 'Yuklanmoqda...',
      'refresh': 'Yangilash uchun torting',
    },
    'ru': {
      'academicSchedule': 'Академическое расписание',
      'today': 'Сегодня',
      'tomorrow': 'Завтра',
      'upcoming': 'Предстоящие события',
      'noEvents': 'Нет запланированных событий',
      'loading': 'Загрузка...',
      'refresh': 'Потяните для обновления',
    },
  };

  String translate(String key) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return translations[languageProvider.currentLanguage]?[key] ??
        translations['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      // Get classes this student is enrolled in
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final Set<String> classIds = {};
      for (final doc in classStudentsSnapshot.docs) {
        classIds.add(doc["classId"] as String);
      }

      // Load events from all enrolled classes
      final List<CalendarEvent> events = [];

      // Load events collection
      final eventsSnapshot = await _firestore
          .collection("events")
          .where("classId", whereIn: classIds.toList())
          .get();

      for (final doc in eventsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        events.add(CalendarEvent.fromMap(data, doc.id));
      }

      // Load announcements as events
      final announcementsSnapshot = await _firestore
          .collection("announcements")
          .where("classId", whereIn: classIds.toList())
          .get();

      for (final doc in announcementsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Convert announcement to event format
        final eventData = {
          'title': data['title'] ?? 'Announcement',
          'description': data['content'] ?? data['description'] ?? '',
          'date': data['createdAt'] ?? Timestamp.now(),
          'time': 'All Day',
          'type': 'announcement',
          'subject': 'Announcement',
          'teacherId': data['teacherId'] ?? '',
          'teacherName': data['teacherName'] ?? 'Teacher',
          'classId': data['classId'] ?? '',
        };
        events.add(CalendarEvent.fromMap(eventData, doc.id));
      }

      // Sort events by date
      events.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _allEvents = events;
        _loading = false;
      });
    } catch (e) {
      print("Error loading events: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FD);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(textColor),
      body: RefreshIndicator(
        onRefresh: () async => _loadAllEvents(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCalendarCard(isDarkMode, cardColor, textColor),
              const SizedBox(height: 25),
              _buildEventSectionHeader(textColor),
              _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
                      ),
                    )
                  : _buildEventList(
                      isDarkMode,
                      cardColor,
                      textColor,
                      dividerColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color textColor) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        translate('academicSchedule'),
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDarkMode, Color cardColor, Color textColor) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Calendar header with month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                        1,
                      );
                    });
                  },
                  icon: Icon(Icons.chevron_left, color: textColor),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(currentMonth),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                        1,
                      );
                    });
                  },
                  icon: Icon(Icons.chevron_right, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Calendar grid
            _buildCalendarGrid(isDarkMode, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDarkMode, Color textColor) {
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final List<Widget> dayWidgets = [];

    // Add empty spaces for days before the first day of the month
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isSelected =
          selectedDate.day == day &&
          selectedDate.month == currentMonth.month &&
          selectedDate.year == currentMonth.year;

      final hasEvents = _hasEventsOnDate(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? Colors.blue[700] : Colors.blue[100])
                  : (hasEvents
                        ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
                        : null),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDarkMode ? Colors.blue : Colors.blue)
                    : (isDarkMode ? Colors.grey! : Colors.grey!),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.blue[700])
                      : (isDarkMode ? Colors.white : Colors.grey[800]),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: dayWidgets,
    );
  }

  Widget _buildEventSectionHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            translate('upcoming'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to full calendar view or add event
            },
            child: Text(
              translate('today'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color? dividerColor,
  ) {
    if (_allEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            textAlign: TextAlign.center,
            translate('noEvents'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    // Filter events for today and upcoming
    final today = DateTime.now();
    final todayEvents = _allEvents
        .where(
          (event) =>
              event.date.year == today.year &&
              event.date.month == today.month &&
              event.date.day == today.day,
        )
        .toList();

    final upcomingEvents = _allEvents
        .where((event) => event.date.isAfter(today))
        .take(5)
        .toList();

    return Column(
      children: [
        if (todayEvents.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              translate('today'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ...todayEvents.map(
            (event) => _buildEventCard(event, isDarkMode, cardColor, textColor),
          ),
        ],
        if (upcomingEvents.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              translate('tomorrow'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ...upcomingEvents.map(
            (event) => _buildEventCard(event, isDarkMode, cardColor, textColor),
          ),
        ],
      ],
    );
  }

  Widget _buildEventCard(
    CalendarEvent event,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
  ) {
    final eventColor = _getEventColor(event.type, isDarkMode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(event.date),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (event.time != 'All Day') ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type, bool isDarkMode) {
    switch (type.toLowerCase()) {
      case 'exam':
        return Colors.red[700]!;
      case 'assignment':
        return Colors.orange[700]!;
      case 'announcement':
        return Colors.blue[700]!;
      case 'meeting':
        return Colors.purple[700]!;
      default:
        return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  bool _hasEventsOnDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _allEvents.any((event) {
      final eventDate = DateFormat('yyyy-MM-dd').format(event.date);
      return eventDate == formattedDate;
    });
  }
}
