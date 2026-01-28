// register_screen.dart (Beautiful UI with Localization)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:edu_connect/data/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:edu_connect/providers/language_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showWelcomeAnimation = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _errorMessage = '';
  List<String> _roles = ["student", "teacher"];
  String _selectedRole = "student";

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'create_account':
            return "Hisob yaratish ✨";
          case 'full_name':
            return "To'liq ism";
          case 'enter_name':
            return "Ismingizni kiriting";
          case 'email_address':
            return "Elektron pochta manzili";
          case 'enter_email':
            return "Elektron pochtangizni kiriting";
          case 'password':
            return "Parol";
          case 'create_strong_password':
            return "Kuchli parol yarating";
          case 'role':
            return "Rol";
          case 'create_account_button':
            return "Hisob yaratish";
          case 'or':
            return "YOKI";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'already_have_account':
            return "Hisobingiz bormi?";
          case 'log_in':
            return "Kirish";
          case 'please_enter_name':
            return "Iltimos, ismingizni kiriting";
          case 'please_enter_email':
            return "Iltimos, elektron pochtangizni kiriting";
          case 'please_enter_password':
            return "Iltimos, parolingizni kiriting";
          case 'password_min_length':
            return "Parol kamida 6 ta belgidan iborat bo'lishi kerak";
          case 'email_already_registered':
            return "Ushbu elektron pochta allaqachon ro'yxatdan o'tgan. Iltimos, kirish qiling yoki boshqa elektron pochta foydalaning.";
          case 'invalid_email_format':
            return "Elektron pochta formati noto'g'ri. Iltimos, elektron pochtangizni tekshiring.";
          case 'weak_password':
            return "Parol juda zaif. Kamida 6 ta belgidan foydalaning.";
          case 'too_many_attempts':
            return "Judah ko'p urinishlar. Iltimos, keyinroq qaytadan urinib ko'ring.";
          case 'network_error':
            return "Tarmoq xatosi. Iltimos, internet ulanishingizni tekshiring.";
          case 'registration_failed':
            return "Ro'yxatdan o'tish amalga oshmadi: ";
          case 'google_registration_coming':
            return "Google orqali ro'yxatdan o'tish tez kunda!";
          case 'apple_registration_coming':
            return "Apple orqali ro'yxatdan o'tish tez kunda!";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'create_account':
            return "Создать аккаунт ✨";
          case 'full_name':
            return "Полное имя";
          case 'enter_name':
            return "Введите ваше имя";
          case 'email_address':
            return "Адрес электронной почты";
          case 'enter_email':
            return "Введите вашу электронную почту";
          case 'password':
            return "Пароль";
          case 'create_strong_password':
            return "Создайте надежный пароль";
          case 'role':
            return "Роль";
          case 'create_account_button':
            return "Создать аккаунт";
          case 'or':
            return "ИЛИ";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'already_have_account':
            return "Уже есть аккаунт?";
          case 'log_in':
            return "Войти";
          case 'please_enter_name':
            return "Пожалуйста, введите ваше имя";
          case 'please_enter_email':
            return "Пожалуйста, введите вашу электронную почту";
          case 'please_enter_password':
            return "Пожалуйста, введите ваш пароль";
          case 'password_min_length':
            return "Пароль должен содержать не менее 6 символов";
          case 'email_already_registered':
            return "Email уже зарегистрирован. Пожалуйста, войдите или используйте другой email.";
          case 'invalid_email_format':
            return "Неверный формат email. Пожалуйста, проверьте ваш email.";
          case 'weak_password':
            return "Пароль слишком слаб. Используйте не менее 6 символов.";
          case 'too_many_attempts':
            return "Слишком много неудачных попыток. Пожалуйста, попробуйте позже.";
          case 'network_error':
            return "Ошибка сети. Пожалуйста, проверьте подключение к интернету.";
          case 'registration_failed':
            return "Регистрация не удалась: ";
          case 'google_registration_coming':
            return "Регистрация через Google скоро!";
          case 'apple_registration_coming':
            return "Регистрация через Apple скоро!";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'create_account':
            return "Create Account ✨";
          case 'full_name':
            return "Full Name";
          case 'enter_name':
            return "Enter your name";
          case 'email_address':
            return "Email Address";
          case 'enter_email':
            return "Enter your email";
          case 'password':
            return "Password";
          case 'create_strong_password':
            return "Create a strong password";
          case 'role':
            return "Role";
          case 'create_account_button':
            return "Create Account";
          case 'or':
            return "OR";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'already_have_account':
            return "Already have an account?";
          case 'log_in':
            return "Log In";
          case 'please_enter_name':
            return "Please enter your name";
          case 'please_enter_email':
            return "Please enter your email";
          case 'please_enter_password':
            return "Please enter a password";
          case 'password_min_length':
            return "Password must be at least 6 characters long";
          case 'email_already_registered':
            return "Email is already registered. Please login or use a different email.";
          case 'invalid_email_format':
            return "Invalid email format. Please check your email.";
          case 'weak_password':
            return "Password is too weak. Use at least 6 characters.";
          case 'too_many_attempts':
            return "Too many failed attempts. Please try again later.";
          case 'network_error':
            return "Network error. Please check your internet connection.";
          case 'registration_failed':
            return "Registration failed: ";
          case 'google_registration_coming':
            return "Google registration coming soon!";
          case 'apple_registration_coming':
            return "Apple registration coming soon!";
          default:
            return key;
        }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      _showError(_getLocalizedString('please_enter_name'));
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError(_getLocalizedString('please_enter_email'));
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showError(_getLocalizedString('please_enter_password'));
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showError(_getLocalizedString('password_min_length'));
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await _auth.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        role: _selectedRole,
      );

      // Navigate based on selected role
      if (_selectedRole == "teacher") {
        Navigator.pushReplacementNamed(context, "/teacher_home");
      } else {
        Navigator.pushReplacementNamed(context, "/student_home");
      }
    } catch (e) {
      _handleRegisterError(e.toString());
    }
  }

  void _handleRegisterError(String error) {
    setState(() => _isLoading = false);

    String errorMessage = _mapAuthError(error);
    _showError(errorMessage);

    // Shake animation on error
    _controller.reverse().then((_) => _controller.forward());
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = '');
    });
  }

  String _mapAuthError(String error) {
    if (error.contains('email-already-in-use')) {
      return _getLocalizedString('email_already_registered');
    } else if (error.contains('invalid-email')) {
      return _getLocalizedString('invalid_email_format');
    } else if (error.contains('weak-password')) {
      return _getLocalizedString('weak_password');
    } else if (error.contains('too-many-requests')) {
      return _getLocalizedString('too_many_attempts');
    } else if (error.contains('network')) {
      return _getLocalizedString('network_error');
    } else {
      return "${_getLocalizedString('registration_failed')}$error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Stack(
            children: [
              // Background Gradient
              _buildBackgroundGradient(),
        
              // Animated Particles
              _buildAnimatedParticles(),
        
              // Main Content
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500, minWidth: 300),
                  child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo and App Name
                          _buildAppHeader(size),
        
                          const SizedBox(height: 24),
        
                          // Welcome Message
                          if (_showWelcomeAnimation) _buildWelcomeAnimation(),
        
                          // Register Form
                          _buildRegisterForm(size),
        
                          // Error Message
                          if (_errorMessage.isNotEmpty) _buildErrorMessage(),
        
                          const SizedBox(height: 24),
        
                          // Register Button
                          _buildRegisterButton(size),
        
                          const SizedBox(height: 20),
        
                          // OR Divider
                          _buildDivider(),
        
                          const SizedBox(height: 20),
        
                          // Social Register Options
                          _buildSocialRegisters(size),
        
                          const SizedBox(height: 24),
        
                          // Login Link
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        
              // Loading Overlay
              if (_isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6C8CFF), Color(0xFF4A6CF7), Color(0xFF3A56C3)],
        ),
      ),
    );
  }

  Widget _buildAnimatedParticles() {
    return Positioned.fill(
      child: CustomPaint(painter: _ParticlePainter(animation: _animation)),
    );
  }

  Widget _buildAppHeader(Size size) {
    return Column(
      children: [
        Container(
          width: size.width * 0.3,
          height: size.width * 0.3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0F4FF)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.school, size: 48, color: Color(0xFF4A6CF7)),
        ),
        const SizedBox(height: 16),
        Text(
          "EduConnect",
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeAnimation() {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: Text(
        _getLocalizedString('create_account'),
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegisterForm(Size size) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _getLocalizedString('full_name'),
                hintText: _getLocalizedString('enter_name'),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF4A6CF7)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A6CF7),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _getLocalizedString('email_address'),
                hintText: _getLocalizedString('enter_email'),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF4A6CF7)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A6CF7),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: _getLocalizedString('password'),
                hintText: _getLocalizedString('create_strong_password'),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A6CF7)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF4A6CF7),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A6CF7),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: _getLocalizedString('role'),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4A6CF7),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A6CF7),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              dropdownColor: Colors.white,
              iconEnabledColor: const Color(0xFF4A6CF7),
              onChanged: (newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(Size size) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
            ),
          ),
      child: SizedBox(
        width: size.width * 0.8,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6CF7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
          ),
          onPressed: _isLoading ? null : _register,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _getLocalizedString('create_account_button'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
            ),
          ),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _getLocalizedString('or'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }

  Widget _buildSocialRegisters(Size size) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(
            size,
            Icons.g_mobiledata,
            Colors.red,
            _getLocalizedString('google'),
            () => _registerWithGoogle(),
          ),
          _buildSocialButton(
            size,
            Icons.apple,
            Colors.black,
            _getLocalizedString('apple'),
            () => _registerWithApple(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    Size size,
    IconData icon,
    Color color,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: size.width * 0.3,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getLocalizedString('already_have_account'),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, "/login");
            },
            child: Text(
              _getLocalizedString('log_in'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A6CF7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A6CF7),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('google_registration_coming')),
          backgroundColor: const Color(0xFF4A6CF7),
        ),
      );
    } catch (e) {
      _handleRegisterError(e.toString());
    }
  }

  Future<void> _registerWithApple() async {
    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('apple_registration_coming')),
          backgroundColor: const Color(0xFF4A6CF7),
        ),
      );
    } catch (e) {
      _handleRegisterError(e.toString());
    }
  }
}

// Custom Particle Animation (Same as login screen)
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Particle> particles = [];

  _ParticlePainter({required this.animation}) {
    for (int i = 0; i < 15; i++) {
      particles.add(_Particle());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      final radius = particle.radius * animation.value;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;

  _Particle()
    : x = Random().nextDouble(),
      y = Random().nextDouble(),
      radius = 1 + Random().nextDouble() * 3,
      speed = 0.001 + Random().nextDouble() * 0.005;
}
