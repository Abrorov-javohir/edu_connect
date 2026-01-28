// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:provider/provider.dart';
// import 'package:edu_connect/data/chat_service.dart';
// import 'package:edu_connect/providers/language_provider.dart';
// import 'package:edu_connect/presintation/teachers_things/chats/teacher_chat_detail_screen.dart';
// import 'package:edu_connect/presintation/student_screens/widget/chart_search_bar.dart';
// import 'package:edu_connect/presintation/student_screens/widget/chat_list_widget.dart';

// class TeacherChatScreen extends StatefulWidget {
//   const TeacherChatScreen({super.key});

//   @override
//   State<TeacherChatScreen> createState() => _TeacherChatScreenState();
// }

// class _TeacherChatScreenState extends State<TeacherChatScreen> {
//   final ChatService _chatService = ChatService();
//   List<ChatContact> _allContacts = [];
//   List<ChatContact> _filteredContacts = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTeacherContacts();
//   }

//   Future<void> _loadTeacherContacts() async {
//     if (!mounted) return;
//     setState(() => _loading = true);

//     try {
//       final contacts = await _chatService.getTeacherContacts();
//       if (mounted) {
//         setState(() {
//           _allContacts = contacts;
//           _filteredContacts = contacts;
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   void _onSearchChanged(String query) {
//     setState(() {
//       _filteredContacts = _allContacts.where((contact) {
//         return contact.name.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   String _getLocalizedString(String key) {
//     final language = context.read<LanguageProvider>().currentLanguage;
//     final Map<String, Map<String, String>> localizedValues = {
//       'en': {
//         'title': 'Student Chats',
//         'no_contacts': 'No Students Found',
//         'info':
//             'Your students will appear here once they are added to the system.',
//       },
//       'uz': {
//         'title': 'Talabalar suhbati',
//         'no_contacts': 'Talabalar topilmadi',
//         'info': 'Talabalar tizimga qo\'shilgandan so\'ng bu yerda ko\'rinadi.',
//       },
//       'ru': {
//         'title': 'Чаты со студентами',
//         'no_contacts': 'Студенты не найдены',
//         'info':
//             'Список студентов появится здесь после их добавления в систему.',
//       },
//     };
//     return localizedValues[language]?[key] ?? localizedValues['en']![key]!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           _getLocalizedString('title'),
//           style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           ChatSearchBar(onSearchChanged: _onSearchChanged),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _loadTeacherContacts, // Pull to refresh feature
//               child: _loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _filteredContacts.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: _filteredContacts.length,
//                       itemBuilder: (context, index) {
//                         return FadeInLeft(
//                           duration: Duration(milliseconds: 300 + (index * 100)),
//                           child: ChatListItem(
//                             contact: _filteredContacts[index],
//                             onChatTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TeacherChatDetailScreen(
//                                     contact: _filteredContacts[index],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return ListView(
//       // Wrap in ListView so RefreshIndicator works even when empty
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * 0.2),
//         Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.people_outline,
//                 size: 80,
//                 color: Colors.blue.withOpacity(0.3),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _getLocalizedString('no_contacts'),
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   _getLocalizedString('info'),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
