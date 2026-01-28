// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';

// class TeacherProfileScreen extends StatefulWidget {
//   const TeacherProfileScreen({super.key});

//   @override
//   State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
// }

// class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   bool _isLoading = true;
//   Map<String, dynamic>? _userData;
//   String? _imageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final doc = await _firestore.collection('users').doc(user.uid).get();
//         if (doc.exists) {
//           setState(() {
//             _userData = doc.data()!;
//             _imageUrl = doc['imageUrl'];
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       print("Error loading user  $e");
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       await _uploadImageToFirebase(File(pickedFile.path));
//     }
//   }

//   Future<void> _uploadImageToFirebase(File imageFile) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images')
//           .child('${user.uid}.jpg');

//       await storageRef.putFile(imageFile);
//       final imageUrl = await storageRef.getDownloadURL();

//       await _firestore.collection('users').doc(user.uid).update({
//         'imageUrl': imageUrl,
//       });

//       if (mounted) {
//         setState(() {
//           _imageUrl = imageUrl;
//         });
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Profile image updated!')));
//     } catch (e) {
//       print("Error uploading image: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
//     }
//   }

//   Future<void> _editProfileDialog() async {
//     final nameController = TextEditingController(
//       text: _userData?['name'] ?? '',
//     );
//     final phoneController = TextEditingController(
//       text: _userData?['phone'] ?? '',
//     );
//     String? selectedImageUrl = _imageUrl;
//     File? selectedImageFile;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: Text("Edit Profile", style: GoogleFonts.poppins()),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         GestureDetector(
//                           onTap: () async {
//                             final XFile? pickedFile = await ImagePicker()
//                                 .pickImage(
//                                   source: ImageSource.gallery,
//                                   imageQuality: 70,
//                                 );
//                             if (pickedFile != null) {
//                               setDialogState(() {
//                                 selectedImageFile = File(pickedFile.path);
//                                 selectedImageUrl = null;
//                               });
//                             }
//                           },
//                           child: CircleAvatar(
//                             radius: 40,
//                             backgroundImage: selectedImageFile != null
//                                 ? FileImage(selectedImageFile!)
//                                 : (selectedImageUrl != null
//                                           ? NetworkImage(selectedImageUrl!)
//                                           : const NetworkImage(
//                                               "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
//                                             ))
//                                       as ImageProvider,
//                           ),
//                         ),
//                         Positioned(
//                           right: 0,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue,
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                             child: PopupMenuButton<String>(
//                               icon: Icon(
//                                 Icons.camera_alt,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                               itemBuilder: (context) => [
//                                 PopupMenuItem(
//                                   value: 'camera',
//                                   child: Text(
//                                     "Camera",
//                                     style: GoogleFonts.poppins(),
//                                   ),
//                                 ),
//                                 PopupMenuItem(
//                                   value: 'gallery',
//                                   child: Text(
//                                     "Gallery",
//                                     style: GoogleFonts.poppins(),
//                                   ),
//                                 ),
//                               ],
//                               onSelected: (value) async {
//                                 final XFile? pickedFile = await ImagePicker()
//                                     .pickImage(
//                                       source: value == 'camera'
//                                           ? ImageSource.camera
//                                           : ImageSource.gallery,
//                                       imageQuality: 70,
//                                     );

//                                 if (pickedFile != null) {
//                                   setDialogState(() {
//                                     selectedImageFile = File(pickedFile.path);
//                                     selectedImageUrl = null;
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         labelText: "Name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: phoneController,
//                       decoration: InputDecoration(
//                         labelText: "Phone",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text("Cancel", style: GoogleFonts.poppins()),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     Navigator.pop(context);

//                     // Upload new image if selected
//                     if (selectedImageFile != null) {
//                       await _uploadImageToFirebase(selectedImageFile!);
//                     }

//                     // Update profile
//                     await _updateProfile(
//                       nameController.text.trim(),
//                       phoneController.text.trim(),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text("Save", style: GoogleFonts.poppins()),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _updateProfile(String name, String phone) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       await _firestore.collection('users').doc(user.uid).update({
//         'name': name,
//         'phone': phone,
//       });

//       if (mounted) {
//         setState(() {
//           _userData!['name'] = name;
//           _userData!['phone'] = phone;
//         });
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
//     } catch (e) {
//       print("Error updating profile: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Loading profile...",
//                 style: GoogleFonts.poppins(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_userData == null) {
//       return Scaffold(
//         body: Center(
//           child: Text(
//             'User data not found',
//             style: GoogleFonts.poppins(fontSize: 18),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           "${_capitalize(_userData!['role'] ?? 'User')}",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _signOut();
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'logout',
//                 child: Text("Log out", style: GoogleFonts.poppins()),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Stack(
//                 alignment: Alignment.bottomRight,
//                 children: [
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 2,
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundImage: _imageUrl != null
//                           ? NetworkImage(_imageUrl!)
//                           : const NetworkImage(
//                               "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
//                             ),
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.blue,
//                         border: Border.all(color: Colors.white, width: 3),
//                       ),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.camera_alt,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                         onPressed: _pickImage,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               Text(
//                 _userData!['name'] ?? "Unnamed",
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 _capitalize(_userData!['role'] ?? 'User'),
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey[600],
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 30),

//               _buildInfoCard("Email", _userData!['email'] ?? '-', Icons.email),
//               _buildInfoCard("Phone", _userData!['phone'] ?? '-', Icons.phone),
//               _buildInfoCard(
//                 "Role",
//                 _capitalize(_userData!['role'] ?? 'User'),
//                 Icons.person,
//               ),

//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _editProfileDialog,
//                   icon: const Icon(Icons.edit),
//                   label: Text("Edit Profile", style: GoogleFonts.poppins()),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _signOut(),
//                   icon: const Icon(Icons.logout),
//                   label: Text("Log out", style: GoogleFonts.poppins()),
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.red.shade400),
//                     foregroundColor: Colors.red.shade400,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String title, String subtitle, IconData icon) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: Colors.blue.shade700),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
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

//   String _capitalize(String s) {
//     if (s.isEmpty) return s;
//     return s[0].toUpperCase() + s.substring(1).toLowerCase();
//   }

//   Future<void> _signOut() async {
//     await _auth.signOut();
//     Navigator.pop(context);
//   }
// }
