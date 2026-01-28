// widgets/chat_list_item.dart
import 'package:edu_connect/data/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatListItem extends StatelessWidget {
  final ChatContact contact;
  final VoidCallback onChatTap;

  const ChatListItem({super.key, required this.contact, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onChatTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              
              const SizedBox(width: 16),
              
              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Role Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.role == "teacher")
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[300]!, width: 1),
                            ),
                            child: Text(
                              "Teacher",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Last Message
                    Text(
                      contact.lastMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Time and Unread Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(contact.lastMessageTime),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (contact.unreadCount > 0)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${contact.unreadCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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
  }

  Widget _buildAvatar() {
    if (contact.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(contact.avatarUrl),
        backgroundColor: Colors.grey[200],
      );
    }
    
    return CircleAvatar(
      radius: 28,
      backgroundColor: contact.role == "teacher" ? Colors.blue[100] : Colors.green[100],
      child: Icon(
        contact.role == "teacher" ? Icons.school : Icons.person,
        color: contact.role == "teacher" ? Colors.blue[700] : Colors.green[700],
        size: 28,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays}d";
      } else {
        return "${time.month}/${time.day}";
      }
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m";
    } else {
      return "Now";
    }
  }
}