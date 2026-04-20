import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/duration_formatter.dart';
import '../../shared/widgets/glass_container.dart';
import '../journal/journal_entry_screen.dart';
import 'player_controller.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({super.key});

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathAnim = CurvedAnimation(
      parent: _breathCtrl,
      curve: Curves.easeInOut,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _breathCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = ref.read(playerControllerProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ctrl.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ctrl.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(playerControllerProvider);
    final ambience = session.ambience;

    // Auto-dismiss when session completes
    ref.listen<SessionState>(playerControllerProvider, (prev, next) {
      if (next.isCompleted && context.mounted) {
        _showSessionCompleteDialog();
      }
    });

    if (ambience == null) {
      // Audio is initializing — show an ambient loading screen
      // (appears immediately on first tap, disappears once session starts)
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _breathAnim,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF1A0B2E),
                      const Color(0xFF0D1F4A),
                      _breathAnim.value,
                    )!,
                    Color.lerp(
                      const Color(0xFF0B1440),
                      const Color(0xFF1A0B30),
                      _breathAnim.value,
                    )!,
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textPrimary,
                                size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.nowPlaying,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: AppColors.accentPurple,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Starting session…',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _breathAnim,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF1A0B2E),
                    const Color(0xFF0D1F4A),
                    _breathAnim.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF0B1440),
                    const Color(0xFF1A0B30),
                    _breathAnim.value,
                  )!,
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(child: _buildBody(context, session, ambience)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GlassContainer(
            borderRadius: 12,
            padding: EdgeInsets.zero,
            blurSigma: 10,
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textPrimary, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                AppStrings.nowPlaying,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, SessionState session, dynamic ambience) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Breathing orb ────────────────────────────────────
          _buildBreathingOrb(ambience),

          // ── Track info ────────────────────────────────────────
          Column(
            children: [
              Text(
                ambience.title,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                ambience.tag,
                style: const TextStyle(
                  color: AppColors.accentPurpleLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // ── Seek + Timer ──────────────────────────────────────
          _buildSeekSection(context, session, ambience),

          // ── Controls ─────────────────────────────────────────
          _buildControls(context, session),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBreathingOrb(dynamic ambience) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Transform.scale(
                scale: 0.9 + (_pulseAnim.value * 0.1),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentPurple.withValues(alpha: 0.0),
                        AppColors.accentPurple
                            .withValues(alpha: 0.15 * _pulseAnim.value),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Inner orb with image or gradient
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.accentPurple.withValues(alpha: 0.35),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    ambience.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.accentGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeekSection(
      BuildContext context, SessionState session, dynamic ambience) {
    final elapsed = ambience.duration - session.secondsRemaining;
    final total = ambience.duration;
    final progress = session.progressFraction;

    return Column(
      children: [
        // Seek slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accentPurple,
            inactiveTrackColor: AppColors.glassWhite,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            trackHeight: 3.5,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              // value is 0.0–1.0 (fraction of total session elapsed)
              // Convert to elapsed seconds, then seek
              final elapsedSeconds = (total * value).round().clamp(0, total);
              ref
                  .read(playerControllerProvider.notifier)
                  .seekTo(Duration(seconds: elapsedSeconds));
            },
          ),
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(elapsed),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              // Remaining timer (session countdown)
              AnimatedBuilder(
                animation: _breathAnim,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DurationFormatter.format(session.secondsRemaining),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accentPurpleLight,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, SessionState session) {
    return Column(
      children: [
        // Play/Pause
        GestureDetector(
          onTap: () =>
              ref.read(playerControllerProvider.notifier).togglePlay(),
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withValues(
                          alpha: 0.4 + 0.1 * _pulseAnim.value),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  session.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),

        // End Session
        TextButton(
          onPressed: () => _showEndSessionDialog(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stop_circle_outlined,
                  size: 16, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text(
                AppStrings.endSession,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.endSessionTitle,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          AppStrings.endSessionMessage,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.endSessionCancel,
              style: TextStyle(color: AppColors.accentPurpleLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(playerControllerProvider.notifier).endSession();
              if (context.mounted) {
                Navigator.pop(context); // Pop player
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JournalEntryScreen(),
                  ),
                );
              }
            },
            child: const Text(
              AppStrings.endSessionConfirm,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '✨ Session Complete',
          style: TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Your session has ended. Take a moment to reflect.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Pop player
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const JournalEntryScreen()),
              );
            },
            child: const Text('Write Reflection'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
