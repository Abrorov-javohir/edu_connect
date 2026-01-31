// screens/onboarding_screen.dart (Beautiful UI with Localization and First Launch Check)
import 'package:edu_connect/presintation/auth/login_screen.dart';
import 'package:edu_connect/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  String _getLocalizedString(String key) {
    final language = context.read<LanguageProvider>().currentLanguage;
    switch (language) {
      case 'uz':
        switch (key) {
          case 'learn_anywhere': return "Har qanday joyda O'rganish";
          case 'learn_description': return "EduConnect bilan bilimlarni oching — shaxsiy o'qish hamrohingiz.";
          case 'connect_collaborate': return "Bog'laning & Hamkorlik Qiling";
          case 'connect_description': return "O'qituvchilar va o'quvchilar, bitta integratsiyalangan platformada birlashtirilgan.";
          case 'simplify_learning': return "O'qishni Soddalashtiring";
          case 'simplify_description': return "Vazifalar, testlar va e'lonlar — barchasi bitta joyda.";
          case 'skip': return "O'tkazish";
          case 'get_started': return "Boshlash";
          case 'next': return "Keyingi";
          default: return key;
        }
      case 'ru':
        switch (key) {
          case 'learn_anywhere': return "Учитесь Везде";
          case 'learn_description': return "Откройте знания с EduConnect — вашим личным помощником в обучении.";
          case 'connect_collaborate': return "Соединяйтесь и Совместная Работа";
          case 'connect_description': return "Учителя и студенты, объединенные в одной интегрированной платформе.";
          case 'simplify_learning': return "Упростить Обучение";
          case 'simplify_description': return "Задания, тесты и объявления — все в одном месте.";
          case 'skip': return "Пропустить";
          case 'get_started': return "Начать";
          case 'next': return "Далее";
          default: return key;
        }
      case 'en':
      default:
        switch (key) {
          case 'learn_anywhere': return "Learn Anywhere";
          case 'learn_description': return "Unlock knowledge with EduConnect — your personal learning companion.";
          case 'connect_collaborate': return "Connect & Collaborate";
          case 'connect_description': return "Teachers and students, united in one integrated platform.";
          case 'simplify_learning': return "Simplify Learning";
          case 'simplify_description': return "Assignments, quizzes, and announcements — all in one place.";
          case 'skip': return "Skip";
          case 'get_started': return "Get Started";
          case 'next': return "Next";
          default: return key;
        }
    }
  }

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/image.png",
      "title": "learn_anywhere",
      "text": "learn_description",
    },
    {
      "image": "assets/images/image2.jpg",
      "title": "connect_collaborate",
      "text": "connect_description",
    },
    {
      "image": "assets/images/image3.png",
      "title": "simplify_learning",
      "text": "simplify_description",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('has_launched_before') ?? false;

    if (hasLaunchedBefore) {
      // User has seen onboarding before, skip to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched_before', true);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Background Image with Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SizedBox.expand(
              key: ValueKey(_currentPage),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _pages[_currentPage]["image"]!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (_, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _getLocalizedString(page["title"]!),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _getLocalizedString(page["text"]!),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 60,
            right: 20,
            child: FadeIn(
              duration: const Duration(milliseconds: 800),
              child: TextButton(
                onPressed: () async {
                  await _markAsSeen();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _getLocalizedString('skip'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Next / Get Started Button
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isDarkMode ? Colors.blue[800]! : Colors.blue[700]!,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      onPressed: () async {
                        if (_currentPage == _pages.length - 1) {
                          await _markAsSeen();
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? _getLocalizedString('get_started')
                            : _getLocalizedString('next'),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}