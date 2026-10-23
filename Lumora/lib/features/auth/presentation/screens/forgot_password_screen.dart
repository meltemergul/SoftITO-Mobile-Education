import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1; // 1: E-posta gönder, 2: Kod ve yeni şifre gir

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(email: _emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  Future<void> _submitResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authNotifierProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreniz başarıyla güncellendi. Giriş yapabilirsiniz.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Geri Dön',
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          'Şifre Sıfırlama',
          style: AppTypography.heading.copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s16),
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: AppTypography.bodySmall.copyWith(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
                if (authState.infoMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: colors.accessibleGreenText),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            authState.infoMessage!,
                            style: AppTypography.bodySmall.copyWith(color: colors.accessibleGreenText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                ],
                if (_currentStep == 1) ...[
                  Text(
                    'Hesabınıza bağlı e-posta adresini girin. Size 6 haneli bir sıfırlama kodu göndereceğiz.',
                    style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppTextField(
                    controller: _emailController,
                    label: 'E-posta Adresi',
                    hintText: 'ornek@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: colors.textSecondary),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'E-posta boş bırakılamaz.';
                      }
                      if (!val.contains('@')) {
                        return 'Geçerli bir e-posta adresi giriniz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppPillButton(
                    label: 'Sıfırlama Kodu Gönder',
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    onPressed: authState.isLoading ? null : _submitForgotPassword,
                  ),
                ] else ...[
                  Text(
                    'E-posta adresinize gönderilen 6 haneli kodu ve yeni şifrenizi girin.',
                    style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppTextField(
                    controller: _codeController,
                    label: '6 Haneli Sıfırlama Kodu',
                    hintText: '123456',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.pin_outlined, color: colors.textSecondary),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Sıfırlama kodu boş bırakılamaz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  AppTextField(
                    controller: _newPasswordController,
                    label: 'Yeni Şifre',
                    hintText: 'En az 8 karakter',
                    isPassword: true,
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.textSecondary),
                    validator: (val) {
                      if (val == null || val.length < 8) {
                        return 'Şifre en az 8 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppPillButton(
                    label: 'Şifreyi Güncelle',
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    onPressed: authState.isLoading ? null : _submitResetPassword,
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Giriş Ekranına Dön',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.primaryStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
