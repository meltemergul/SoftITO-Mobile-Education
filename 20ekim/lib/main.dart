// Girişim360 — Başlangıç Noktası (main.dart)
// PROJECT.md Bölüm 4 & 5 kurallarına uygun başlangıç ve bağımlılık kurulumu

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/theme/theme_controller.dart';
import 'features/startup/data/datasources/startup_local_datasource.dart';
import 'features/startup/data/repositories/startup_repository_impl.dart';
import 'features/startup/presentation/controllers/startup_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Çekirdek Servisler ve Durum Kontrolcüleri
  final themeController = ThemeController();
  final startupDataSource = StartupLocalDataSource();
  final startupRepository = StartupRepositoryImpl(startupDataSource);
  final startupController = StartupController(startupRepository);

  runApp(Girisim360App(
    themeController: themeController,
    startupController: startupController,
  ));
}
