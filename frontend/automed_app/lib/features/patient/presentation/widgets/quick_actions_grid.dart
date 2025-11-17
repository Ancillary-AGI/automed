import 'package:flutter/material.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.headline6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.calendar_today,
                  label: 'Book Appointment',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.medical_services,
                  label: 'View Records',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.local_hospital,
                  label: 'Find Hospital',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.chat,
                  label: 'AI Assistant',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.appPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.appPrimary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
