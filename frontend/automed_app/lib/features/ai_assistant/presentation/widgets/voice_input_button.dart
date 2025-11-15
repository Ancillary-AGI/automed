import 'package:flutter/material.dart';

// Voice input button with listening state
class VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const VoiceInputButton({
    super.key,
    this.isListening = false,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        icon: Icon(
          isListening ? Icons.mic_off : Icons.mic,
          color: isEnabled
              ? (isListening ? Colors.red : Colors.blue)
              : Colors.grey,
        ),
        onPressed: isEnabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: isListening
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.1),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
