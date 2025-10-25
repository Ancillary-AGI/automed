import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.video_call,
        label: 'Video Call',
        color: Colors.blue,
        onTap: () => context.push('/consultation/video'),
      ),
      _QuickAction(
        icon: Icons.chat,
        label: 'Chat',
        color: Colors.green,
        onTap: () => context.push('/consultation/chat'),
      ),
      _QuickAction(
        icon: Icons.local_hospital,
        label: 'Find Hospital',
        color: Colors.red,
        onTap: () => context.push('/hospital/search'),
      ),
      _QuickAction(
        icon: Icons.medication,
        label: 'Medications',
        color: Colors.orange,
        onTap: () => context.push('/medication'),
      ),
      _QuickAction(
        icon: Icons.emergency,
        label: 'Emergency',
        color: Colors.purple,
        onTap: () => context.push('/emergency'),
      ),
      _QuickAction(
        icon: Icons.analytics,
        label: 'Health Analytics',
        color: Colors.teal,
        onTap: () => context.push('/analytics'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
