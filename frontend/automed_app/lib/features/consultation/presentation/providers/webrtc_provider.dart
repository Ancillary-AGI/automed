import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:automed_app/core/config/app_config.dart';
import 'package:automed_app/core/utils/logger.dart';

class WebRtcState {
  final bool isConnected;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;
  final String? error;
  final bool isInitializing;

  WebRtcState({
    this.isConnected = false,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.localRenderer,
    this.remoteRenderer,
    this.error,
    this.isInitializing = false,
  });

  WebRtcState copyWith({
    bool? isConnected,
    bool? isAudioMuted,
    bool? isVideoMuted,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
    String? error,
    bool? isInitializing,
  }) {
    return WebRtcState(
      isConnected: isConnected ?? this.isConnected,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      localRenderer: localRenderer ?? this.localRenderer,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
      error: error ?? this.error,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class WebRtcNotifier extends StateNotifier<WebRtcState> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  WebSocketChannel? _signalingChannel;
  String? _consultationId;

  final AppConfig _config = AppConfig.fromEnvironment();

  WebRtcNotifier() : super(WebRtcState());

  Future<void> initializeConnection(
    String consultationId,
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    try {
      state = state.copyWith(isInitializing: true, error: null);

      _consultationId = consultationId;

      // Initialize renderers
      await localRenderer.initialize();
      await remoteRenderer.initialize();

      // Create peer connection
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ]
      });

      // Get user media
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        }
      });

      // Add local stream to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Set local renderer
      localRenderer.srcObject = _localStream;

      // Setup signaling
      _setupSignaling();

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams[0];
          state = state.copyWith(remoteRenderer: remoteRenderer);
        }
      };

      // Listen for ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _sendSignalingMessage('ice-candidate', candidate.toMap());
            };

      // Listen for connection state changes
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        Logger.info('Connection state: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          this.state =
              this.state.copyWith(isConnected: true, isInitializing: false);
        } else if (state ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          this.state =
              this.state.copyWith(isConnected: false, error: 'Connection lost');
        }
      };

      state = state.copyWith(
        localRenderer: localRenderer,
        remoteRenderer: remoteRenderer,
        isInitializing: false,
      );

      // Create offer if we're the initiator
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendSignalingMessage('offer', offer.toMap());
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isInitializing: false,
      );
    }
  }

  void _setupSignaling() {
    final wsUrl = '${_config.wsBaseUrl}/consultation/$_consultationId';
    _signalingChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _signalingChannel!.stream.listen(
      (message) {
        _handleSignalingMessage(message);
      },
      onError: (error) {
        state = state.copyWith(error: 'Signaling error: $error');
      },
      onDone: () {
        Logger.info('Signaling channel closed');
      },
    );
  }

  void _handleSignalingMessage(String message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      final payload = data['data'];

      switch (type) {
        case 'offer':
          _handleOffer(payload);
          break;
        case 'answer':
          _handleAnswer(payload);
          break;
        case 'ice-candidate':
          _handleIceCandidate(payload);
          break;
      }
    } catch (e) {
      Logger.error('Error handling signaling message: $e');
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> offerData) async {
    if (_peerConnection != null) {
      final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
      await _peerConnection!.setRemoteDescription(offer);

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendSignalingMessage('answer', answer.toMap());
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> answerData) async {
    if (_peerConnection != null) {
      final answer =
          RTCSessionDescription(answerData['sdp'], answerData['type']);
      await _peerConnection!.setRemoteDescription(answer);
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidateData) async {
    if (_peerConnection != null) {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    }
  }

  void _sendSignalingMessage(String type, dynamic data) {
    if (_signalingChannel != null) {
      final message = jsonEncode({
        'type': type,
        'data': data,
        'from': 'client', // You might want to use actual user ID
      });
      _signalingChannel!.sink.add(message);
    }
  }

  void toggleAudio(bool muted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !muted;
      });
    }
    state = state.copyWith(isAudioMuted: muted);
  }

  void toggleVideo(bool muted) {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = !muted;
      });
    }
    state = state.copyWith(isVideoMuted: muted);
  }

  void endCall() {
    // Close peer connection
    _peerConnection?.close();
    _peerConnection = null;

    // Stop local stream
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream = null;

    // Close signaling channel
    _signalingChannel?.sink.close();
    _signalingChannel = null;

    // Dispose renderers
    state.localRenderer?.dispose();
    state.remoteRenderer?.dispose();

    state = WebRtcState();
  }
}

final webRtcProvider =
    StateNotifierProvider<WebRtcNotifier, WebRtcState>((ref) {
  return WebRtcNotifier();
});
