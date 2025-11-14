import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcState {
  final bool isConnected;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;

  WebRtcState({
    this.isConnected = false,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.localRenderer,
    this.remoteRenderer,
  });

  WebRtcState copyWith({
    bool? isConnected,
    bool? isAudioMuted,
    bool? isVideoMuted,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
  }) {
    return WebRtcState(
      isConnected: isConnected ?? this.isConnected,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      localRenderer: localRenderer ?? this.localRenderer,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
    );
  }
}

class WebRtcNotifier extends StateNotifier<WebRtcState> {
  WebRtcNotifier() : super(WebRtcState());

  Future<void> initializeConnection(
    String consultationId,
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    // TODO: Implement WebRTC connection initialization
    state = state.copyWith(
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
    );
  }

  void toggleAudio(bool muted) {
    // TODO: Implement audio toggle
    state = state.copyWith(isAudioMuted: muted);
  }

  void toggleVideo(bool muted) {
    // TODO: Implement video toggle
    state = state.copyWith(isVideoMuted: muted);
  }

  void endCall() {
    // TODO: Implement call ending
    state = state.copyWith(isConnected: false);
  }
}

final webRtcProvider =
    StateNotifierProvider<WebRtcNotifier, WebRtcState>((ref) {
  return WebRtcNotifier();
});
