// screens/chat_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/data/chat_service.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatContact contact;

  const ChatDetailScreen({super.key, required this.contact});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatId != null && _currentUserId != null) {
          _chatService.markMessagesAsRead(_chatId!, _currentUserId!);
        }
      });
    }
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'unable_to_load':
            return "Chat yuklanmadi";
          case 'permissions_check':
            return "Iltimos, tizimga kirganingiz va kerakli ruxsatnomaga ega ekanligingizni tekshiring.";
          case 'start_conversation':
            return "Suhbat boshlang!";
          case 'send_message':
            return "${widget.contact.name}ga xabar yuborish uchun boshlang.";
          case 'type_message':
            return "Xabar yozing...";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'unable_to_load':
            return "Не удалось загрузить чат";
          case 'permissions_check':
            return "Убедитесь, что вы вошли в систему и имеете необходимые разрешения.";
          case 'start_conversation':
            return "Начните разговор!";
          case 'send_message':
            return "Отправьте сообщение ${widget.contact.name}, чтобы начать.";
          case 'type_message':
            return "Введите сообщение...";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'unable_to_load':
            return "Unable to load chat";
          case 'permissions_check':
            return "Please make sure you're logged in and have proper permissions.";
          case 'start_conversation':
            return "Start a conversation!";
          case 'send_message':
            return "Send a message to ${widget.contact.name} to get started.";
          case 'type_message':
            return "Type a message...";
          default:
            return key;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null || _currentUserId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red[900]?.withOpacity(0.2)
                        : Colors.red[50],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.red[700]!
                          : Colors.red[200]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red[400]
                        : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _getLocalizedString('unable_to_load'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    textAlign: TextAlign.center,
                    _getLocalizedString('permissions_check'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(_chatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyChatState();
                }

                final messages = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: widget.contact.role == "teacher"
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.blue[100])
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.green[900]
                      : Colors.green[100]),
            child: Icon(
              widget.contact.role == "teacher" ? Icons.school : Icons.person,
              color: widget.contact.role == "teacher"
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]
                        : Colors.blue[700])
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.green[300]
                        : Colors.green[700]),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contact.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ),
              Text(
                widget.contact.role == "teacher" ? "Teacher" : "Classmate",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[300]
                      : Colors.blue[200],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).appBarTheme.foregroundColor,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]?.withOpacity(0.2)
                    : Colors.blue[50],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue
                                : Colors.blue)
                            .withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 56,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[300]
                    : Colors.blue[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getLocalizedString('start_conversation'),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                textAlign: TextAlign.center,
                _getLocalizedString('send_message'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isCurrentUser = message.senderId == _currentUserId;

    return FadeIn(
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.contact.role == "teacher"
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[900]
                            : Colors.blue[100])
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.green[900]
                            : Colors.green[100]),
                  child: Icon(
                    widget.contact.role == "teacher"
                        ? Icons.school
                        : Icons.person,
                    color: widget.contact.role == "teacher"
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[300]
                              : Colors.blue[700])
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.green[300]
                              : Colors.green[700]),
                    size: 18,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (message.isSticker)
                    _buildSticker(message.content)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[900]
                                  : Colors.blue[700])
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.blue
                                        : Colors.grey)
                                    .withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: isCurrentUser
                            ? null
                            : Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!,
                                width: 1.5,
                              ),
                      ),
                      child: Text(
                        message.content,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isCurrentUser
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[900]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 52),
          ],
        ),
      ),
    );
  }

  Widget _buildSticker(String stickerType) {
    IconData icon;
    Color color;

    switch (stickerType.toLowerCase()) {
      case 'smile':
        icon = Icons.sentiment_satisfied;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.yellow[400]!
            : Colors.yellow[700]!;
        break;
      case 'happy':
        icon = Icons.mood;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.green[400]!
            : Colors.green[700]!;
        break;
      case 'sad':
        icon = Icons.sentiment_dissatisfied;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.blue[400]!
            : Colors.blue[700]!;
        break;
      case 'angry':
        icon = Icons.sentiment_very_dissatisfied;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.red[400]!
            : Colors.red[700]!;
        break;
      case 'love':
        icon = Icons.favorite;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.pink[400]!
            : Colors.pink[700]!;
        break;
      case 'thumbsup':
        icon = Icons.thumb_up;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.green[400]!
            : Colors.green[700]!;
        break;
      case 'thumbsdown':
        icon = Icons.thumb_down;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.red[400]!
            : Colors.red[700]!;
        break;
      default:
        icon = Icons.sentiment_satisfied;
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]!
            : Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, size: 36, color: color),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showStickerSheet,
              icon: Icon(
                Icons.insert_emoticon,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _getLocalizedString('type_message'),
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[500],
                  fontSize: 15,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[800]
                  : Colors.blue[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _currentUserId == null ||
        _chatId == null)
      return;

    setState(() => _isLoading = true);

    final messageText = _messageController.text.trim();
    final isSticker = _isStickerMessage(messageText);
    final currentUser = FirebaseAuth.instance.currentUser!;

    try {
      await _chatService.sendMessage(
        chatId: _chatId!,
        content: messageText,
        senderId: _currentUserId!,
        senderName: currentUser.displayName ?? "Student",
        isSticker: isSticker,
      );

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send message: $e"),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.red[900]
              : Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isStickerMessage(String message) {
    return [
      'smile',
      'happy',
      'sad',
      'angry',
      'love',
      'thumbsup',
      'thumbsdown',
    ].contains(message.toLowerCase());
  }

  void _showStickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose a sticker",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStickerButton(
                    'smile',
                    Icons.sentiment_satisfied,
                    Colors.yellow[700]!,
                  ),
                  _buildStickerButton('happy', Icons.mood, Colors.green[700]!),
                  _buildStickerButton(
                    'sad',
                    Icons.sentiment_dissatisfied,
                    Colors.blue[700]!,
                  ),
                  _buildStickerButton(
                    'angry',
                    Icons.sentiment_very_dissatisfied,
                    Colors.red[700]!,
                  ),
                  _buildStickerButton(
                    'love',
                    Icons.favorite,
                    Colors.pink[700]!,
                  ),
                  _buildStickerButton(
                    'thumbsup',
                    Icons.thumb_up,
                    Colors.green[700]!,
                  ),
                  _buildStickerButton(
                    'thumbsdown',
                    Icons.thumb_down,
                    Colors.red[700]!,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickerButton(String type, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _messageController.text = type;
        Navigator.pop(context);
        _sendMessage();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year != now.year) {
      return "${time.day}/${time.month}/${time.year}";
    }
    if (time.day != now.day || time.month != now.month) {
      return "${time.day}/${time.month}";
    }
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
