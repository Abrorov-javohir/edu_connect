// data/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendChatNotification({
    required String recipientId,
    required String title,
    required String body,
    required String chatId,
  }) async {
    try {
      final sender = FirebaseAuth.instance.currentUser!;
      
      // Create notification in recipient's collection
      await _firestore
          .collection("notifications")
          .doc(recipientId)
          .collection("userNotifications")
          .add({
        "title": title,
        "body": body,
        "type": "chat_message",
        "chatId": chatId,
        "senderId": sender.uid,
        "senderName": sender.displayName ?? "User",
        "timestamp": FieldValue.serverTimestamp(),
        "read": false,
      });

      // Also create in global notifications for real-time updates
      await _firestore.collection("notifications").add({
        "recipientId": recipientId,
        "title": title,
        "body": body,
        "type": "chat_message",
        "chatId": chatId,
        "senderId": sender.uid,
        "senderName": sender.displayName ?? "User",
        "timestamp": FieldValue.serverTimestamp(),
        "read": false,
      });
    } catch (e) {
      print("Error sending chat notification: $e");
    }
  }
}