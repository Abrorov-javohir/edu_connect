// teacher_edit_screen.dart (Beautiful UI with Localization)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'dart:io';

class TeacherEditScreen extends StatefulWidget {
  const TeacherEditScreen({super.key});

  @override
  State<TeacherEditScreen> createState() => _TeacherEditScreenState();
}

class _TeacherEditScreenState extends State<TeacherEditScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = true;
  bool _isImagePickerActive = false;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'edit_profile':
            return "Profilni Tahrirlash";
          case 'full_name':
            return "To'liq Ism";
          case 'phone':
            return "Telefon";
          case 'new_password':
            return "Yangi Parol";
          case 'save_changes':
            return "O'zgarishlarni Saqlash";
          case 'loading_profile':
            return "Profil yuklanmoqda...";
          case 'profile_updated_success':
            return "Profil muvaffaqiyatli yangilandi!";
          case 're_auth_title':
            return "Qayta autentifikatsiya";
          case 're_auth_message':
            return "Profilni yangilash uchun joriy parolingizni kiriting: ";
          case 'current_password':
            return "Joriy Parol";
          case 'cancel':
            return "Bekor Qilish";
          case 'confirm':
            return "Tasdiqlash";
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
          case 'phone':
            return "Телефон";
          case 'new_password':
            return "Новый Пароль";
          case 'save_changes':
            return "Сохранить Изменения";
          case 'loading_profile':
            return "Загрузка профиля...";
          case 'profile_updated_success':
            return "Профиль успешно обновлен!";
          case 're_auth_title':
            return "Повторная аутентификация";
          case 're_auth_message':
            return "Введите текущий пароль для обновления профиля: ";
          case 'current_password':
            return "Текущий Пароль";
          case 'cancel':
            return "Отмена";
          case 'confirm':
            return "Подтвердить";
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
          case 'phone':
            return "Phone";
          case 'new_password':
            return "New Password";
          case 'save_changes':
            return "Save Changes";
          case 'loading_profile':
            return "Loading profile...";
          case 'profile_updated_success':
            return "Profile updated successfully!";
          case 're_auth_title':
            return "Re-authenticate";
          case 're_auth_message':
            return "Enter your current password to update profile: ";
          case 'current_password':
            return "Current Password";
          case 'cancel':
            return "Cancel";
          case 'confirm':
            return "Confirm";
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
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data["name"] ?? "";
      phoneController.text = data["phone"] ?? "";
      passwordController.text = "";
    }

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;

    setState(() => _isImagePickerActive = true);

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image selection failed: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isImagePickerActive = false);
      }
    }
  }

  Future<bool> _reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      String email = user.email ?? "";
      String password = "";

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              _getLocalizedString('re_auth_title'),
              style: GoogleFonts.poppins(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_getLocalizedString('re_auth_message')}$email",
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _getLocalizedString('current_password'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => password = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _getLocalizedString('cancel'),
                  style: GoogleFonts.poppins(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, password);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _getLocalizedString('confirm'),
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          );
        },
      );

      if (password.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Loading profile..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedString('edit_profile'),
          style: GoogleFonts.poppins(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const NetworkImage(
                                "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('full_name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('phone'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _getLocalizedString('new_password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    // Update Firestore fields first
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .update({
                          "name": nameController.text.trim(),
                          "phone": phoneController.text.trim(),
                        });

                    // Update password if provided (with re-authentication)
                    if (passwordController.text.trim().isNotEmpty) {
                      bool authenticated = await _reauthenticateUser();
                      if (authenticated) {
                        await user.updatePassword(
                          passwordController.text.trim(),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _getLocalizedString('profile_updated_success'),
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _getLocalizedString('profile_updated_success'),
                            ),
                          ),
                        );
                      }
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getLocalizedString('save_changes'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
}
