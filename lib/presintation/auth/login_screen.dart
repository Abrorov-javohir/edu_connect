// login_screen.dart (Beautiful UI with Auto-login) - FIXED
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:edu_connect/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:edu_connect/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _showWelcomeAnimation = true;
  final _auth = AuthService();
  late AnimationController _controller;
  late Animation<double> _animation;
  String _errorMessage = '';

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'welcome_back':
            return "Xush Kelibsiz 👋";
          case 'email_address':
            return "Elektron pochta manzili";
          case 'enter_email':
            return "Elektron pochtangizni kiriting";
          case 'password':
            return "Parol";
          case 'enter_password':
            return "Parolingizni kiriting";
          case 'remember_me':
            return "Eslab qolish";
          case 'forgot_password':
            return "Parolni unutdingizmi?";
          case 'log_in':
            return "Kirish";
          case 'or':
            return "YOKI";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'dont_have_account':
            return "Hisobingiz yo'qmi?";
          case 'sign_up':
            return "Ro'yxatdan o'tish";
          case 'no_account_found':
            return "Bu elektron pochta bilan hisob topilmadi. Iltimos, avval ro'yxatdan o'ting.";
          case 'incorrect_password':
            return "Noto'g'ri parol. Iltimos, qaytadan urinib ko'ring.";
          case 'invalid_email_format':
            return "Elektron pochta formati noto'g'ri. Iltimos, elektron pochtangizni tekshiring.";
          case 'invalid_credentials':
            return "Noto'g'ri elektron pochta yoki parol. Iltimos, ma'lumotlaringizni tekshiring.";
          case 'network_error':
            return "Tarmoq xatosi. Iltimos, internet ulanishingizni tekshiring.";
          case 'login_failed':
            return "Kirish amalga oshmadi. Iltimos, qaytadan urinib ko'ring.";
          case 'too_many_attempts':
            return "Judah ko'p urinishlar. Iltimos, keyinroq qaytadan urinib ko'ring.";
          case 'biometric_login_coming':
            return "Biometrik kirish tez kunda!";
          case 'google_signin_coming':
            return "Google orqali kirish tez kunda!";
          case 'apple_signin_coming':
            return "Apple orqali kirish tez kunda!";
          default:
            return key;
        }
      case 'ru':
        switch (key) {
          case 'welcome_back':
            return "С возвращением 👋";
          case 'email_address':
            return "Адрес электронной почты";
          case 'enter_email':
            return "Введите вашу электронную почту";
          case 'password':
            return "Пароль";
          case 'enter_password':
            return "Введите ваш пароль";
          case 'remember_me':
            return "Запомнить меня";
          case 'forgot_password':
            return "Забыли пароль?";
          case 'log_in':
            return "Войти";
          case 'or':
            return "ИЛИ";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'dont_have_account':
            return "Нет аккаунта?";
          case 'sign_up':
            return "Зарегистрироваться";
          case 'no_account_found':
            return "Аккаунт с этим email не найден. Пожалуйста, зарегистрируйтесь сначала.";
          case 'incorrect_password':
            return "Неверный пароль. Пожалуйста, попробуйте снова.";
          case 'invalid_email_format':
            return "Неверный формат email. Пожалуйста, проверьте ваш email.";
          case 'invalid_credentials':
            return "Неверный email или пароль. Пожалуйста, проверьте ваши данные.";
          case 'network_error':
            return "Ошибка сети. Пожалуйста, проверьте подключение к интернету.";
          case 'login_failed':
            return "Вход не удался. Пожалуйста, попробуйте снова.";
          case 'too_many_attempts':
            return "Слишком много неудачных попыток. Пожалуйста, попробуйте позже.";
          case 'biometric_login_coming':
            return "Биометрический вход скоро!";
          case 'google_signin_coming':
            return "Вход через Google скоро!";
          case 'apple_signin_coming':
            return "Вход через Apple скоро!";
          default:
            return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'welcome_back':
            return "Welcome Back 👋";
          case 'email_address':
            return "Email Address";
          case 'enter_email':
            return "Enter your email";
          case 'password':
            return "Password";
          case 'enter_password':
            return "Enter your password";
          case 'remember_me':
            return "Remember me";
          case 'forgot_password':
            return "Forgot Password?";
          case 'log_in':
            return "Log In";
          case 'or':
            return "OR";
          case 'google':
            return "Google";
          case 'apple':
            return "Apple";
          case 'dont_have_account':
            return "Don't have an account?";
          case 'sign_up':
            return "Sign Up";
          case 'no_account_found':
            return "No account found with this email. Please register first.";
          case 'incorrect_password':
            return "Incorrect password. Please try again.";
          case 'invalid_email_format':
            return "Invalid email format. Please check your email.";
          case 'invalid_credentials':
            return "Invalid email or password. Please check your credentials.";
          case 'network_error':
            return "Network error. Please check your internet connection.";
          case 'login_failed':
            return "Login failed. Please try again.";
          case 'too_many_attempts':
            return "Too many failed attempts. Please try again later.";
          case 'biometric_login_coming':
            return "Biometric login coming soon!";
          case 'google_signin_coming':
            return "Google sign-in coming soon!";
          case 'apple_signin_coming':
            return "Apple sign-in coming soon!";
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

    // Start auto-login process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');

    if (savedEmail != null) {
      setState(() => _isLoading = true);

      try {
        // Simulate loading for better UX
        await Future.delayed(const Duration(milliseconds: 800));

        // ✅ FIXED: Check if user is already authenticated using currentUser
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          _handleSuccessfulLogin();
          return;
        }

        // Try to auto-login with saved email
        await _auth.loginWithEmail(
          email: savedEmail,
          password: '', // Will use token-based auth
        );

        _handleSuccessfulLogin();
      } catch (e) {
        setState(() => _isLoading = false);
        // Clear invalid credentials
        await prefs.remove('email');
      }
    }
  }

  void _handleSuccessfulLogin() async {
    final userData = await _auth.getUserData();

    if (userData != null && userData.exists) {
      final role = userData.get("role") ?? "student";

      if (role == "teacher") {
        Navigator.pushReplacementNamed(context, "/teacher_home");
      } else {
        Navigator.pushReplacementNamed(context, "/student_home");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/student_home");
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty) {
      _showError(_getLocalizedString('no_account_found'));
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showError(_getLocalizedString('enter_password'));
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await _auth.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save email if remember me is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text.trim());
      }

      _handleSuccessfulLogin();
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }

  void _handleLoginError(String error) {
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
    if (error.contains('user-not-found')) {
      return _getLocalizedString('no_account_found');
    } else if (error.contains('wrong-password')) {
      return _getLocalizedString('incorrect_password');
    } else if (error.contains('invalid-email')) {
      return _getLocalizedString('invalid_email_format');
    } else if (error.contains('too-many-requests')) {
      return _getLocalizedString('too_many_attempts');
    } else if (error.contains('invalid-credential')) {
      return _getLocalizedString('invalid_credentials');
    } else if (error.contains('network')) {
      return _getLocalizedString('network_error');
    } else {
      return _getLocalizedString('login_failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  isDarkMode
                      ? 'assets/images/image.jpg'
                      : 'assets/images/image2.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Semi-transparent overlay to improve text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarColor: isDarkMode
                    ? const Color(0xFF121212)
                    : Colors.white,
                systemNavigationBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
              ),
              child: Stack(
                children: [
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
                              _buildAppHeader(size, isDarkMode),

                              const SizedBox(height: 32),

                              // Welcome Message
                              if (_showWelcomeAnimation)
                                _buildWelcomeAnimation(isDarkMode),

                              // Login Form
                              _buildLoginForm(size, isDarkMode),

                              // Error Message
                              if (_errorMessage.isNotEmpty)
                                _buildErrorMessage(isDarkMode),

                              // Forgot Password
                              _buildForgotPassword(isDarkMode),

                              const SizedBox(height: 24),

                              // Login Button
                              _buildLoginButton(size, isDarkMode),

                              const SizedBox(height: 20),

                              // OR Divider
                              _buildDivider(isDarkMode),

                              const SizedBox(height: 20),

                              // Social Login Options
                              _buildSocialLogins(size, isDarkMode),

                              const SizedBox(height: 24),

                              // Register Link
                              _buildRegisterLink(isDarkMode),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Loading Overlay
                  if (_isLoading) _buildLoadingOverlay(isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(Size size, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: size.width * 0.3,
          height: size.width * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF2D2D2D), const Color(0xFF1E1E1E)]
                  : [Colors.white, const Color(0xFFF0F4FF)],
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
            color: isDarkMode ? Colors.white : Colors.white,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeAnimation(bool isDarkMode) {
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: Text(
        _getLocalizedString('welcome_back'),
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoginForm(Size size, bool isDarkMode) {
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
          color: isDarkMode
              ? const Color(0xFF1E1E1E).withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _getLocalizedString('email_address'),
                hintText: _getLocalizedString('enter_email'),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF4A6CF7)),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: _getLocalizedString('password'),
                hintText: _getLocalizedString('enter_password'),
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
                fillColor: isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onChanged: (_) => setState(() => _errorMessage = ''),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: const Color(0xFF4A6CF7),
                  checkColor: Colors.white,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                ),
                Text(
                  _getLocalizedString('remember_me'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _getLocalizedString('biometric_login_coming'),
                        ),
                        backgroundColor: const Color(0xFF4A6CF7),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fingerprint, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(bool isDarkMode) {
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
          color: isDarkMode
              ? Colors.red.withOpacity(0.2)
              : Colors.red.withOpacity(0.1),
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
                  color: isDarkMode ? Colors.red[300] : Colors.red[700],
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

  Widget _buildForgotPassword(bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/reset_password');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: const Color(0xFF4A6CF7),
        ),
        child: Text(
          _getLocalizedString('forgot_password'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size size, bool isDarkMode) {
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
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _getLocalizedString('log_in'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
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
          Expanded(
            child: Container(
              height: 1,
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _getLocalizedString('or'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogins(Size size, bool isDarkMode) {
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
            () => _signInWithGoogle(),
            isDarkMode,
          ),
          _buildSocialButton(
            size,
            Icons.apple,
            Colors.black,
            _getLocalizedString('apple'),
            () => _signInWithApple(),
            isDarkMode,
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
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: size.width * 0.3,
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2D2D2D).withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
            width: 1,
          ),
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

  Widget _buildRegisterLink(bool isDarkMode) {
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
            _getLocalizedString('dont_have_account'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, "/register");
            },
            child: Text(
              _getLocalizedString('sign_up'),
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

  Widget _buildLoadingOverlay(bool isDarkMode) {
    return Container(
      color: isDarkMode
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.05),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A6CF7),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('google_signin_coming')),
          backgroundColor: const Color(0xFF4A6CF7),
        ),
      );
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    _errorMessage = '';

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString('apple_signin_coming')),
          backgroundColor: const Color(0xFF4A6CF7),
        ),
      );
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }
}

// Custom Particle Animation
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  final List<_Particle> particles = [];

  _ParticlePainter({required this.animation, required this.isDarkMode}) {
    for (int i = 0; i < 15; i++) {
      particles.add(_Particle());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(0.1)
          : Colors.white.withOpacity(0.2)
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
