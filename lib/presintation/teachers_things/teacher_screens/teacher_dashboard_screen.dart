// In your teacher dashboard screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _listenToUnreadNotifications();
  }

  void _listenToUnreadNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection("notifications")
        .doc(userId)
        .collection("userNotifications")
        .where("read", isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _unreadNotifications = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherNotificationsScreen(),
                    ),
                  );
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadNotifications > 9 ? "9+" : "$_unreadNotifications",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // ... rest of your dashboard
    );
  }
}