import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'presentation/main_navigation_shell.dart';

/// Movira Ana Uygulama Kök Widget'ı
class MoviraApp extends StatelessWidget {
  const MoviraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: globalThemeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Movira Araç Kiralama',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const MainNavigationShell(),
        );
      },
    );
  }
}
