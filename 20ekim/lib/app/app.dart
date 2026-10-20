// Girişim360 — Ana Uygulama Widget'ı (PROJECT.md Bölüm 4)
// Tema yönetimi, rotalar ve uygulama başlangıç koordinasyonu

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../features/startup/presentation/controllers/startup_controller.dart';
import 'navigation/main_nav_scaffold.dart';

class Girisim360App extends StatelessWidget {
  final ThemeController themeController;
  final StartupController startupController;

  const Girisim360App({
    super.key,
    required this.themeController,
    required this.startupController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: MainNavScaffold(
            themeController: themeController,
            startupController: startupController,
          ),
        );
      },
    );
  }
}
