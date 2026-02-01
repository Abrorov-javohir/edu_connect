import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:edu_connect/presintation/teachers_things/chats/teacher_chat_detail_screen.dart';
import 'package:edu_connect/presintation/student_screens/widget/chart_search_bar.dart';
import 'package:edu_connect/presintation/student_screens/widget/chat_list_widget.dart';
import 'package:edu_connect/data/chat_service.dart'; // ✅ Import existing ChatContact model

class TeacherChatScreen extends StatefulWidget {
  const TeacherChatScreen({super.key});

  @override
  State<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ChatContact> _allContacts =
      []; // ✅ Uses ChatContact from chat_service.dart
  List<ChatContact> _filteredContacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherContacts();
  }

  Future<void> _loadTeacherContacts() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final teacherId = _auth.currentUser?.uid;
      if (teacherId == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // Get all classes where this teacher is the owner
      final classesSnapshot = await _firestore
          .collection("classes")
          .where("teacherId", isEqualTo: teacherId)
          .get();

      if (classesSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _allContacts = [];
            _filteredContacts = [];
            _loading = false;
          });
        }
        return;
      }

      // Collect all student IDs from these classes
      final Set<String> studentIds = {};
      final Map<String, String> studentGrades = {}; // Map studentId -> grade

      for (final classDoc in classesSnapshot.docs) {
        final classId = classDoc.id;
        final classData = classDoc.data() as Map<String, dynamic>;
        final grade =
            classData["name"]?.toString() ?? "Unknown"; // Class name as grade

        final studentsSnapshot = await _firestore
            .collection("classStudents")
            .where("classId", isEqualTo: classId)
            .get();

        for (final studentDoc in studentsSnapshot.docs) {
          final studentId = studentDoc["studentId"] as String?;
          if (studentId != null && studentId != teacherId) {
            studentIds.add(studentId);
            studentGrades[studentId] = grade; // Store grade for this student
          }
        }
      }

      // Fetch student details and latest messages
      final List<ChatContact> contacts = [];
      for (final studentId in studentIds) {
        final userDoc = await _firestore
            .collection("users")
            .doc(studentId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final studentName =
              userData["name"] ?? userData["fullName"] ?? "Student";
          final avatarUrl = userData["imageUrl"] ?? "";

          // Get latest message in chat
          final chatId = _getChatId(teacherId, studentId);
          String lastMessage = "New conversation";
          DateTime lastMessageTime = DateTime.now();
          int unreadCount = 0;

          final messagesSnapshot = await _firestore
              .collection("chats")
              .doc(chatId)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .limit(1)
              .get();

          if (messagesSnapshot.docs.isNotEmpty) {
            final messageData = messagesSnapshot.docs.first.data()!;
            lastMessage = messageData["content"]?.toString() ?? "New message";
            final timestamp = messageData["timestamp"];
            lastMessageTime = timestamp is Timestamp
                ? timestamp.toDate()
                : DateTime.now();

            // Count unread messages from student
            if (messageData["senderId"] != teacherId &&
                (messageData["read"] == null || messageData["read"] == false)) {
              final unreadSnapshot = await _firestore
                  .collection("chats")
                  .doc(chatId)
                  .collection("messages")
                  .where("senderId", isEqualTo: studentId)
                  .where("read", isEqualTo: false)
                  .get();
              unreadCount = unreadSnapshot.docs.length;
            }
          }

          // ✅ ENHANCEMENT: Embed grade in lastMessage for display without model changes
          final grade = studentGrades[studentId] ?? "";
          final displayMessage = grade.isNotEmpty
              ? "$lastMessage • $grade"
              : lastMessage;

          contacts.add(
            ChatContact(
              // ✅ Uses imported ChatContact from chat_service.dart
              id: studentId,
              name: studentName,
              role: "student",
              avatarUrl: avatarUrl,
              lastMessage: displayMessage, // Grade embedded here
              lastMessageTime: lastMessageTime,
              unreadCount: unreadCount,
            ),
          );
        }
      }

      // Sort: unread messages first, then by latest message time
      contacts.sort((a, b) {
        if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
        if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
        return b.lastMessageTime.compareTo(a.lastMessageTime);
      });

      if (mounted) {
        setState(() {
          _allContacts = contacts;
          _filteredContacts = List.from(contacts);
          _loading = false;
        });
      }
    } catch (e) {
      print("Error loading teacher contacts: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getChatId(String userId, String contactId) {
    return userId.compareTo(contactId) < 0
        ? "$userId-$contactId"
        : "$contactId-$userId";
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.lastMessage.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    final Map<String, Map<String, String>> localizedValues = {
      'en': {
        'title': 'Student Chats',
        'no_contacts': 'No Students Found',
        'info':
            'Your students will appear here once they are added to your classes.',
      },
      'uz': {
        'title': 'Talabalar suhbati',
        'no_contacts': 'Talabalar topilmadi',
        'info':
            'Talabalar sizning sinflaringizga qo\'shilgandan so\'ng bu yerda ko\'rinadi.',
      },
      'ru': {
        'title': 'Чаты со студентами',
        'no_contacts': 'Студенты не найдены',
        'info':
            'Список студентов появится здесь после их добавления в ваши классы.',
      },
    };
    return localizedValues[language]?[key] ?? localizedValues['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedString('title'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          ChatSearchBar(onSearchChanged: _onSearchChanged),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTeacherContacts,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredContacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        return FadeInLeft(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: ChatListItem(
                            contact: _filteredContacts[index],
                            onChatTap: () {
                              // ✅ Now passes compatible ChatContact type
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherChatDetailScreen(
                                    contact: _filteredContacts[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[300]!.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            _getLocalizedString('no_contacts'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _getLocalizedString('info'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
