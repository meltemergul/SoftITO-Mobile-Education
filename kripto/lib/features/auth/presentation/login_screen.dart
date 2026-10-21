import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      final success = await ref.read(authControllerProvider.notifier).signUp(email, password);
      if (!mounted) return;

      if (success) {
        setState(() {
          _successMessage = 'Kayıt başarılı! Giriş yapılıyor veya e-posta onayını kontrol edin.';
        });
        if (ref.read(isAuthenticatedProvider)) {
          context.go('/dashboard');
        }
      } else {
        final error = ref.read(authControllerProvider).error;
        setState(() {
          _errorMessage = error?.toString() ?? 'Kayıt işlemi başarısız oldu.';
        });
      }
    } else {
      final success = await ref.read(authControllerProvider.notifier).signIn(email, password);
      if (!mounted) return;

      if (success) {
        context.go('/dashboard');
      } else {
        final error = ref.read(authControllerProvider).error;
        setState(() {
          _errorMessage = error?.toString() ?? 'Giriş yapılamadı.';
        });
      }
    }
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screenMarginMobile,
            right: AppSpacing.screenMarginMobile,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Şifre Sıfırlama',
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hesabınıza kayıtlı e-posta adresini girin. Sıfırlama bağlantısı gönderilecektir.',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'ornek@email.com',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () async {
                  final email = resetEmailController.text.trim();
                  if (email.isEmpty) return;

                  Navigator.pop(ctx);
                  final success =
                      await ref.read(authControllerProvider.notifier).resetPassword(email);
                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'),
                        backgroundColor: AppColors.profit,
                      ),
                    );
                  } else {
                    final err = ref.read(authControllerProvider).error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err?.toString() ?? 'Bağlantı gönderilemedi.'),
                        backgroundColor: AppColors.loss,
                      ),
                    );
                  }
                },
                child: Text('SIFIRLAMA BAĞLANTISI GÖNDER'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMarginMobile),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ve Marka
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chronomind',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLg,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Kripto Kâr / Zarar & Portföy Takibi',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Segment Seçici (Giriş Yap / Kayıt Ol)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: AppSpacing.roundedCard,
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isSignUp ? AppColors.surface2 : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: !_isSignUp ? AppColors.borderCyanFocus : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'GİRİŞ YAP',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: !_isSignUp ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isSignUp ? AppColors.surface2 : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isSignUp ? AppColors.borderCyanFocus : Colors.transparent,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'KAYIT OL',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: _isSignUp ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Hata Mesajı Kartı
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
                      decoration: BoxDecoration(
                        color: AppColors.lossBg,
                        borderRadius: AppSpacing.roundedCard,
                        border: Border.all(color: AppColors.lossBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.lossText, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySm.copyWith(color: AppColors.lossText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Başarı Mesajı Kartı
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
                      decoration: BoxDecoration(
                        color: AppColors.profitBg,
                        borderRadius: AppSpacing.roundedCard,
                        border: Border.all(color: AppColors.profitBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.profitText, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: AppTextStyles.bodySm.copyWith(color: AppColors.profitText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // E-posta Alanı
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      hintText: 'ornek@email.com',
                      prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Lütfen e-posta adresinizi girin.';
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Şifre Alanı
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Lütfen şifrenizi girin.';
                      }
                      if (_isSignUp && val.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),

                  // Şifre Tekrar Alanı (Sadece Kayıt Ol)
                  if (_isSignUp) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrar',
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'Şifreler birbiriyle eşleşmiyor.';
                        }
                        return null;
                      },
                    ),
                  ],

                  // Şifremi Unuttum Bağlantısı
                  if (!_isSignUp) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordSheet,
                        child: Text(
                          'Şifremi unuttum',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Ana CTA Butonu
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.canvas,
                            ),
                          )
                        : Text(_isSignUp ? 'HESAP OLUŞTUR' : 'GİRİŞ YAP'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Misafir Modu (Kayıt Olmadan Canlı Piyasa ve Simülasyon)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(isGuestModeProvider.notifier).enableGuest();
                      context.go('/dashboard');
                    },
                    icon: Icon(Icons.explore_outlined, size: 18, color: AppColors.primaryBright),
                    label: Text(
                      'Misafir Modu ile İncele',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderCard),
                      backgroundColor: AppColors.surface1,
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Demo Modu / Bilgi Şeridi (Supabase henüz canlı bağlanmadıysa)
                  if (!SupabaseService.isConfigured) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedCard,
                        border: Border.all(color: AppColors.borderCard),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Yerel Geliştirme Modu',
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supabase henüz .env ile bağlanmadı. Ekranları incelemek için doğrudan devam edebilirsiniz.',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: () => context.go('/dashboard'),
                            child: Text('DASHBOARD\'A GEÇ (DEMO)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
