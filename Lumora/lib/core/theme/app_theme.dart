import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';
import 'typography.dart';

abstract class AppTheme {
  static ThemeData get light {
    final colors = AppColorsExtension.light();

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.primaryStrong,
        onPrimary: colors.textOnPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      extensions: [colors],
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  /// TODO: Koyu tema paleti henüz tasarım ekibi tarafından teslim edilmemiştir.
  /// Mimari koyu temayı destekler durumdadır; tasarım paleti netleştiğinde güncellenecektir.
  static ThemeData get dark {
    final colors = AppColorsExtension.dark();

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryStrong,
        onPrimary: colors.textOnPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      extensions: [colors],
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: Color(0xFF334155)),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
