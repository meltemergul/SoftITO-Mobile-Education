import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  void toggle() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  void dispose() {
    themeMode.dispose();
  }
}

/// ThemeController'ı ağaç boyunca setState olmadan erişilebilir kılar.
class ThemeScope extends InheritedWidget {
  final ThemeController controller;

  const ThemeScope({super.key, required this.controller, required super.child});

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope ağaçta bulunamadı.');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) =>
      controller != oldWidget.controller;
}

/// AppBar'larda kullanılan tema geçiş butonu.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller.themeMode,
      builder: (context, mode, _) {
        return IconButton(
          tooltip: AppStrings.toggleTheme,
          icon: Icon(
            mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: controller.toggle,
        );
      },
    );
  }
}
