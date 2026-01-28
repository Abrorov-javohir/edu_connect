// student_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStudentData() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await firestore.collection("users").doc(uid).get();
    return doc.data();
  }

  Future<void> updateStudentData({
    required String name,
    required String phone,
    required String grade,
    required String password,
    String? imageUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Update Firestore fields
    Map<String, dynamic> updateData = {
      "name": name,
      "phone": phone,
      "grade": grade,
    };

    if (imageUrl != null) {
      updateData["imageUrl"] = imageUrl;
    }

    await firestore.collection("users").doc(uid).update(updateData);

    // Update password if provided
    if (password.trim().isNotEmpty) {
      await user.updatePassword(password);
    }
  }
}
