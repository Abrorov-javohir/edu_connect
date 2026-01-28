// widgets/notification_badge.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationBadge extends StatefulWidget {
  final VoidCallback onPressed;

  const NotificationBadge({super.key, required this.onPressed});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;
  bool _loading = true;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'notifications': return "Bildirishnomalar";
          case 'error_loading_notifications': return "Bildirishnomalarni yuklashda xato";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'notifications': return "Уведомления";
          case 'error_loading_notifications': return "Ошибка загрузки уведомлений";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'notifications': return "Notifications";
          case 'error_loading_notifications': return "Error loading notifications";
          default: return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _listenToNotifications();
  }

  void _loadUnreadCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final unreadSnapshot = await FirebaseFirestore.instance
          .collection("notifications")
          .doc(userId)
          .collection("userNotifications")
          .where("read", isEqualTo: false)
          .get();

      if (mounted) {
        setState(() {
          _unreadCount = unreadSnapshot.docs.length;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error loading unread count: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('error_loading_notifications')),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[800]
                : Colors.red[700],
          ),
        );
      }
    }
  }

  void _listenToNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection("notifications")
        .doc(userId)
        .collection("userNotifications")
        .where("read", isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unreadCount = snapshot.docs.length;
        });
      }
    }).onError((error) {
      print("Error listening to notifications: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('error_loading_notifications')),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[800]
                : Colors.red[700],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[700],
              size: 24,
            ),
            onPressed: widget.onPressed,
            splashRadius: 24,
            padding: EdgeInsets.zero,
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: FittedBox(
                child: Text(
                  _unreadCount > 9 ? "9+" : "$_unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}