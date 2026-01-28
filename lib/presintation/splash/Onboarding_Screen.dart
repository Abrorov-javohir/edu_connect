import 'package:edu_connect/presintation/auth/login_screen.dart';
import 'package:edu_connect/presintation/auth/register_screen.dart';
import 'package:edu_connect/presintation/auth/smslogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edu_connect/presintation/auth/smsregister_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/image.png",
      "title": "Learn Anytime, Anywhere",
      "text":
          "Unlock knowledge with EduConnect — your personal learning companion.",
    },
    {
      "image": "assets/images/image2.jpg",
      "title": "Connect & Collaborate",
      "text": "Teachers and students, united in one seamless platform.",
    },
    {
      "image": "assets/images/image3.png",
      "title": "Simplify Learning",
      "text": "Assignments, quizzes, and announcements — all in one place.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background image that changes with page
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
                    color: Colors.black.withOpacity(0.5), // dark overlay
                    colorBlendMode: BlendMode.darken,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
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

          // PageView Content (without top image)
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
                    // ❌ Removed top image
                    // Title
                    Text(
                      page["title"]!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      page["text"]!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
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
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text(
                "Skip",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom Controls (Indicators + Button)
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ).copyWith(
                          overlayColor: MaterialStateProperty.all(
                            Colors.white.withOpacity(0.1),
                          ),
                        ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? "Get Started"
                          : "Next",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
