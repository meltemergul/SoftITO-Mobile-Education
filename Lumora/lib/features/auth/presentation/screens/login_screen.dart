import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _selectedTabIndex = 0; // 0: Giriş Yap, 1: Kayıt Ol

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(authNotifierProvider.notifier);

    if (_selectedTabIndex == 0) {
      // Giriş Yap
      await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
    } else {
      // Kayıt Ol
      await notifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        rememberMe: _rememberMe,
      );
    }
  }

  Future<void> _continueAsGuest() async {
    await ref.read(authNotifierProvider.notifier).guest();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authNotifierProvider);
    final isLogin = _selectedTabIndex == 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.s24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Üstte marka logosu ve başlık
              const AuthHeader(),
              const SizedBox(height: AppSpacing.s24),

              // Giriş Yap / Kayıt Ol sekme seçici
              AppSegmentedControl(
                options: const ['Giriş Yap', 'Kayıt Ol'],
                selectedIndex: _selectedTabIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  ref.read(authNotifierProvider.notifier).clearMessages();
                },
              ),
              const SizedBox(height: AppSpacing.s20),

              // Hata mesajı banner'ı
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
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

              // Kayıt modunda Görünen Ad alanı
              if (!isLogin) ...[
                AppTextField(
                  controller: _displayNameController,
                  label: 'Görünen Ad',
                  hintText: 'Adınız Soyadınız',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: colors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Görünen ad boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
              ],

              // E-posta alanı
              AppTextField(
                controller: _emailController,
                label: 'E-posta',
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
              const SizedBox(height: AppSpacing.s16),

              // Şifre alanı
              AppTextField(
                controller: _passwordController,
                label: 'Şifre',
                hintText: isLogin ? 'Şifreniz' : 'En az 8 karakter',
                isPassword: true,
                prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.textSecondary),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Şifre boş bırakılamaz.';
                  }
                  if (!isLogin && val.length < 8) {
                    return 'Şifre en az 8 karakter olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s8),

              // Beni Hatırla & Şifremi Unuttum satırı
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: colors.primaryStrong,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Beni hatırla',
                        style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
                      ),
                    ],
                  ),
                  if (isLogin)
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Şifremi unuttum?',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primaryStrong,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Birincil CTA (Giriş Yap / Kayıt Ol)
              AppPillButton(
                label: isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                isLoading: authState.isLoading,
                trailingIcon: Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.textOnPrimary,
                  size: 20,
                ),
                isFullWidth: true,
                onPressed: authState.isLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.s24),

              // VEYA Ayırıcı Çizgi
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                    child: Text(
                      'veya',
                      style: AppTypography.caption.copyWith(color: colors.textTertiary),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.border)),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Sosyal Giriş Butonları (Görsel Yer Tutucular)
              SocialButton(
                label: 'Google ile Devam Et',
                icon: Image.network(
                  'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              const SocialButton(
                label: 'Apple ile Giriş Yap',
                icon: Icon(Icons.apple_rounded, size: 22),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Misafir olarak devam et
              Center(
                child: TextButton(
                  onPressed: authState.isLoading ? null : _continueAsGuest,
                  child: Text(
                    'Misafir Olarak Devam Et',
                    style: AppTypography.body.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
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
