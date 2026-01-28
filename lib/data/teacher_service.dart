import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherService {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getTeacherData() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await firestore.collection("teachers").doc(uid).get();
    return doc.data();
  }

  Future<void> updateTeacherData({
    required String name,
    required String phone,
    required String password,
    required String imageUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // 1. Update Firestore fields
    await firestore.collection("teachers").doc(uid).update({
      "fullName": name,
      "phone": phone,
      "image": imageUrl,
    });

    // 2. Update password if changed
    if (password.trim().isNotEmpty) {
      await user.updatePassword(password);
    }
  }
}
