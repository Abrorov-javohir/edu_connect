// // sms_register_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:edu_connect/data/auth_service.dart';

// class SmsRegisterScreen extends StatefulWidget {
//   const SmsRegisterScreen({super.key});

//   @override
//   State<SmsRegisterScreen> createState() => _SmsRegisterScreenState();
// }

// class _SmsRegisterScreenState extends State<SmsRegisterScreen> {
//   final _phoneController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _codeController = TextEditingController();
//   final _auth = AuthService();
//   bool _loading = false;
//   bool _codeSent = false;
//   final List<String> _roles = ["teacher", "student"];
//   String _selectedRole = "student";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Register with Phone",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Enter your phone number and name to register",
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 40),

//             if (!_codeSent) ...[
//               // FULL NAME INPUT
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: "Full Name",
//                   prefixIcon: const Icon(Icons.person),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // PHONE NUMBER INPUT
//               TextField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: "Phone Number",
//                   prefixText: "+998",
//                   prefixIcon: const Icon(Icons.phone),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // ROLE SELECTION
//               DropdownButtonFormField(
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//                 value: _selectedRole,
//                 items: _roles
//                     .map(
//                       (e) => DropdownMenuItem(
//                         value: e,
//                         child: Text(e.toUpperCase()),
//                       ),
//                     )
//                     .toList(),
//                 onChanged: (v) {
//                   if (v != null) {
//                     setState(() {
//                       _selectedRole = v;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 20),

//               // SEND CODE BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: _loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 0,
//                         ),
//                         onPressed: _sendCode,
//                         child: const Text(
//                           "Send Verification Code",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//               ),
//             ] else ...[
//               // VERIFICATION CODE INPUT
//               TextField(
//                 controller: _codeController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: "Verification Code",
//                   prefixIcon: const Icon(Icons.code),
//                   filled: true,
//                   fillColor: Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // VERIFY CODE BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: _loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 0,
//                         ),
//                         onPressed: _verifyCode,
//                         child: const Text(
//                           "Verify & Register",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 16),

//               // RESEND CODE
//               Center(
//                 child: TextButton(
//                   onPressed: _sendCode,
//                   child: const Text(
//                     "Resend Code",
//                     style: TextStyle(color: Colors.blue),
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 30),

//             // BACK TO REGISTER OPTIONS
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       "Back",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   TextButton(
//                     onPressed: () {
//                       // Navigate to email register screen
//                       Navigator.pushReplacementNamed(context, '/register');
//                     },
//                     child: const Text(
//                       "Use Email Instead",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _sendCode() async {
//     if (_nameController.text.trim().isEmpty ||
//         _phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       // ✅ USE AuthService method
//       await _auth.sendSmsCode("+998${_phoneController.text.trim()}");
//       // Code will be handled by AuthService's codeSent callback
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to send code: $e")));
//     }
//   }

//   String _mapFirebaseException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'invalid-phone-number':
//         return 'Phone number is invalid. Please check format.';
//       case 'too-many-requests':
//         return 'Too many requests. Please try again later.';
//       case 'app-not-authorized':
//         return 'App not authorized for phone auth. Contact support.';
//       default:
//         return e.message ?? 'Unknown error occurred.';
//     }
//   }

//   Future<void> _verifyCode() async {
//     if (_codeController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter the verification code")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final user = await _auth.verifySmsCode(_codeController.text.trim());

//       if (user != null) {
//         // FIRESTOREGA USER QO’SHILADI
//         await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//           "uid": user.uid,
//           "name": _nameController.text.trim(),
//           "phone": user.phoneNumber,
//           "role": _selectedRole,
//           "created_at": FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         // ROLE GA KO’RA NAVIGATSIYA
//         if (_selectedRole == "teacher") {
//           Navigator.pushReplacementNamed(context, "/teacher_home");
//         } else {
//           Navigator.pushReplacementNamed(context, "/student_home");
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() => _loading = false);
//       String message = _mapFirebaseException(e);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Verification failed: $message")));
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Verification failed: $e")));
//     }
//   }
// }
