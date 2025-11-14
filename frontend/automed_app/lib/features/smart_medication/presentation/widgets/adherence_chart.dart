import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdherenceChart extends StatelessWidget {
  final double adherence; // 0.0 - 1.0

  const AdherenceChart({super.key, required this.adherence});

  @override
  Widget build(BuildContext context) {
    final percent = (adherence * 100).clamp(0, 100).toInt();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adherence', style: AppTextStyles.subtitle1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: adherence.clamp(0.0, 1.0),
                    color: AppColors.success,
                    backgroundColor: AppColors.success.withOpacity(0.12),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Text('$percent%', style: AppTextStyles.subtitle2),
              ],
            ),
            const SizedBox(height: 8),
            Text('Based on recent intake logs', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
