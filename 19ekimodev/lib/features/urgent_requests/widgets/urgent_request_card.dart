import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/urgent_request_model.dart';

class UrgentRequestCard extends StatelessWidget {
  final UrgentRequestModel request;
  final VoidCallback onRespond;

  const UrgentRequestCard({
    super.key,
    required this.request,
    required this.onRespond,
  });

  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.critical:
        return AppColors.critical;
      case UrgencyLevel.high:
        return AppColors.warning;
      case UrgencyLevel.normal:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor(request.urgency);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: urgencyColor.withAlpha(77), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: urgencyColor.withAlpha(31),
          child: Text(
            request.bloodGroup.label,
            style: TextStyle(color: urgencyColor, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          request.hospitalName,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${request.city} • Kalan: ${request.remainingUnits}/${request.unitsNeeded} ünite',
          style: textTheme.bodySmall,
        ),
        trailing: request.isFulfilled
            ? const Icon(Icons.check_circle, color: AppColors.eligible)
            : FilledButton.tonal(
                onPressed: onRespond,
                child: const Text('Bağışçı Ol'),
              ),
      ),
    );
  }
}
