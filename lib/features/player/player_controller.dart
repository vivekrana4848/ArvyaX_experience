import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../core/utils/database_helper.dart';
import '../../data/models/ambience_model.dart';

// ── Session State ─────────────────────────────────────────────────────────────

class SessionState {
  final AmbienceModel? ambience;
  final bool isPlaying;
  final int secondsRemaining;
  final Duration position;
  final Duration audioDuration;
  final bool isCompleted;

  const SessionState({
    this.ambience,
    this.isPlaying = false,
    this.secondsRemaining = 0,
    this.position = Duration.zero,
    this.audioDuration = Duration.zero,
    this.isCompleted = false,
  });

  bool get isActive => ambience != null && !isCompleted;

  double get progressFraction {
    if (ambience == null || ambience!.duration == 0) return 0.0;
    final elapsed = ambience!.duration - secondsRemaining;
    return (elapsed / ambience!.duration).clamp(0.0, 1.0);
  }

  SessionState copyWith({
    AmbienceModel? ambience,
    bool? isPlaying,
    int? secondsRemaining,
    Duration? position,
    Duration? audioDuration,
    bool? isCompleted,
    bool clearAmbience = false,
  }) {
    return SessionState(
      ambience: clearAmbience ? null : (ambience ?? this.ambience),
      isPlaying: isPlaying ?? this.isPlaying,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      position: position ?? this.position,
      audioDuration: audioDuration ?? this.audioDuration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ── PlayerController ──────────────────────────────────────────────────────────

class PlayerController extends StateNotifier<SessionState> {
  final AudioPlayer _audio = AudioPlayer();
  Timer? _sessionTimer;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;

  PlayerController() : super(const SessionState()) {
    _listenToAudio();
  }

  void _listenToAudio() {
    _positionSub = _audio.positionStream.listen((pos) {
      if (mounted) {
        state = state.copyWith(position: pos);
      }
    });

    _durationSub = _audio.durationStream.listen((dur) {
      if (mounted && dur != null) {
        state = state.copyWith(audioDuration: dur);
      }
    });

    _playerStateSub = _audio.playerStateStream.listen((ps) {
      if (mounted) {
        state = state.copyWith(isPlaying: ps.playing);
      }
    });
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> startSession(AmbienceModel ambience) async {
    // Already running the same session — resume if paused
    if (state.ambience?.id == ambience.id && state.isActive) {
      if (!state.isPlaying) await _audio.play();
      return;
    }

    // Stop existing session cleanly
    await _cleanupSession();

    // 1. Set state immediately so player screen renders correctly on first frame
    state = SessionState(
      ambience: ambience,
      isPlaying: true, // optimistic — audio is about to start
      secondsRemaining: ambience.duration,
    );

    // 2. Initialize audio (non-blocking from caller’s perspective — navigation
    //    already happened via Future.microtask before this runs)
    try {
      if (kIsWeb) {
        // Web: plain asset path (background service not supported)
        await _audio.setAsset(ambience.audioAsset);
      } else {
        // Native: MediaItem tag drives the OS notification/lock-screen controls
        await _audio.setAudioSource(
          AudioSource.asset(
            ambience.audioAsset,
            tag: MediaItem(
              id: ambience.id.toString(),
              title: ambience.title,
              artist: 'ArvyaX',
            ),
          ),
        );
      }
      await _audio.setLoopMode(LoopMode.one);
      await _audio.play();
      _startSessionTimer();
      _persistSession(); // fire-and-forget, no need to block
    } catch (e) {
      debugPrint('[PlayerController] Audio error: $e');
      if (mounted) state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
  }

  Future<void> pause() async => _audio.pause();
  Future<void> resume() async => _audio.play();

  /// Seek to a specific second offset in the SESSION timer.
  /// This updates [secondsRemaining] in state (so the slider stays put)
  /// and also syncs the audio position proportionally.
  Future<void> seekTo(Duration position) async {
    final ambience = state.ambience;
    if (ambience == null) return;

    // Clamp to valid range
    final totalSeconds = ambience.duration;
    final seekSeconds = position.inSeconds.clamp(0, totalSeconds);
    final newRemaining = totalSeconds - seekSeconds;

    // 1. Update state immediately so slider doesn't snap back
    if (mounted) {
      state = state.copyWith(secondsRemaining: newRemaining);
    }

    // 2. Sync audio position (seek within the looping track)
    try {
      await _audio.seek(Duration(seconds: seekSeconds));
    } catch (e) {
      debugPrint('[PlayerController] seekTo error: $e');
    }
  }

  /// Convenience: seek by elapsed seconds (for the session timer seek bar).
  Future<void> seekToSeconds(int elapsedSeconds) async {
    await seekTo(Duration(seconds: elapsedSeconds));
  }

  Future<void> endSession() async {
    await _cleanupSession();
    state = const SessionState(isCompleted: true);
    // Brief delay, then fully clear
    await Future.delayed(const Duration(milliseconds: 300));
    state = const SessionState();
    await DatabaseHelper.instance.clearSessionState();
  }

  /// Called by app lifecycle observer when app goes to background.
  Future<void> onAppPaused() async {
    // With just_audio_background, we don't want to pause audio here.
    // The session timer will continue to run to keep state synced.
  }

  /// Called by app lifecycle observer when app resumes.
  Future<void> onAppResumed() async {
    // State is already maintained by the background service and timer.
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!state.isPlaying) return;

      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        _onSessionComplete();
      } else {
        state = state.copyWith(secondsRemaining: remaining);
      }
    });
  }

  Future<void> _onSessionComplete() async {
    _sessionTimer?.cancel();
    await _audio.stop();
    state = state.copyWith(isCompleted: true, isPlaying: false, secondsRemaining: 0);
    await DatabaseHelper.instance.clearSessionState();
  }

  Future<void> _cleanupSession() async {
    _sessionTimer?.cancel();
    await _audio.stop();
  }

  Future<void> _persistSession() async {
    final a = state.ambience;
    if (a == null) return;
    await DatabaseHelper.instance.upsertSessionState({
      'ambience_title': a.title,
      'ambience_id': a.id,
      'ambience_audio': a.audioAsset,
      'ambience_image': a.imageAsset,
      'is_playing': 1,
      'seconds_remaining': a.duration,
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final playerControllerProvider =
    StateNotifierProvider<PlayerController, SessionState>(
  (ref) => PlayerController(),
);

/// Convenience: is any session currently active?
final isSessionActiveProvider = Provider<bool>((ref) {
  return ref.watch(playerControllerProvider).isActive;
});
