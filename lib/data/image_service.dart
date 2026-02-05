// // lib/services/imagekit_service.dart
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ImageKitService {
//   static const String _publicKey = "your_public_key_here"; // Put your key here
//   static const String _uploadUrl = "https://upload.imagekit.io/api/v1/files/upload";

//   Future<String?> uploadImage(File imageFile, String userId) async {
//     try {
//       final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

//       // Add file
//       request.files.add(
//         await http.MultipartFile.fromPath('file', imageFile.path),
//       );

//       // ✅ FIXED: Added {} around userId
//       request.fields['fileName'] = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       request.fields['useUniqueFileName'] = "true";
//       request.fields['folder'] = "/profile_pictures/";

//       // Authentication
//       final auth = 'Basic ${base64Encode(utf8.encode('$_publicKey:'))}';
//       request.headers['Authorization'] = auth;

//       final response = await request.send();
      
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         final json = jsonDecode(responseData);
//         return json['url'] as String?;
//       } else {
//         print("Upload failed: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("ImageKit error: $e");
//       return null;
//     }
//   }
// }