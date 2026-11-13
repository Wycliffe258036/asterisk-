import 'package:flutter/material.dart';

import 'components/header/home_header.dart';
import 'models/user.dart';
import 'components/PAGE/HomePage.dart';
import 'theme/app_theme_controller.dart';

void main() {
  runApp(const SocialApp());
}

class SocialApp extends StatefulWidget {
  const SocialApp({super.key});

  @override
  State<SocialApp> createState() => _SocialAppState();
}

class _SocialAppState extends State<SocialApp> {
  final AppThemeController _themeController = AppThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Social App',
            themeMode: _themeController.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.transparent,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.transparent,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HeaderTestPage extends StatelessWidget {
  const HeaderTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const user = User(
      id: 'user_001',
      username: 'wycliffe',
      displayName: 'Wycliffe',
      isVerified: true,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              currentUser: user,
              appName: 'Asterix',
              unreadNotifications: 4,
            ),

            const Expanded(
              child: Center(
                child: Text(
                  'Stories and feed will appear here',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  