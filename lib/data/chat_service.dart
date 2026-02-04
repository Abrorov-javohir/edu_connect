// data/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ChatContact>> getStudentContacts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      // Get all classes where this student is enrolled
      final classStudentsSnapshot = await _firestore
          .collection("classStudents")
          .where("studentId", isEqualTo: userId)
          .get();

      if (classStudentsSnapshot.docs.isEmpty) return [];

      final Set<String> contactIds = {};
      final Map<String, String> contactRoles = {}; // Track roles

      // 1. Add teachers from enrolled classes
      for (final classStudentDoc in classStudentsSnapshot.docs) {
        final classId = classStudentDoc["classId"] as String;
        final classDoc = await _firestore
            .collection("classes")
            .doc(classId)
            .get();
        if (classDoc.exists) {
          final classData = classDoc.data()!;
          final teacherId = classData["teacherId"] as String?;
          if (teacherId != null && teacherId != userId) {
            contactIds.add(teacherId);
            contactRoles[teacherId] = "teacher";
          }
        }
      }

      // 2. Add classmates from ALL enrolled classes
      for (final classStudentDoc in classStudentsSnapshot.docs) {
        final classId = classStudentDoc["classId"] as String;
        
        // Get ALL students in this class (including current user)
        final classmatesSnapshot = await _firestore
            .collection("classStudents")
            .where("classId", isEqualTo: classId)
            .get();

        for (final classmateDoc in classmatesSnapshot.docs) {
          final classmateId = classmateDoc["studentId"] as String;
          // Skip current user
          if (classmateId != userId) {
            contactIds.add(classmateId);
            contactRoles[classmateId] = "student"; // Classmates are students
          }
        }
      }

      // 3. Fetch user details and latest messages
      final List<ChatContact> contacts = [];
      for (final contactId in contactIds) {
        final userDoc = await _firestore
            .collection("users")
            .doc(contactId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final role = contactRoles[contactId] ?? "student";

          // Get latest message
          final chatId = getChatId(userId, contactId);
          final latestMessageSnapshot = await _firestore
              .collection("chats")
              .doc(chatId)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .limit(1)
              .get();

          String lastMessage = "New conversation";
          DateTime lastMessageTime = DateTime.now();
          int unreadCount = 0;

          if (latestMessageSnapshot.docs.isNotEmpty) {
            final messageData = latestMessageSnapshot.docs.first.data()!;
            lastMessage = messageData["content"] ?? "New message";
            lastMessageTime = (messageData["timestamp"] as Timestamp).toDate();

            // Count unread messages from this contact
            if (messageData["senderId"] != userId) {
              final unreadSnapshot = await _firestore
                  .collection("chats")
                  .doc(chatId)
                  .collection("messages")
                  .where("senderId", isEqualTo: contactId)
                  .where("read", isEqualTo: false)
                  .get();
              unreadCount = unreadSnapshot.docs.length;
            }
          }

          contacts.add(
            ChatContact(
              id: contactId,
              name: userData["name"] ?? userData["fullName"] ?? "Unknown User",
              role: role,
              avatarUrl: userData["imageUrl"] ?? "",
              lastMessage: lastMessage,
              lastMessageTime: lastMessageTime,
              unreadCount: unreadCount,
            ),
          );
        }
      }

      // Sort: teachers first, then by latest message time
      contacts.sort((a, b) {
        if (a.role == "teacher" && b.role != "teacher") return -1;
        if (a.role != "teacher" && b.role == "teacher") return 1;
        return b.lastMessageTime.compareTo(a.lastMessageTime);
      });

      return contacts;
    } catch (e) {
      print("Error getting student contacts: $e");
      return [];
    }
  }

  String getChatId(String userId, String contactId) {
    return userId.compareTo(contactId) < 0
        ? "$userId-$contactId"
        : "$contactId-$userId";
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessage.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
    required String senderId,
    required String senderName,
    required bool isSticker,
  }) async {
    try {
      final messageData = {
        "content": content,
        "senderId": senderId,
        "senderName": senderName,
        "timestamp": FieldValue.serverTimestamp(),
        "isSticker": isSticker,
        "read": false,
      };

      // Save message to Firestore
      await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .add(messageData);

      // Mark as read for sender
      await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .where("senderId", isEqualTo: senderId)
          .where("read", isEqualTo: false)
          .get()
          .then((snapshot) {
            for (final doc in snapshot.docs) {
              doc.reference.update({"read": true});
            }
          });
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .where("senderId", isNotEqualTo: userId)
          .where("read", isEqualTo: false)
          .get();

      for (final message in unreadMessages.docs) {
        await message.reference.update({"read": true});
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }
}

class ChatContact {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatContact({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isSticker;
  final bool read;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isSticker,
    required this.read,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      content: map["content"] ?? "",
      senderId: map["senderId"] ?? "",
      senderName: map["senderName"] ?? "Unknown",
      timestamp: (map["timestamp"] as Timestamp).toDate(),
      isSticker: map["isSticker"] ?? false,
      read: map["read"] ?? false,
    );
  }
}