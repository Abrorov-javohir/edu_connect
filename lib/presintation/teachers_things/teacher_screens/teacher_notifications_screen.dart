// screens/teacher_notifications_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/widget/notification_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  List<DocumentSnapshot> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      // Listen to notifications in real-time
      FirebaseFirestore.instance
          .collection("notifications")
          .doc(userId)
          .collection("userNotifications")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((snapshot) {
            setState(() {
              _notifications = snapshot.docs;
              _loading = false;
            });
          })
          .onError((error) {
            print("Error loading notifications: $error");
            setState(() => _loading = false);
          });
    } catch (e) {
      print("Error initializing notifications: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(userId)
          .collection("userNotifications")
          .doc(notificationId)
          .update({"read": true, "readAt": FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> _handleNotificationAction(
    String taskId,
    String studentId,
    String type,
  ) async {
    if (type == "task_completed" || type == "proof_submitted") {
      // Navigate to task details screen where teacher can accept/reject
      Navigator.pushNamed(
        context,
        '/teacher_task_details',
        arguments: {'taskId': taskId, 'studentId': studentId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final data = notification.data() as Map<String, dynamic>;

                return NotificationCard(
                  notificationId: notification.id,
                  title: data["title"] ?? "New Notification",
                  body: data["body"] ?? "",
                  type: data["type"] ?? "general",
                  timestamp: (data["timestamp"] as Timestamp).toDate(),
                  isRead: data["read"] ?? false,
                  taskId: data["taskId"] ?? "",
                  studentId: data["studentId"] ?? "",
                  onMarkAsRead: _markAsRead,
                  onAction: _handleNotificationAction,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[100]!, width: 2),
            ),
            child: Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "No Notifications",
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "You'll receive notifications when students complete tasks or submit proof of their work.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
