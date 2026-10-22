import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// mobile_blank kabuğu: Auth, Giriş/Kayıt ve odaklanmış tam ekran akışları için.
/// Üst çubuk ve alt sekme barındırmaz.
class MobileBlankShell extends StatelessWidget {
  const MobileBlankShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: child,
      ),
    );
  }
}
