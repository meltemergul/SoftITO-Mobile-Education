import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/views/home_shell.dart';

void main() {
  runApp(const CanBagimApp());
}

/// Yalnızca uygulama başlatma ve tema sağlayıcı tanımı (project.md §2).
class CanBagimApp extends StatefulWidget {
  const CanBagimApp({super.key});

  @override
  State<CanBagimApp> createState() => _CanBagimAppState();
}

class _CanBagimAppState extends State<CanBagimApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController.themeMode,
        builder: (context, mode, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
