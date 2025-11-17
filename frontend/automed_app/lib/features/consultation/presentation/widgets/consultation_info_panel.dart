import 'package:flutter/material.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';

class ConsultationInfoPanel extends StatelessWidget {
  final dynamic consultation;
  final VoidCallback onClose;

  const ConsultationInfoPanel({
    super.key,
    required this.consultation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.95),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Consultation Info',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: colorScheme.onSurface),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Info Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Type',
                    consultation.type ?? 'Unknown',
                    colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Doctor',
                    consultation.doctorName ?? 'Unknown',
                    colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Status',
                    consultation.status ?? 'Unknown',
                    colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Start Time',
                    consultation.startTime ?? 'Unknown',
                    colorScheme,
                  ),
                  if (consultation.notes != null &&
                      consultation.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      consultation.notes,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style:
                AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
