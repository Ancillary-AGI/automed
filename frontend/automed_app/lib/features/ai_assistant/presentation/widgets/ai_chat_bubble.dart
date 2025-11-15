import 'package:flutter/material.dart';

// AI Chat Bubble widget for displaying messages
class AIChatBubble extends StatelessWidget {
  final dynamic message;
  final Function(String)? onSpeakMessage;
  final Function(String)? onCopyMessage;
  final Function(dynamic)? onActionTap;

  const AIChatBubble({
    super.key,
    required this.message,
    this.onSpeakMessage,
    this.onCopyMessage,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = !message.isUser;

    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isIncoming ? Colors.grey.shade200 : Colors.blue.shade400,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isIncoming ? Radius.zero : const Radius.circular(12),
            bottomRight: isIncoming ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isIncoming ? Colors.black : Colors.white,
                ),
              ),
            ),
            if (message.metadata != null &&
                message.metadata!['actions'] != null)
              _buildActions(context, message.metadata!['actions']),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, List<dynamic> actions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onSpeakMessage != null)
            IconButton(
              icon: const Icon(Icons.volume_up, size: 16),
              onPressed: () => onSpeakMessage!(message.content),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (onCopyMessage != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => onCopyMessage!(message.content),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          // Action buttons would be added here based on message actions
        ],
      ),
    );
  }
}
