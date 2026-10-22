import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_pill_button.dart';
import '../../../../app/router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 48,
            color: colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Profil',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s24),
          AppPillButton(
            label: 'Çıkış Yap',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ref.read(authStateProvider.notifier).setAuthenticated(false);
            },
          ),
        ],
      ),
    );
  }
}
