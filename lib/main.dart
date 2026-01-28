// main.dart
import 'package:edu_connect/presintation/teachers_things/cubit/anouncement_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/course_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/home_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/cubit/student_cubit.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Authentication screens
import 'package:edu_connect/presintation/auth/login_screen.dart';
import 'package:edu_connect/presintation/auth/register_screen.dart';
import 'package:edu_connect/presintation/auth/reset_password.dart';
import 'package:edu_connect/presintation/splash/onboarding_screen.dart';

// Student screens
import 'package:edu_connect/presintation/student_screens/student_home.dart';
import 'package:edu_connect/presintation/student_screens/student_profile/student_profile.dart';
import 'package:edu_connect/presintation/student_screens/student_calendar_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_chat_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_task_screen.dart';
import 'package:edu_connect/presintation/student_screens/student_progress_screen.dart';

// Teacher screens
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_screen.dart';
import 'package:edu_connect/presintation/teachers_things/teacher_screens/teacher_notifications_screen.dart';

// Providers
import 'package:edu_connect/providers/theme_provider.dart';
import 'package:edu_connect/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initApp();
  runApp(const EduConnectApp());
}

Future<void> _initApp() async {
  await SharedPreferences.getInstance();
  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();
  await themeProvider.loadTheme();
  await languageProvider.loadLanguage();
}

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        BlocProvider(create: (context) => CoursesCubit()),
        BlocProvider(create: (context) => AnnouncementsCubit()),
        BlocProvider(create: (context) => StudentsCubit()),
        BlocProvider(create: (context) => HomeCubit()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'EduConnect',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFFF6F7FB),
              fontFamily: 'Poppins',
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              colorScheme: ColorScheme.dark(),
            ),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('uz', ''), // Uzbek
              Locale('ru', ''), // Russian
            ],
            locale: Locale(languageProvider.currentLanguage, ''),
            initialRoute: '/',
            routes: {
              '/': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/reset_password': (context) => const ResetPasswordScreen(),
              '/teacher_home': (context) => const TeacherScreen(),
              '/student_home': (context) => const StudentHomeScreen(),
              '/student_profile': (context) => const StudentProfileScreen(),
              '/student_calendar': (context) => const StudentCalendarScreen(),
              '/student_chat': (context) => const StudentChatScreen(),
              '/student_tasks': (context) => const StudentTasksScreen(),
              '/student_progress': (context) => const StudentProgressScreen(),
              '/teacher_notifications': (context) =>
                  const TeacherNotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}
