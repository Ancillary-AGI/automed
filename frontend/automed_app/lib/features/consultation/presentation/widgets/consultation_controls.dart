import 'package:flutter/material.dart';

// Consultation controls widget
class ConsultationControls extends StatelessWidget {
  final bool isAudioMuted;
  final bool isVideoMuted;
  final VoidCallback onAudioToggle;
  final VoidCallback onVideoToggle;
  final VoidCallback onEndCall;
  final VoidCallback onChatToggle;
  final VoidCallback onInfoToggle;

  const ConsultationControls({
    super.key,
    required this.isAudioMuted,
    required this.isVideoMuted,
    required this.onAudioToggle,
    required this.onVideoToggle,
    required this.onEndCall,
    required this.onChatToggle,
    required this.onInfoToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Audio Toggle
          IconButton(
            icon: Icon(
              isAudioMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
            onPressed: onAudioToggle,
          ),

          // Video Toggle
          IconButton(
            icon: Icon(
              isVideoMuted ? Icons.videocam_off : Icons.videocam,
              color: Colors.white,
            ),
            onPressed: onVideoToggle,
          ),

          // Chat Toggle
          IconButton(
            icon: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
            onPressed: onChatToggle,
          ),

          // Info Toggle
          IconButton(
            icon: const Icon(
              Icons.info,
              color: Colors.white,
            ),
            onPressed: onInfoToggle,
          ),

          // End Call
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
              ),
              onPressed: onEndCall,
            ),
          ),
        ],
      ),
    );
  }
}
