// screens/student_edit_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class StudentEditScreen extends StatefulWidget {
  const StudentEditScreen({super.key});

  @override
  State<StudentEditScreen> createState() => _StudentEditScreenState();
}

class _StudentEditScreenState extends State<StudentEditScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  bool _loading = true;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController gradeController;
  late final TextEditingController passwordController;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'edit_profile':
            return "Profilni Tahrirlash";
          case 'full_name':
            return "To'liq Ism";
          case 'phone_number':
            return "Telefon Raqam";
          case 'new_password':
            return "Yangi Parol (Ixtiyoriy)";
          case 'enter_full_name':
            return "Iltimos, to'liq ismingizni kiriting";
          case 'valid_phone':
            return "Iltimos, to'g'ri telefon raqam kiriting";
          case 'password_min_length':
            return "Parol kamida 6 ta belgidan iborat bo'lishi kerak";
          case 'save_changes':
            return "O'zgarishlarni Saqlash";
          case 'cancel':
            return "Bekor Qilish";
          case 're_authenticate':
            return "Qayta Autentifikatsiya";
          case 'current_password_prompt':
            return "Profilni yangilash uchun joriy parolingizni kiriting: ";
          case 'current_password':
            return "Joriy Parol";
          case 'confirm':
            return "Tasdiqlash";
          case 'profile_updated_success':
            return "Profil muvaffaqiyatli yangilandi!";
          case 'failed_update_profile':
            return "Profilni yangilashda xatolik yuz berdi: ";
          case 'failed_pick_image':
            return "Rasm tanlashda xatolik yuz berdi: ";
          case 're_auth_failed':
            return "Qayta autentifikatsiya amalga oshmadi: ";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'edit_profile':
            return "Редактировать Профиль";
          case 'full_name':
            return "Полное Имя";
          case 'phone_number':
            return "Номер Телефона";
          case 'new_password':
            return "Новый Пароль (необязательно)";
          case 'enter_full_name':
            return "Пожалуйста, введите ваше полное имя";
          case 'valid_phone':
            return "Пожалуйста, введите действительный номер телефона";
          case 'password_min_length':
            return "Пароль должен содержать не менее 6 символов";
          case 'save_changes':
            return "Сохранить Изменения";
          case 'cancel':
            return "Отмена";
          case 're_authenticate':
            return "Повторная аутентификация";
          case 'current_password_prompt':
            return "Введите текущий пароль для обновления профиля: ";
          case 'current_password':
            return "Текущий Пароль";
          case 'confirm':
            return "Подтвердить";
          case 'profile_updated_success':
            return "Профиль успешно обновлен!";
          case 'failed_update_profile':
            return "Не удалось обновить профиль: ";
          case 'failed_pick_image':
            return "Не удалось выбрать изображение: ";
          case 're_auth_failed':
            return "Повторная аутентификация не удалась: ";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'edit_profile':
            return "Edit Profile";
          case 'full_name':
            return "Full Name";
          case 'phone_number':
            return "Phone Number";
          case 'new_password':
            return "New Password (Optional)";
          case 'enter_full_name':
            return "Please enter your full name";
          case 'valid_phone':
            return "Please enter a valid phone number";
          case 'password_min_length':
            return "Password must be at least 6 characters";
          case 'save_changes':
            return "Save Changes";
          case 'cancel':
            return "Cancel";
          case 're_authenticate':
            return "Re-authenticate";
          case 'current_password_prompt':
            return "Enter your current password to update profile: ";
          case 'current_password':
            return "Current Password";
          case 'confirm':
            return "Confirm";
          case 'profile_updated_success':
            return "Profile updated successfully!";
          case 'failed_update_profile':
            return "Failed to update profile: ";
          case 'failed_pick_image':
            return "Failed to pick image: ";
          case 're_auth_failed':
            return "Re-authentication failed: ";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers here to avoid memory leaks
    nameController = TextEditingController();
    phoneController = TextEditingController();
    gradeController = TextEditingController();
    passwordController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    nameController.dispose();
    phoneController.dispose();
    gradeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        nameController.text = data["name"] ?? "";
        phoneController.text = data["phone"] ?? "";
        gradeController.text = data["grade"] ?? "";
        passwordController.text = "";

        setState(() => _loading = false);
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('failed_update_profile')}$e"),
          ),
        );
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${_getLocalizedString('failed_pick_image')}$e"),
          ),
        );
      }
    }
  }

  Future<bool> reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Show loading indicator
      if (mounted) {
        setState(() => _loading = true);
      }

      // Update Firestore fields first
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
            "name": nameController.text.trim(),
            "phone": phoneController.text.trim(),
            "grade": gradeController.text.trim(),
          });

      // Update password if provided (with re-authentication)
      if (passwordController.text.trim().isNotEmpty) {
        bool authenticated = await reauthenticateUser();
        if (authenticated) {
          await user.updatePassword(passwordController.text.trim());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getLocalizedString('profile_updated_success')),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getLocalizedString('profile_updated_success')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Navigate back only if widget is still mounted
      if (mounted) {
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
                          child: _imageFile != null
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
