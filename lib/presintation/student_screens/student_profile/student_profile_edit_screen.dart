// screens/student_edit_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StudentEditScreen extends StatefulWidget {
  const StudentEditScreen({super.key});

  @override
  State<StudentEditScreen> createState() => _StudentEditScreenState();
}

class _StudentEditScreenState extends State<StudentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _imageFile;
  String? _localImagePath; // Local file path
  bool _loading = true;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController gradeController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    gradeController = TextEditingController();
    passwordController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    gradeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        nameController.text = data["name"] ?? "";
        phoneController.text = data["phone"] ?? "";
        gradeController.text = data["grade"] ?? "";
        passwordController.text = "";

        // Load local image path with proper null handling
        await _loadLocalImagePath(user.uid);

        if (mounted) {
          setState(() => _loading = false);
        }
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load data: $e")));
      }
    }
  }

  Future<void> _loadLocalImagePath(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_path_$userId');

      // Only set if file actually exists
      if (imagePath != null && File(imagePath).existsSync()) {
        if (mounted) {
          setState(() {
            _localImagePath = imagePath;
          });
        }
      } else {
        // Clear invalid path from preferences
        await prefs.remove('profile_image_path_$userId');
        if (mounted) {
          setState(() {
            _localImagePath = null;
          });
        }
      }
    } catch (e) {
      print("Error loading image path: $e");
      if (mounted) {
        setState(() {
          _localImagePath = null;
        });
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked != null && mounted) {
        // Compress image before saving locally
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          picked.path,
          quality: 85,
          minHeight: 400,
          minWidth: 400,
        );

        if (compressedBytes != null) {
          // Get app directory
          final dir = await getApplicationDocumentsDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '${dir.path}/profile_$fileName';

          final file = File(filePath);
          await file.writeAsBytes(compressedBytes);

          if (mounted) {
            setState(() {
              _imageFile = file;
              _localImagePath = filePath;
            });
          }
        } else {
          final file = File(picked.path);
          if (mounted) {
            setState(() {
              _imageFile = file;
              _localImagePath = picked.path;
            });
          }
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        setState(() {
          _imageFile = null;
          _localImagePath = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
      }
    }
  }

  Future<void> saveImageToPrefs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Only save if file exists
      if (_localImagePath != null && File(_localImagePath!).existsSync()) {
        await prefs.setString(
          'profile_image_path_${user.uid}',
          _localImagePath!,
        );
      } else {
        // Remove invalid path
        await prefs.remove('profile_image_path_${user.uid}');
        if (mounted) {
          setState(() {
            _localImagePath = null;
          });
        }
      }
    } catch (e) {
      print("Error saving image to prefs: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save image: $e")));
      }
    }
  }

  Future<bool> reauthenticateUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      String email = user.email ?? "";
      String? password;

      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          String inputPassword = "";
          return AlertDialog(
            title: Text(
              _getLocalizedString('re_authenticate'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_getLocalizedString('current_password_prompt')}$email",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _getLocalizedString('current_password'),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => inputPassword = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _getLocalizedString('cancel'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, inputPassword);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[800]
                      : Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getLocalizedString('confirm'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );

      password = result;

      if (password != null && password.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (e) {
      print("Re-authentication failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_getLocalizedString('re_auth_failed')}$e")),
        );
      }
      return false;
    }
    return false;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (mounted) {
        setState(() => _loading = true);
      }

      // Save image to local storage and preferences first
      if (_imageFile != null) {
        await saveImageToPrefs();
      }

      // Update Firestore fields
      await _firestore.collection("users").doc(user.uid).update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "grade": gradeController.text.trim(),
      });

      // Update password if provided
      if (passwordController.text.trim().isNotEmpty) {
        bool authenticated = await reauthenticateUser();
        if (authenticated) {
          await user.updatePassword(passwordController.text.trim());
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('profile_updated_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving changes: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('failed_update_profile')}$e"),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[800]
                : Colors.red[700],
          ),
        );
      }
    }
  }

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        return {
              'edit_profile': "Profilni Tahrirlash",
              'full_name': "To'liq Ism",
              'phone_number': "Telefon Raqam",
              'new_password': "Yangi Parol (Ixtiyoriy)",
              'enter_full_name': "Iltimos, to'liq ismingizni kiriting",
              'valid_phone': "Iltimos, to'g'ri telefon raqam kiriting",
              'password_min_length':
                  "Parol kamida 6 ta belgidan iborat bo'lishi kerak",
              'save_changes': "O'zgarishlarni Saqlash",
              'cancel': "Bekor Qilish",
              're_authenticate': "Qayta Autentifikatsiya",
              'current_password_prompt':
                  "Profilni yangilash uchun joriy parolingizni kiriting: ",
              'current_password': "Joriy Parol",
              'confirm': "Tasdiqlash",
              'profile_updated_success': "Profil muvaffaqiyatli yangilandi!",
              'failed_update_profile':
                  "Profilni yangilashda xatolik yuz berdi: ",
              'failed_pick_image': "Rasm tanlashda xatolik yuz berdi: ",
              're_auth_failed': "Qayta autentifikatsiya amalga oshmadi: ",
            }[key] ??
            key;
      case 'ru':
        return {
              'edit_profile': "Редактировать Профиль",
              'full_name': "Полное Имя",
              'phone_number': "Номер Телефона",
              'new_password': "Новый Пароль (необязательно)",
              'enter_full_name': "Пожалуйста, введите ваше полное имя",
              'valid_phone':
                  "Пожалуйста, введите действительный номер телефона",
              'password_min_length':
                  "Пароль должен содержать не менее 6 символов",
              'save_changes': "Сохранить Изменения",
              'cancel': "Отмена",
              're_authenticate': "Повторная аутентификация",
              'current_password_prompt':
                  "Введите текущий пароль для обновления профиля: ",
              'current_password': "Текущий Пароль",
              'confirm': "Подтвердить",
              'profile_updated_success': "Профиль успешно обновлен!",
              'failed_update_profile': "Не удалось обновить профиль: ",
              'failed_pick_image': "Не удалось выбрать изображение: ",
              're_auth_failed': "Повторная аутентификация не удалась: ",
            }[key] ??
            key;
      default:
        return {
              'edit_profile': "Edit Profile",
              'full_name': "Full Name",
              'phone_number': "Phone Number",
              'new_password': "New Password (Optional)",
              'enter_full_name': "Please enter your full name",
              'valid_phone': "Please enter a valid phone number",
              'password_min_length': "Password must be at least 6 characters",
              'save_changes': "Save Changes",
              'cancel': "Cancel",
              're_authenticate': "Re-authenticate",
              'current_password_prompt':
                  "Enter your current password to update profile: ",
              'current_password': "Current Password",
              'confirm': "Confirm",
              'profile_updated_success': "Profile updated successfully!",
              'failed_update_profile': "Failed to update profile: ",
              'failed_pick_image': "Failed to pick image: ",
              're_auth_failed': "Re-authentication failed: ",
            }[key] ??
            key;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          title: Text(
            _getLocalizedString('edit_profile'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[400]
                : Colors.blue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          _getLocalizedString('edit_profile'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Picture Section
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          // ✅ FIXED: Use Image.file for local files, NOT CachedNetworkImage
                          child:
                              _localImagePath != null &&
                                  File(_localImagePath!).existsSync()
                              ? Image.file(
                                  File(_localImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey,
                                ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.blue[800]
                                : Colors.blue[700],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.blue
                                            : Colors.blue)
                                        .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: pickImage,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildFormField(
                controller: nameController,
                labelText: _getLocalizedString('full_name'),
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _getLocalizedString('enter_full_name');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildFormField(
                controller: phoneController,
                labelText: _getLocalizedString('phone_number'),
                icon: Icons.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[0-9+\-\s\(\)]+$').hasMatch(value)) {
                      return _getLocalizedString('valid_phone');
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildFormField(
                controller: gradeController,
                labelText: "Grade",
                icon: Icons.school,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[0-9A-Za-z\s]+$').hasMatch(value)) {
                      return "Please enter a valid grade";
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildFormField(
                controller: passwordController,
                labelText: _getLocalizedString('new_password'),
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 6) {
                    return _getLocalizedString('password_min_length');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue[800]
                          : Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _getLocalizedString('save_changes'),
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Button
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!
                            : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getLocalizedString('cancel'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?)? validator,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[700],
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue[300]
                : Colors.blue[700],
            size: 22,
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[300]!
                  : Colors.blue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        validator: validator,
      ),
    );
  }
}
