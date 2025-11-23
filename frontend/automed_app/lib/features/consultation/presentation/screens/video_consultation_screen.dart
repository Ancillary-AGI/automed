import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/core/widgets/app_scaffold.dart';
import 'package:automed_app/generated/l10n.dart';
import '../providers/consultation_provider.dart';
import '../providers/webrtc_provider.dart';
import '../widgets/consultation_controls.dart';
import '../widgets/consultation_chat.dart';
import '../widgets/consultation_info_panel.dart';

class VideoConsultationScreen extends ConsumerStatefulWidget {
  final String consultationId;

  const VideoConsultationScreen({
    super.key,
    required this.consultationId,
  });

  @override
  ConsumerState<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState
    extends ConsumerState<VideoConsultationScreen> {
  bool _isChatVisible = false;
  bool _isInfoPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    final localRenderer = RTCVideoRenderer();
    final remoteRenderer = RTCVideoRenderer();

    await localRenderer.initialize();
    await remoteRenderer.initialize();

    // Initialize WebRTC connection
    ref.read(webRtcProvider.notifier).initializeConnection(
          widget.consultationId,
          localRenderer,
          remoteRenderer,
        );
  }

  @override
  Widget build(BuildContext context) {
    final consultation = ref.watch(consultationProvider);
    final webRtcState = ref.watch(webRtcProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: Colors.black,
      body: consultation.when(
        data: (consultationData) => Stack(
          children: [
            // Video Views
            _buildVideoViews(webRtcState),

            // Top Bar
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: _buildTopBar(consultationData, theme),
            ),

            // Bottom Controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
              child: ConsultationControls(
                isAudioMuted: webRtcState.isAudioMuted,
                isVideoMuted: webRtcState.isVideoMuted,
                onAudioToggle: _toggleAudio,
                onVideoToggle: _toggleVideo,
                onEndCall: _endCall,
                onChatToggle: _toggleChat,
                onInfoToggle: _toggleInfoPanel,
              ),
            ),

            // Chat Panel
            if (_isChatVisible)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: ConsultationChat(
                  consultationId: widget.consultationId,
                  onClose: () => setState(() => _isChatVisible = false),
                ),
              ),

            // Info Panel
            if (_isInfoPanelVisible)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: ConsultationInfoPanel(
                  consultation: consultationData,
                  onClose: () => setState(() => _isInfoPanelVisible = false),
                ),
              ),

            // Connection Status
            if (!webRtcState
                .isConnected) // Assuming webRtcState is true when connected
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 20,
                right: 20,
                child: _buildConnectionStatus(webRtcState),
              ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).errorLoadingConsultation,
                style:
                    AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(S.of(context).goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoViews(WebRtcState webRtcState) {
    return Stack(
      children: [
        // Remote Video (Full Screen)
        if (webRtcState.remoteRenderer != null)
          Positioned.fill(
            child: RTCVideoView(
              webRtcState.remoteRenderer!,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          )
        else
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.video_call,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),

        // Local Video (Picture-in-Picture)
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          right: 20,
          width: 120,
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: webRtcState.localRenderer != null
                  ? RTCVideoView(
                      webRtcState.localRenderer!,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(dynamic consultation, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consultation.type == 'EMERGENCY'
                      ? S.of(context).emergencyConsultation
                      : S.of(context).videoConsultation,
                  style:
                      AppTextStyles.titleMedium.copyWith(color: Colors.white),
                ),
                Text(
                  'with Dr. ${consultation.doctorName ?? 'Unknown'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: consultation.status == 'IN_PROGRESS'
                  ? Colors.green
                  : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              consultation.status == 'IN_PROGRESS'
                  ? S.of(context).live
                  : S.of(context).connecting,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(WebRtcState webRtcState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                webRtcState.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            webRtcState.isInitializing
                ? 'Initializing...'
                : webRtcState.isConnected
                    ? 'Connected'
                    : 'Connecting...',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _toggleAudio() {
    final webRtcState = ref.read(webRtcProvider);
    ref.read(webRtcProvider.notifier).toggleAudio(!webRtcState.isAudioMuted);
  }

  void _toggleVideo() {
    final webRtcState = ref.read(webRtcProvider);
    ref.read(webRtcProvider.notifier).toggleVideo(!webRtcState.isVideoMuted);
  }

  void _toggleChat() {
    setState(() => _isChatVisible = !_isChatVisible);
  }

  void _toggleInfoPanel() {
    setState(() => _isInfoPanelVisible = !_isInfoPanelVisible);
  }

  void _endCall() {
    ref.read(webRtcProvider.notifier).endCall();
    context.pop();
  }
}
