import 'package:flutter/material.dart';

import 'components/header/home_header.dart';
import 'models/user.dart';
import 'components/PAGE/HomePage.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';
import 'theme/sky_gradient_background.dart';

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
            title: 'Asterisk',
            themeMode: _themeController.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            builder: (context, child) => SkyGradientBackground(
              child: child ?? const SizedBox.shrink(),
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
              appName: 'Asterisk',
              unreadNotifications: 4,
            ),
            const Expanded(
              child: Center(
                child: Text('Stories and feed will appear here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
