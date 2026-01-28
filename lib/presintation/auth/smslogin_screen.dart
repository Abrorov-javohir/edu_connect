// // sms_login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:edu_connect/data/auth_service.dart';

// class SmsLoginScreen extends StatefulWidget {
//   const SmsLoginScreen({super.key});

//   @override
//   State<SmsLoginScreen> createState() => _SmsLoginScreenState();
// }

// class _SmsLoginScreenState extends State<SmsLoginScreen> {
//   final _phoneController = TextEditingController();
//   final _codeController = TextEditingController();
//   final _auth = AuthService();
//   bool _loading = false;
//   bool _codeSent = false;
//   String _verificationId = "";
//   int? _resendToken;

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
//               "Login with Phone",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Enter your phone number to receive a verification code",
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 40),

//             if (!_codeSent) ...[
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
//                           "Verify Code",
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

//             // BACK TO LOGIN OPTIONS
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
//                       // Navigate to email login screen
//                       Navigator.pushReplacementNamed(context, '/login');
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
//     if (_phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a phone number")),
//       );
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       await _auth.sendSmsCode("+998${_phoneController.text.trim()}");
//       // Code will be handled by the AuthService's codeSent callback
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to send code: $e")));
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
//         // Navigate based on user role
//         final userData = await _auth.getUserData();
//         final role = userData?.get("role") ?? "student";

//         if (role == "teacher") {
//           Navigator.pushReplacementNamed(context, "/teacher_home");
//         } else {
//           Navigator.pushReplacementNamed(context, "/student_home");
//         }
//       }
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Verification failed: $e")));
//     }
//   }
// }
