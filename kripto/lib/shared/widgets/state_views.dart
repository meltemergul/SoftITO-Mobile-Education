import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Obsidian Precision temasına uygun yükleniyor durumu bileşeni.
class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Veriler yükleniyor...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Obsidian Precision temasına uygun hata durumu ve yeniden deneme bileşeni.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    this.message = 'Veriler yüklenirken bir sorun oluştu.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.lossText,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bir Hata Oluştu',
                style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: 18),
                label: Text('YENİDEN DENE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Obsidian Precision temasına uygun boş durum (Empty State) bileşeni.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textMuted, size: 38),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.headlineSm.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(Icons.add, size: 18),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 42),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
