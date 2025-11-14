import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOnline;

  const OfflineIndicator({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange.shade800,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'You are currently offline',
            style: AppTextStyles.bodyText2.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
