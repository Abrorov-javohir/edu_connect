// screens/teacher_chat_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/chat_service.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class TeacherChatDetailScreen extends StatefulWidget {
  final ChatContact contact;

  const TeacherChatDetailScreen({super.key, required this.contact});

  @override
  State<TeacherChatDetailScreen> createState() =>
      _TeacherChatDetailScreenState();
}

class _TeacherChatDetailScreenState extends State<TeacherChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatId;
  String? _currentUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _chatId = _chatService.getChatId(_currentUserId!, widget.contact.id);
    }
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'role_label':
            return "Talaba";
          case 'start_conversation':
            return "Suhbatni boshlang!";
          case 'type_message':
            return "Xabar yozing...";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'role_label':
            return "Студент";
          case 'start_conversation':
            return "Начните разговор!";
          case 'type_message':
            return "Введите сообщение...";
          default:
            return key;
        }
      default:
        switch (key) {
          case 'role_label':
            return "Student";
          case 'start_conversation':
            return "Start a conversation!";
          case 'type_message':
            return "Type a message...";
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatId != null
                  ? _chatService.getMessages(_chatId!)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyChatState();
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageItem(messages[index]),
                );
              },
            ),
          ),
          _buildMessageInput(), // This is now defined below
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            child: const Icon(Icons.person, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contact.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getLocalizedString('role_label'),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FIXED: Added the missing _buildMessageInput method
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _getLocalizedString('type_message'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // FIXED: Added the missing _buildEmptyChatState method
  Widget _buildEmptyChatState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_getLocalizedString('start_conversation')),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isCurrentUser = message.senderId == _currentUserId;
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;
    setState(() => _isLoading = true);
    try {
      await _chatService.sendMessage(
        chatId: _chatId!,
        content: _messageController.text.trim(),
        senderId: _currentUserId!,
        senderName: "Teacher", // Set your preferred display name logic
        isSticker: false,
      );
      _messageController.clear();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
