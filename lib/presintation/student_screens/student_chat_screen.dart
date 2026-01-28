// screens/student_chat_screen.dart
import 'package:edu_connect/data/chat_service.dart';
import 'package:edu_connect/presintation/student_screens/ai_chat_page.dart';
import 'package:edu_connect/presintation/student_screens/chat_detail_screen.dart';
import 'package:edu_connect/presintation/student_screens/widget/chart_search_bar.dart';
import 'package:edu_connect/presintation/student_screens/widget/chat_list_widget.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({super.key});

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final ChatService _chatService = ChatService();
  List<ChatContact> _allContacts = [];
  List<ChatContact> _filteredContacts = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _loading = true);
    try {
      final contacts = await _chatService.getStudentContacts();
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _loading = false;
      });
    } catch (e) {
      print("Error loading contacts: $e");
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'messages':
            return "Xabarlar";
          case 'no_contacts':
            return "Hali kontakt yo'q";
          case 'no_matches':
            return "Hech narsa topilmadi";
          case 'enroll_info':
            return "Sinfda ro'yxatdan o'tganingizdan keyin sinfdoshlaringiz va o'qituvchingiz bilan suhbatlashishingiz mumkin bo'ladi.";
          case 'search_info':
            return "Boshqa kalit so'zlarni qidirib ko'ring yoki sinf ro'yxatga olishini tekshiring.";
          case 'ask_ai':
            return "AI dan so'rang";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'messages':
            return "Сообщения";
          case 'no_contacts':
            return "Контактов пока нет";
          case 'no_matches':
            return "Совпадений не найдено";
          case 'enroll_info':
            return "Вы сможете общаться со своими одноклассниками и учителями после зачисления в классы.";
          case 'search_info':
            return "Попробуйте поискать с другими ключевыми словами или проверьте регистрацию в классе.";
          case 'ask_ai':
            return "Спросить ИИ";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'messages':
            return "Messages";
          case 'no_contacts':
            return "No Contacts Yet";
          case 'no_matches':
            return "No matches found";
          case 'enroll_info':
            return "You'll be able to chat with your classmates and teachers once you're enrolled in classes.";
          case 'search_info':
            return "Try searching with different keywords or check your class enrollment.";
          case 'ask_ai':
            return "Ask AI";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar Section
            ChatSearchBar(onSearchChanged: _onSearchChanged),

            const SizedBox(height: 16),

            // 💬 Chats List Section
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[400]
                            : Colors.blue,
                      ),
                    )
                  : _filteredContacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          duration: const Duration(milliseconds: 600),
                          child: ChatListItem(
                            contact: _filteredContacts[index],
                            onChatTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
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
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 0,
      title: Text(
        _getLocalizedString('messages'),
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).appBarTheme.foregroundColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]?.withOpacity(0.2)
                    : Colors.blue[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[700]!
                      : Colors.blue[100]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue
                                : Colors.blue)
                            .withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 72,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _searchQuery.isEmpty
                  ? _getLocalizedString('no_contacts')
                  : _getLocalizedString('no_matches'),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                textAlign: TextAlign.center,
                _searchQuery.isEmpty
                    ? _getLocalizedString('enroll_info')
                    : _getLocalizedString('search_info'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AiChatPage()),
        );
      },
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue[900]
          : Colors.blue[800],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome, size: 24),
      label: Text(
        _getLocalizedString('ask_ai'),
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
