// screens/ai_chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_connect/data/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  _AiChatPageState createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  List<String> get _suggestions {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        return [
          "Fotosintezni tushuntiring 🌿",
          "Matematika yordami 📐",
          "Grammatika tekshiruvi ✍️",
          "O'qish bo'yicha maslahatlar 📚",
        ];
      case 'ru':
        return [
          "Объясните фотосинтез 🌿",
          "Помощь с математикой 📐",
          "Проверка грамматики ✍️",
          "Советы по учебе 📚",
        ];
      case 'en':
      default:
        return [
          "Explain Photosynthesis 🌿",
          "Math help 📐",
          "Grammar check ✍️",
          "Study tips 📚",
        ];
    }
  }

  void _sendMessage({String? text}) async {
    final messageText = text ?? _controller.text;
    if (messageText.trim().isEmpty) return;
    if (_auth.currentUser == null) return;

    final user = _auth.currentUser!;
    _controller.clear();
    setState(() => _isLoading = true);

    try {
      // 1. Save User Message
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ai_chats')
          .add({
            'role': 'user',
            'content': messageText,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 2. Prepare AI Placeholder
      DocumentReference aiMsgRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ai_chats')
          .add({
            'role': 'ai',
            'content': '',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 3. Stream Response
      String fullAiResponse = "";
      await _aiService.getStreamingResponse(messageText).forEach((chunk) {
        fullAiResponse = chunk;
        aiMsgRef.update({'content': fullAiResponse});
        _scrollToBottom();
      });

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Chat Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'ai_tutor': return "AI O'qituvchi";
          case 'clear_history': return "Tarixni tozalash";
          case 'ask_question': return "Savol bering...";
          case 'ai_partner': return "Sizning AI o'quv hamkoringiz";
          case 'start_question': return "Boshlash uchun savol bering!";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'ai_tutor': return "AI Репетитор";
          case 'clear_history': return "Очистить историю";
          case 'ask_question': return "Задайте вопрос...";
          case 'ai_partner': return "Ваш AI-партнер по обучению";
          case 'start_question': return "Задайте вопрос, чтобы начать!";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'ai_tutor': return "AI Tutor";
          case 'clear_history': return "Clear History";
          case 'ask_question': return "Ask anything...";
          case 'ai_partner': return "Your AI Study Partner";
          case 'start_question': return "Ask me a question to get started!";
          default: return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF121212) 
                : const Color(0xFFF0F2F5),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildChatStream()),
            if (!_isLoading)
              _buildSuggestionsList(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[800]
                : Colors.blue[100],
            child: Icon(Icons.psychology, 
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue),
          ),
          const SizedBox(width: 12),
          Text(
            _getLocalizedString('ai_tutor'),
            style: GoogleFonts.poppins(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.delete_sweep_outlined,
            color: Colors.redAccent,
          ),
          onPressed: _showClearChatDialog,
        ),
      ],
    );
  }

  Widget _buildChatStream() {
    final user = _auth.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(user?.uid)
          .collection('ai_chats')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return _buildEmptyState();

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: _buildChatBubble(
                data['role'] == 'user',
                data['content'] ?? "",
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatBubble(bool isUser, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 15,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[900]
                  : Colors.blue[50],
              child: const Icon(Icons.smart_toy, size: 18),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue[900] 
                        : Colors.blue[600])
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: content == "" ? "typing..." : content,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.poppins(
                    color: isUser 
                        ? Colors.white 
                        : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black87),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _getLocalizedString('ask_question'),
                    hintStyle: GoogleFonts.poppins(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isLoading ? null : () => _sendMessage(),
              child: CircleAvatar(
                backgroundColor: _isLoading 
                    ? Colors.grey 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.blue[800] 
                        : Colors.blue[600]),
                radius: 25,
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _suggestions
            .map(
              (s) => ActionChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                onPressed: () => _sendMessage(text: s),
                backgroundColor: Theme.of(context).cardColor,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade800
                        : Colors.blue.shade100,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.blue
                : Colors.blue)
                    .withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedString('ai_partner'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            _getLocalizedString('start_question'),
            style: GoogleFonts.poppins(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    String clearHistory = _getLocalizedString('clear_history');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clearHistory),
        content: const Text("This will delete all messages permanently."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = _auth.currentUser;
              var collection = await _firestore
                  .collection('users')
                  .doc(user!.uid)
                  .collection('ai_chats')
                  .get();
              for (var doc in collection.docs) {
                await doc.reference.delete();
              }
              Navigator.pop(context);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

              