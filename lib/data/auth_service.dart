// auth_service.dart (complete mixed version)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  // SMS AUTHENTICATION

  /// Send SMS verification code
  Future<void> sendSmsCode(String phoneNumber) async {
    print("Attempting to send SMS to: $phoneNumber");

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Verification completed automatically");
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.code} - ${e.message}");
          throw Exception(_mapAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Code sent successfully! Verification ID: $verificationId");
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto-retrieval timeout: $verificationId");
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print("SMS Verification Error: $e");
      rethrow;
    }
  }

  /// Verify SMS code
  Future<User?> verifySmsCode(String smsCode) async {
    print("Attempting to verify code: $smsCode");

    try {
      if (_verificationId == null) {
        throw Exception("Verification ID not found. Please resend code.");
      }

      print("Using verification ID: $_verificationId");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print("Verification successful! User: ${userCredential.user?.uid}");

      // Check if user exists in Firestore, if not create profile
      final user = userCredential.user;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection("users")
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          print("Creating new user profile for: ${user.uid}");
          // Create user profile with default data
          await _firestore.collection("users").doc(user.uid).set({
            "name": "New User",
            "phone": user.phoneNumber,
            "role": "student", // Default role
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      print("SMS Verification Error: $e");
      rethrow;
    }
  }

  // EMAIL AUTHENTICATION

  /// Register with email and password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    await _firestore.collection("users").doc(user!.uid).set({
      "name": fullName,
      "email": email,
      "role": role,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return user;
  }

  /// Login with email and password
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  // PASSWORD RESET

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // UTILITY METHODS

  /// Helper to map Firebase Auth exceptions to user-friendly messages
  String _mapAuthException(FirebaseAuthException e) {
    print("Firebase Auth Error: ${e.code} - ${e.message}");
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'session-expired':
        return 'Session expired. Please resend the code.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Verification ID expired. Please resend the code.';
      case 'app-not-authorized':
        return 'App not authorized for phone auth. Check Firebase setup.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Contact support.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return e.message ?? 'An error occurred during phone verification.';
    }
  }

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get user data from Firestore
  Future<DocumentSnapshot?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection("users").doc(user.uid).get();
        return doc.exists ? doc : null;
      } catch (e) {
        print("Error getting user  $e");
        return null;
      }
    }
    return null;
  }

  /// Logout user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Set verification ID manually (for debugging)
  void setVerificationId(String id) {
    _verificationId = id;
    print("Verification ID saved in AuthService: $id");
  }
}
