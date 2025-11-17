import 'package:flutter/material.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/core/models/medication_models.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;

  const MedicationCard({super.key, required this.medication, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.appPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: AppColors.appPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name, style: AppTextStyles.subtitle1),
                    const SizedBox(height: 4),
                    Text('${medication.dosage} · ${medication.frequency}',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!medication.isExpired)
                Chip(
                    label: Text('Active',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.appSuccess)))
              else
                Chip(
                    label: Text('Expired',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.appError))),
            ],
          ),
        ),
      ),
    );
  }
}
